#!/usr/bin/env bash
# PHP pane: Doxygen (PHP mode) over the SDK src/.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export SW_SRC="$ROOT/_build/sdks/signalwire-php"
export SW_OUT="$ROOT/langs/php"
export SW_THEME="$ROOT/_build/tools/doxygen-awesome-css"

rm -rf "$SW_OUT"; mkdir -p "$SW_OUT"
doxygen "$ROOT/build/php/Doxyfile"
bash "$ROOT/build/scripts/embed-readme-logo.sh" "$SW_OUT"
echo "php -> $SW_OUT ($(find "$SW_OUT" -name '*.html' | wc -l) pages)"
