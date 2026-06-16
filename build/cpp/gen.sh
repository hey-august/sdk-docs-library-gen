#!/usr/bin/env bash
# C++ pane: Doxygen over the SDK headers + sources.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export SW_SRC="$ROOT/_build/sdks/signalwire-cpp"
export SW_OUT="$ROOT/langs/cpp"
export SW_THEME="$ROOT/_build/tools/doxygen-awesome-css"

rm -rf "$SW_OUT"; mkdir -p "$SW_OUT"
doxygen "$ROOT/build/cpp/Doxyfile"
bash "$ROOT/build/scripts/embed-readme-logo.sh" "$SW_OUT"
echo "cpp -> $SW_OUT ($(find "$SW_OUT" -name '*.html' | wc -l) pages)"
