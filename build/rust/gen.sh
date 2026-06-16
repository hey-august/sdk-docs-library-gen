#!/usr/bin/env bash
# Rust pane: rustdoc via `cargo doc --no-deps`.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC="$ROOT/_build/sdks/signalwire-rust"
OUT="$ROOT/langs/rust"

cd "$SRC"

# This box links against brew's glibc (the only one with crt objects), but the
# system runtime glibc is older — so freshly-built proc-macro/build-script
# binaries must load brew's loader + libc at runtime. Bake that into every link.
GLIBC_LIB="$(ls -d "$(brew --prefix)"/Cellar/glibc/*/lib 2>/dev/null | sort -V | tail -1)"
LOADER="$(ls "$GLIBC_LIB"/ld-linux-*.so.* 2>/dev/null | head -1)"
export RUSTFLAGS="-C link-arg=-Wl,-rpath,$GLIBC_LIB -C link-arg=-Wl,--dynamic-linker=$LOADER"

# Native build-script crates (ring, libc, ...) compile C/asm via the cc-rs
# crate, which otherwise hunts for /usr/bin/gcc. Point every C tool at the
# brew toolchain wrapper.
export CC="$ROOT/_build/tools/bin/cc" HOST_CC="$ROOT/_build/tools/bin/cc"
export CXX="$ROOT/_build/tools/bin/cc" HOST_CXX="$ROOT/_build/tools/bin/cc"
export AR="$(brew --prefix)/opt/binutils/bin/ar" HOST_AR="$(brew --prefix)/opt/binutils/bin/ar"

CARGO_TARGET_DIR="$ROOT/_build/out/rust-target" cargo doc --no-deps --quiet
rm -rf "$OUT"; mkdir -p "$OUT"
cp -a "$ROOT/_build/out/rust-target/doc/." "$OUT"/

# rustdoc emits no crate-root index; add the redirect the shell links to.
cat > "$OUT/index.html" <<'HTML'
<!doctype html>
<meta http-equiv="refresh" content="0; url=signalwire/index.html">
<title>SignalWire Rust SDK</title>
<a href="signalwire/index.html">Redirecting to signalwire crate…</a>
HTML
echo "rust -> $OUT ($(find "$OUT" -name '*.html' | wc -l) pages)"
