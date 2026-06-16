#!/usr/bin/env python3
"""Render gomarkdoc per-package Markdown into the styled Go pane HTML shell.

Reused by build/go/gen.sh. Reads <md_dir>/<slug>.md files and the package
manifest (slug<TAB>label, in nav order) on stdin, writes <out_dir>/<slug>.html
plus an overview index.html. Styling comes from the committed assets/style.css.
"""
import sys, os, html, markdown

md_dir, out_dir = sys.argv[1], sys.argv[2]
readme = sys.argv[3] if len(sys.argv) > 3 else None
pkgs = [line.rstrip("\n").split("\t") for line in sys.stdin if line.strip()]

def sidebar(active):
    items = []
    for slug, label in pkgs:
        cls = ' class="active"' if slug == active else ""
        items.append(
            f'    <li><a href="{slug}.html" data-pkg="{slug}"{cls}>{html.escape(label)}</a></li>'
        )
    return "\n".join(items)

def page(active, title, body):
    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<title>{html.escape(title)} — SignalWire Go SDK</title>
<link rel="stylesheet" href="assets/style.css" />
</head>
<body>
<nav class="side">
  <header>
    <div class="brand"><span class="gopher"></span> SignalWire Go SDK</div>
    <div style="color:var(--fg-dim);font-size:12px;margin-top:4px">github.com/signalwire/signalwire-go</div>
  </header>
  <div class="subnav">Packages</div>
  <ul>
{sidebar(active)}
  </ul>
</nav>
<main>
{body}
</main>
</body>
</html>
"""

def render_md(text):
    # gomarkdoc output: codehilite so the Pygments classes match style.css.
    return markdown.markdown(
        text,
        extensions=["codehilite", "fenced_code", "tables", "toc", "attr_list"],
        extension_configs={"codehilite": {"guess_lang": False}},
    )

def render_readme(text):
    # READMEs open with a raw <div align="center"> header that Python-Markdown
    # swallows whole; markdown-it (CommonMark) renders the markdown inside it.
    from markdown_it import MarkdownIt
    return MarkdownIt("commonmark", {"html": True}).enable(["table", "strikethrough"]).render(text)

os.makedirs(out_dir, exist_ok=True)
for slug, label in pkgs:
    src = os.path.join(md_dir, f"{slug}.md")
    if not os.path.exists(src):
        continue
    with open(src) as fh:
        body = render_md(fh.read())
    with open(os.path.join(out_dir, f"{slug}.html"), "w") as fh:
        fh.write(page(slug, label, body))

# Overview index: the SDK README (packages remain in the sidebar).
if readme and os.path.exists(readme):
    with open(readme) as fh:
        overview = render_readme(fh.read())
else:
    links = "\n".join(
        f'<li><a href="{slug}.html">{html.escape(label)}</a></li>' for slug, label in pkgs
    )
    overview = f"<h1>SignalWire Go SDK</h1>\n<h2>Packages</h2>\n<ul>\n{links}\n</ul>"
with open(os.path.join(out_dir, "index.html"), "w") as fh:
    fh.write(page(None, "Overview", overview))
print(f"go pages: {len(pkgs)}")
