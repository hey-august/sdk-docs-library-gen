// POC shell: vertical tabs -> iframe swap.
// Each language pane is its own native generator output, isolated in an iframe.

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

const docPath = (id) => `langs/${id}/index.html`;

function render() {
  const nav = document.getElementById("tabs");
  nav.innerHTML = "";
  for (const lang of LANGS) {
    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "tab";
    btn.role = "tab";
    btn.id = `tab-${lang.id}`;
    btn.dataset.lang = lang.id;
    btn.style.setProperty("--lang-color", lang.color);
    btn.setAttribute("aria-selected", "false");
    btn.innerHTML = `
      <span class="swatch" aria-hidden="true"></span>
      <span class="label">${lang.label}</span>
      <span class="gen">${lang.generator}</span>
    `;
    btn.addEventListener("click", () => select(lang.id, true));
    nav.appendChild(btn);
  }
}

function select(id, pushHash) {
  const lang = LANGS.find((l) => l.id === id) || LANGS[0];
  for (const btn of document.querySelectorAll(".tab")) {
    btn.setAttribute("aria-selected", btn.dataset.lang === lang.id ? "true" : "false");
  }
  const frame = document.getElementById("doc-frame");
  frame.src = docPath(lang.id);
  document.title = `SignalWire ${lang.label} — Docs POC`;
  if (pushHash) {
    history.replaceState(null, "", `#${lang.id}`);
  }
}

function initial() {
  const hash = location.hash.replace(/^#/, "");
  const found = LANGS.find((l) => l.id === hash);
  select(found ? found.id : LANGS[0].id, false);
}

window.addEventListener("hashchange", initial);
document.addEventListener("DOMContentLoaded", () => { render(); initial(); });
