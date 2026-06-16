#!/usr/bin/env bash
# .NET pane: DocFX (modern template) over the SignalWire class library.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC="$ROOT/_build/sdks/signalwire-dotnet"
OUT="$ROOT/langs/dotnet"

export DOTNET_ROOT="$(brew --prefix)/opt/dotnet/libexec"
export DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1
export PATH="$DOTNET_ROOT:$HOME/.dotnet/tools:$PATH"

cd "$SRC"
cp "$ROOT/build/dotnet/docfx.json" docfx.json
cp "$ROOT/build/dotnet/toc.yml" toc.yml
# Landing page = the SDK README (DocFX renders the content-root index.md).
cp README.md index.md
dotnet restore src/SignalWire/SignalWire.csproj
docfx docfx.json

rm -rf "$OUT"; mkdir -p "$OUT"
cp -a _docfx_site/. "$OUT"/
rm -rf docfx.json index.md toc.yml api _docfx_site
bash "$ROOT/build/scripts/embed-readme-logo.sh" "$OUT"
echo "dotnet -> $OUT ($(find "$OUT" -name '*.html' | wc -l) pages)"
