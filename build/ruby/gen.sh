#!/usr/bin/env bash
# Ruby pane: YARD over lib/.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC="$ROOT/_build/sdks/signalwire-ruby"
OUT="$ROOT/langs/ruby"

rm -rf "$OUT"
cd "$SRC"
export PATH="$(ruby -e 'print Gem.bindir'):$PATH"
yard doc --quiet --no-cache --no-save \
  --output-dir "$OUT" --title "SignalWire Ruby SDK" \
  'lib/**/*.rb'
bash "$ROOT/build/scripts/embed-readme-logo.sh" "$OUT"
echo "ruby -> $OUT ($(find "$OUT" -name '*.html' | wc -l) pages)"
