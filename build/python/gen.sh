#!/usr/bin/env bash
# Python pane: MkDocs Material + mkdocstrings. One API page per importable
# top-level subpackage of `signalwire`, discovered at build time.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC="$ROOT/_build/sdks/signalwire-python"
DOCS="$ROOT/_build/out/python-docs"
CFG="$ROOT/build/python/mkdocs.yml"

# Install the SDK + its dependencies so mkdocstrings can import it.
pip install -q -e "$SRC" || pip install -q -r "$SRC/requirements.txt"

# Generate the docs tree: index + one API page per subpackage.
rm -rf "$DOCS"; mkdir -p "$DOCS/api"
# Landing page = the SDK README.
cp "$SRC/README.md" "$DOCS/index.md"

PYTHONPATH="$SRC/signalwire" python - "$DOCS/api" <<'PY'
import sys, os, pkgutil, importlib
out = sys.argv[1]
pkg = importlib.import_module("signalwire")
names = sorted(m.name for m in pkgutil.iter_modules(pkg.__path__))
for name in names:
    if name.startswith("_"):
        continue
    slug = name.replace("_", "-")
    with open(os.path.join(out, f"{slug}.md"), "w") as fh:
        fh.write(f"# signalwire.{name}\n\n::: signalwire.{name}\n")
print("api pages:", ", ".join(names))
PY

mkdocs build --quiet --config-file "$CFG"
bash "$ROOT/build/scripts/embed-readme-logo.sh" "$ROOT/langs/python"
echo "python -> $ROOT/langs/python ($(find "$ROOT/langs/python" -name '*.html' | wc -l) pages)"
