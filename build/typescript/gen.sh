#!/usr/bin/env bash
# TypeScript pane: TypeDoc over the SDK's src/ (each file becomes a module).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC="$ROOT/_build/sdks/signalwire-typescript"
OUT="$ROOT/langs/typescript"
CFG="$ROOT/build/typescript/typedoc.json"

cd "$SRC"
[ -d node_modules ] || npm ci --no-audit --no-fund --silent
rm -rf "$OUT"
npx --yes typedoc@0.27 --options "$CFG" --out "$OUT" src
bash "$ROOT/build/scripts/embed-readme-logo.sh" "$OUT"
echo "typescript -> $OUT ($(find "$OUT" -name '*.html' | wc -l) pages)"
