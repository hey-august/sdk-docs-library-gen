# Wrapper navbar & theme sync

The wrapper adds the Fern navbar (including quick links to Support and other
docs) plus a menu to switch to another language. In the proof of concept it also
syncs each generator's light/dark theme to the Fern docs site's global theme
control.

## Decision: inject, via a shared hosted navbar asset

**Status:** decided (2026-06-17). Supersedes the iframe approach used in the PoC.

The navbar could be attached to the generated reference in one of two ways:

- **Inject** — each generated site carries the Fern navbar directly. One
  canonical site per language; every page is a real, deep-linkable, crawlable
  URL.
- **Host the wrapper separately + iframe** — a single shell hosts the navbar and
  iframes the unmodified generator output. The PoC works this way: generated
  output on disk is never modified, and switching languages just swaps the
  iframe `src`.

We are going with **inject**. The deciding factor is that the iframe model
produces **two URLs for every page** — the wrapper URL and the bare pane URL —
which works against three goals the proposal already commits to:

- **llms.txt + SEO discoverability.** Crawlers and the `llms.txt` index must
  point at the bare pane URLs (iframe content is a discoverability hazard), so
  anyone who searches or lands there gets the naked generator output with no
  navbar. The wrapped experience and the discoverable experience would be
  different URLs.
- **Redirects from Fern.** Old tech-ref links should land on a specific symbol
  page. With inject that's just the real page URL; with iframe it's a wrapper
  URL that then has to JS-route the iframe to the deep link.
- **Deep links / history / "copy this URL".** Native with inject; fragile JS
  plumbing with iframe (the PoC's `app.js` already carries this weight).

The iframe model's headline advantage — never modifying generator output — is a
PoC convenience, not a product requirement, and it isn't worth the runtime
fragility on exactly the axes we care about.

### How inject stays DRY

The obvious cost of inject is that the navbar would touch 10 generators with 10
different header mechanisms, and the markup would live in 10 places (drifting
when Fern's navbar changes). Both costs dissolve by injecting a **reference to a
shared hosted asset**, not the markup itself:

- Publish the navbar as one canonical bundle —
  `reference.signalwire.com/_shell/navbar.{js,css}` — that mounts the Fern bar +
  the language/version switcher at runtime into a known mount point.
- Each generator's header hook then only needs **one line**: a `<link>` +
  `<script>` tag pointing at that bundle. Every generator supports this
  (rustdoc `--html-in-header`, Doxygen `HTML_HEADER`/`HTML_EXTRA_FILES`, Javadoc
  `-header`/`-top`, MkDocs Material `overrides/`, DocFX templates, YARD
  templates, Pod wrapper). TypeDoc and gomarkdoc (already post-processed static
  HTML) take a small post-build step instead.
- For any generator where the header hook is awkward, a **uniform post-build
  step** that adds those two tags to `<head>` of every emitted `.html` works
  identically across all 10 — and in the inject model "we edited the output" is
  no longer a constraint.

Result: exactly **one source of truth for the navbar**, but every page is a
real, crawlable, deep-linkable URL. Per-generator work shrinks from "build a
navbar 10 times" to "add a header include 10 times."

### Validation spike

Before committing the whole fleet, prove the one-line include + runtime mount
against the two trickiest generators for header injection — **TypeDoc** and
**gomarkdoc** (Go output is post-processed static HTML). If those two work
cleanly, the other eight are easier.

Theme sync also gets simpler under inject: each page is same-origin with its own
navbar, so the PoC's cross-frame bridge becomes ordinary in-page JS — no
`postMessage`, no origin assumptions.

## Theme sync (as implemented in the PoC)

The shell stores the theme preference in `localStorage["theme"]` as
`light | dark | system` — the exact key and semantics next-themes uses on
signalwire.com/docs. Hosted on the signalwire.com origin, the user's docs theme
carries over both ways automatically, and `storage` events give live cross-tab
sync. The shell then drives light/dark inside each generator on every load and
toggle:

| Lang | Mechanism |
|------|-----------|
| C++ / PHP (Doxygen awesome) | `dark-mode` / `light-mode` class on `<html>` |
| C# (DocFX modern) | `data-bs-theme` attribute |
| Python (MkDocs Material) | `data-md-color-scheme` (`slate` / `default`) |
| Rust (rustdoc) | `data-theme` attribute + `rustdoc-theme` localStorage |
| TypeScript (TypeDoc) | `data-theme` attribute + `tsd-theme` localStorage |
| Java (Javadoc 17+) | CSS custom property overrides (injected stylesheet) |
| Ruby (YARD), Go, Perl | injected dark stylesheet (`assets/css/iframe-dark.css`) |

Generators with their own theme persistence get their localStorage keys seeded
so internally-navigated pages restore the right theme themselves.
