# Demo: generated SDK docs behind the SignalWire Docs navbar

Language-native API docs for the 10 SignalWire Server SDKs, presented behind a
clone of the Fern navbar from [signalwire.com/docs](https://signalwire.com/docs).
Each pane is the unmodified HTML output of that language's canonical generator.

## View

```bash
python3 -m http.server -d . 8000
```

Open <http://localhost:8000>.

## The navbar

A static clone of the production Fern header, built from the live site's
rendered markup, its compiled component CSS, and the custom product-selector
styling in `signalwire-docs/docs/fern/styles.css`:

- **Product switcher** — the custom 3-column mega-menu (Explore SignalWire /
  SDKs / APIs groups, Compatibility API footer link), with an **SDK Reference**
  card added to the SDKs column showing where this product would slot in.
  Product links go to the live docs site.
- **Language dropdown** — replaces the search bar in the center slot; switches
  the iframe between the 10 generated SDK doc sites.
- **Right side** — Log in, Sign up, Support menu (with the pulsing status
  dot), and the theme control, all as configured in `docs.yml`.

Design tokens (`assets/fern/tokens.css`) are the Radix-style accent/grayscale
scales Fern generates from the site's configured colors (SW Blue light /
SW Turquoise dark), extracted from the live render.

## Theme sync

The shell stores the theme preference in `localStorage["theme"]` as
`light | dark | system` — the exact key and semantics next-themes uses on
signalwire.com/docs (the same bootstrap snippet runs before first paint).
Hosted on the signalwire.com origin, the user's docs theme carries over both
ways automatically; `storage` events give live cross-tab sync.

The shell then drives light/dark inside each generator's iframe on every load
and toggle:

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
so internally-navigated pages restore the right theme themselves. Generated
output on disk is never modified.

## Generators

| Lang | Tool |
|------|------|
| C++ | Doxygen + doxygen-awesome-css |
| C# / .NET | DocFX |
| Go | gomarkdoc → static HTML |
| Java | Javadoc |
| Perl | Pod::Simple::XHTML |
| PHP | Doxygen (PHP mode) |
| Python | MkDocs Material + mkdocstrings |
| Ruby | YARD |
| Rust | rustdoc |
| TypeScript | TypeDoc |

## Layout

```
index.html               shell: navbar + iframe
assets/fern/             cloned Fern tokens + header component CSS
assets/css/app.css       shell layout + language dropdown
assets/css/iframe-dark.css  injected dark theme for Javadoc/YARD/go/perl
assets/js/app.js         dropdowns, routing, theme manager + iframe bridge
assets/img/, assets/fonts/  logo, favicon, product icons, brand fonts
home/                    overview pane
langs/<id>/              generated docs for each SDK
_build/                  build configs + toolchains (gitignored)
```
