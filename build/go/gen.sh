#!/usr/bin/env bash
# Go pane: gomarkdoc per package -> Markdown -> styled HTML shell (render.py).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC="$ROOT/_build/sdks/signalwire-go"
OUT="$ROOT/langs/go"
MD="$ROOT/_build/out/go-md"
MODULE="github.com/signalwire/signalwire-go"
GOMARKDOC="$(command -v gomarkdoc || echo "$ROOT/_build/tools/bin/gomarkdoc")"

cd "$SRC"
rm -rf "$MD"; mkdir -p "$MD"

# Documentable packages: skip internal, command, example, and test-only dirs.
pkgs="$(go list ./... | grep -vE "/(internal|cmd|examples?|testdata|test)(/|$)")"

manifest=""
while IFS= read -r pkg; do
  rel="${pkg#$MODULE/}"; rel="${rel#pkg/}"   # drop module prefix + pkg/ wrapper
  [ "$rel" = "$pkg" ] && rel="$(basename "$pkg")"
  slug="${rel//\//-}"                         # rest/namespaces -> rest-namespaces
  label="${rel//\//.}"                        # rest/namespaces -> rest.namespaces
  if "$GOMARKDOC" --output "$MD/$slug.md" "$pkg" 2>/dev/null && [ -s "$MD/$slug.md" ]; then
    manifest+="$slug	$label"$'\n'
  fi
done <<< "$pkgs"

# Rebuild the pane, preserving the committed stylesheet.
rm -rf "$OUT"; mkdir -p "$OUT/assets"
cp "$ROOT/build/go/assets/style.css" "$OUT/assets/style.css"
printf '%s' "$manifest" | sort -t'	' -k2 | python "$ROOT/build/go/render.py" "$MD" "$OUT" "$SRC/README.md"
bash "$ROOT/build/scripts/embed-readme-logo.sh" "$OUT"
echo "go -> $OUT ($(find "$OUT" -name '*.html' | wc -l) pages)"
