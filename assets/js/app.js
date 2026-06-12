// Demo shell: Fern navbar clone + language dropdown + theme sync.
//
// Each language pane is its own native generator output, isolated in an
// iframe. The shell drives two things across that boundary:
//   1. navigation (hash -> iframe src)
//   2. theme (localStorage["theme"], same key/semantics as signalwire.com/docs)

const HOME = { id: "home", label: "Overview", generator: "All languages", path: "home/index.html" };

const LANGS = [
  { id: "cpp",        label: "C++",        generator: "Doxygen + awesome-css", color: "#00599C" },
  { id: "dotnet",     label: "C# / .NET",  generator: "DocFX",                 color: "#512BD4" },
  { id: "go",         label: "Go",         generator: "gomarkdoc",             color: "#00ADD8" },
  { id: "java",       label: "Java",       generator: "Javadoc",               color: "#ED8B00" },
  { id: "perl",       label: "Perl",       generator: "Pod::Simple::XHTML",    color: "#39457E" },
  { id: "php",        label: "PHP",        generator: "Doxygen (PHP mode)",    color: "#777BB4" },
  { id: "python",     label: "Python",     generator: "MkDocs + mkdocstrings", color: "#3776AB" },
  { id: "ruby",       label: "Ruby",       generator: "YARD",                  color: "#CC342D" },
  { id: "rust",       label: "Rust",       generator: "rustdoc",               color: "#DEA584" },
  { id: "typescript", label: "TypeScript", generator: "TypeDoc",               color: "#3178C6" },
];

const docPath = (id) => (id === HOME.id ? HOME.path : `langs/${id}/index.html`);

const CHECK_SVG =
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"></path></svg>';

let current = HOME.id;

/* =============================================================================
   THEME
   The Fern site stores the user preference in localStorage["theme"] as
   "light" | "dark" | "system" (next-themes). We read and write the exact same
   key, so on a shared origin (signalwire.com) the setting carries over both
   ways, and `storage` events give us live cross-tab sync.
   ============================================================================= */

const THEME_KEY = "theme";

function themePref() {
  let v = null;
  try { v = localStorage.getItem(THEME_KEY); } catch {}
  return v === "light" || v === "dark" ? v : "system";
}

function resolvedMode(pref = themePref()) {
  if (pref === "light" || pref === "dark") return pref;
  return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
}

function setThemePref(pref) {
  try { localStorage.setItem(THEME_KEY, pref); } catch {}
  applyTheme();
}

function applyTheme() {
  const pref = themePref();
  const mode = resolvedMode(pref);

  const html = document.documentElement;
  html.classList.remove("light", "dark");
  html.classList.add(mode);
  html.style.colorScheme = mode;

  // Sun in light, moon in dark — like the Fern header button.
  document.getElementById("theme-icon-sun").hidden = mode !== "light";
  document.getElementById("theme-icon-moon").hidden = mode !== "dark";

  // Check mark next to the active preference in the theme menu.
  for (const item of document.querySelectorAll("#theme-panel [data-theme-pref]")) {
    item.querySelector("[data-check]").innerHTML =
      item.dataset.themePref === pref ? CHECK_SVG : "";
  }

  seedGeneratorThemeStores(mode);
  themeFrame(mode);
}

// Generators whose own JS reads a theme preference from localStorage.
// Seeding these keys (same origin as the shell) means internally-navigated
// pages restore the right theme themselves, before our load handler runs.
function seedGeneratorThemeStores(mode) {
  try {
    localStorage.setItem("rustdoc-theme", mode);             // rustdoc
    localStorage.setItem("rustdoc-use-system-theme", "false");
    localStorage.setItem("tsd-theme", mode);                 // TypeDoc
    // doxygen-awesome stores deltas from the OS preference
    const osDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    localStorage.removeItem("prefers-dark-mode-in-light-mode");
    localStorage.removeItem("prefers-light-mode-in-dark-mode");
    if (mode === "dark" && !osDark) localStorage.setItem("prefers-dark-mode-in-light-mode", true);
    if (mode === "light" && osDark) localStorage.setItem("prefers-light-mode-in-dark-mode", true);
  } catch {}
}

/* --- Per-generator theme bridge ------------------------------------------ */

const INJECT_CSS_HREF = new URL("assets/css/iframe-dark.css", location.href).href;

function doxygenTheme(doc, mode) {
  doc.documentElement.classList.toggle("dark-mode", mode === "dark");
  doc.documentElement.classList.toggle("light-mode", mode === "light");
}

// Generators with no theming hooks at all (Javadoc, YARD, and our static
// go/perl wrappers) get a stylesheet injected by the shell; the generated
// output on disk stays pristine.
function injectedTheme(doc, mode, id) {
  doc.documentElement.dataset.swTheme = mode;
  doc.documentElement.dataset.swLang = id;
  if (!doc.querySelector('link[data-sw-theme-css]')) {
    const link = doc.createElement("link");
    link.rel = "stylesheet";
    link.href = INJECT_CSS_HREF;
    link.setAttribute("data-sw-theme-css", "");
    doc.head.appendChild(link);
  }
}

const THEMERS = {
  home: (doc, mode) => { doc.documentElement.dataset.swTheme = mode; },
  cpp: doxygenTheme,
  php: doxygenTheme,
  dotnet: (doc, mode) => doc.documentElement.setAttribute("data-bs-theme", mode),
  python: (doc, mode) =>
    doc.body && doc.body.setAttribute("data-md-color-scheme", mode === "dark" ? "slate" : "default"),
  rust: (doc, mode) => { doc.documentElement.dataset.theme = mode; },
  typescript: (doc, mode) => { doc.documentElement.dataset.theme = mode; },
  java: injectedTheme,
  ruby: injectedTheme,
  go: injectedTheme,
  perl: injectedTheme,
};

function themeDocument(doc, mode, id) {
  if (!doc || !doc.documentElement) return;
  doc.documentElement.style.colorScheme = mode;
  (THEMERS[id] || (() => {}))(doc, mode, id);

  // Some generators (YARD) nest their nav in a child iframe — theme it too,
  // now and on its own navigations.
  for (const nested of doc.querySelectorAll("iframe")) {
    if (!nested.dataset.swThemed) {
      nested.dataset.swThemed = "1";
      nested.addEventListener("load", () => themeDocument(nested.contentDocument, resolvedMode(), id));
    }
    try { themeDocument(nested.contentDocument, mode, id); } catch {}
  }
}

function themeFrame(mode = resolvedMode()) {
  const frame = document.getElementById("doc-frame");
  try { themeDocument(frame.contentDocument, mode, current); } catch {}
}

/* =============================================================================
   DROPDOWNS — minimal Radix-style open/close + anchored positioning
   ============================================================================= */

const dropdowns = [];

function registerDropdown(triggerId, panelId, { align = "start", offset = 8 } = {}) {
  const trigger = document.getElementById(triggerId);
  const panel = document.getElementById(panelId);
  const dd = {
    trigger, panel,
    get open() { return panel.dataset.state === "open"; },
    set(open) {
      panel.dataset.state = open ? "open" : "closed";
      trigger.dataset.state = open ? "open" : "closed";
      trigger.setAttribute("aria-expanded", String(open));
      if (open) position();
    },
  };

  function position() {
    const r = trigger.getBoundingClientRect();
    panel.style.top = `${r.bottom + offset}px`;
    if (align === "end") {
      panel.style.right = `${Math.max(8, window.innerWidth - r.right)}px`;
      panel.style.left = "auto";
    } else {
      const width = panel.offsetWidth;
      panel.style.left = `${Math.min(r.left, Math.max(8, window.innerWidth - width - 8))}px`;
      panel.style.right = "auto";
    }
    if (align === "stretch") panel.style.minWidth = `${r.width}px`;
  }

  trigger.addEventListener("click", (e) => {
    e.stopPropagation();
    const willOpen = !dd.open;
    closeAllDropdowns();
    dd.set(willOpen);
  });

  dropdowns.push(dd);
  return dd;
}

function closeAllDropdowns() {
  for (const dd of dropdowns) dd.set(false);
}

document.addEventListener("click", (e) => {
  if (!e.target.closest(".fern-dropdown, [data-testid='product-dropdown-content']")) {
    closeAllDropdowns();
  }
});

document.addEventListener("keydown", (e) => {
  if (e.key === "Escape") closeAllDropdowns();
});

window.addEventListener("resize", closeAllDropdowns);

/* =============================================================================
   LANGUAGE SWITCHER
   ============================================================================= */

function renderLangMenu() {
  const panel = document.getElementById("lang-panel");
  panel.innerHTML = "";
  for (const item of [HOME, ...LANGS]) {
    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "fern-dropdown-item";
    btn.dataset.lang = item.id;
    btn.setAttribute("role", "menuitemradio");
    btn.innerHTML = `
      <span class="fern-dropdown-item-indicator" data-check></span>
      <span class="lang-dot" style="--lang-color:${item.color || "var(--grayscale-8)"}"></span>
      <span>${item.label}</span>
      <span class="item-meta">${item.generator}</span>
    `;
    btn.addEventListener("click", () => {
      closeAllDropdowns();
      select(item.id, true);
    });
    panel.appendChild(btn);
  }
}

function updateLangUI(target) {
  document.getElementById("lang-trigger-label").textContent = target.label;
  document.getElementById("lang-trigger-meta").textContent =
    target.id === HOME.id ? "10 languages" : target.generator;
  for (const btn of document.querySelectorAll("#lang-panel [data-lang]")) {
    const selected = btn.dataset.lang === target.id;
    btn.setAttribute("aria-checked", String(selected));
    btn.querySelector("[data-check]").innerHTML = selected ? CHECK_SVG : "";
  }
}

function select(id, pushHash) {
  const target = id === HOME.id ? HOME : LANGS.find((l) => l.id === id) || HOME;
  current = target.id;

  const frame = document.getElementById("doc-frame");
  frame.src = docPath(target.id);

  updateLangUI(target);
  document.title =
    target.id === HOME.id
      ? "SignalWire SDK Reference — demo"
      : `SignalWire ${target.label} SDK Reference`;

  if (pushHash) {
    const newHash = target.id === HOME.id ? "" : `#${target.id}`;
    history.replaceState(null, "", newHash || location.pathname);
  }
}

function initial() {
  const hash = location.hash.replace(/^#/, "");
  const found = LANGS.find((l) => l.id === hash);
  select(found ? found.id : HOME.id, false);
}

/* =============================================================================
   INIT
   ============================================================================= */

document.addEventListener("DOMContentLoaded", () => {
  renderLangMenu();

  registerDropdown("product-trigger", "product-panel");
  registerDropdown("lang-trigger", "lang-panel", { align: "stretch" });
  registerDropdown("support-trigger", "support-panel", { align: "end" });
  registerDropdown("theme-trigger", "theme-panel", { align: "end" });

  // Theme menu: Light / Dark / System
  for (const item of document.querySelectorAll("#theme-panel [data-theme-pref]")) {
    item.addEventListener("click", () => {
      closeAllDropdowns();
      setThemePref(item.dataset.themePref);
    });
  }

  // Logo and the active "SDK Reference" product card both lead home.
  for (const elId of ["brand-link", "sdk-reference-card"]) {
    document.getElementById(elId).addEventListener("click", (e) => {
      e.preventDefault();
      closeAllDropdowns();
      select(HOME.id, true);
    });
  }

  // Re-theme the iframe on every navigation inside it.
  document.getElementById("doc-frame").addEventListener("load", () => themeFrame());

  // Live sync: another tab (or, on a shared origin, the Fern docs site)
  // changed the theme preference.
  window.addEventListener("storage", (e) => {
    if (e.key === THEME_KEY) applyTheme();
  });

  // Follow OS preference while in "system" mode.
  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", () => {
    if (themePref() === "system") applyTheme();
  });

  applyTheme();
  initial();
});

window.addEventListener("hashchange", initial);
