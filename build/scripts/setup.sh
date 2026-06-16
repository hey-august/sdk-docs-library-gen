#!/usr/bin/env bash
# Install the doc generators into the runtimes mise provides, plus the few
# tools that don't come from a mise runtime. Idempotent.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOLS="$ROOT/_build/tools"
BREW="$(brew --prefix)"
mkdir -p "$TOOLS/bin"

# This container has no working C toolchain on PATH: no `cc`/`gcc`, and gcc
# can't find glibc's crt objects. Build a self-contained `cc`/`gcc` wrapper
# around brew's gcc that puts binutils (as/ld) on PATH and points LIBRARY_PATH
# at brew's glibc. cargo/rustc and native gem/pip builds use `cc` as the linker.
brew list --formula 2>/dev/null | grep -qx binutils || brew install binutils
GCC_BIN="$(ls "$BREW/bin"/gcc-[0-9]* 2>/dev/null | grep -E 'gcc-[0-9]+$' | sort -V | tail -1)"
GLIBC_DIR="$(ls -d "$BREW"/Cellar/glibc/*/ 2>/dev/null | sort -V | tail -1)"
BINUTILS_BIN="$BREW/opt/binutils/bin"
if [ -n "$GCC_BIN" ] && [ -n "$GLIBC_DIR" ]; then
  cat > "$TOOLS/bin/cc" <<EOF
#!/bin/sh
# brew gcc + binutils, with brew glibc's headers/libs (the system has no
# libc-dev). LIBRARY_PATH supplies crt*.o; CPATH satisfies gcc's #include_next.
export PATH="$BINUTILS_BIN:\$PATH"
export LIBRARY_PATH="${GLIBC_DIR}lib\${LIBRARY_PATH:+:\$LIBRARY_PATH}"
export CPATH="${GLIBC_DIR}include\${CPATH:+:\$CPATH}"
exec "$GCC_BIN" "\$@"
EOF
  chmod +x "$TOOLS/bin/cc"
  ln -sf cc "$TOOLS/bin/gcc"
fi

# TypeScript: typedoc is pulled per-run via npx (see build/typescript/gen.sh).

# Python: mkdocs-material + mkdocstrings (Python pane), plus markdown + pygments
# (used by the Go pane to render gomarkdoc output into the styled HTML shell).
pip install -q --upgrade mkdocs-material "mkdocstrings[python]" markdown pygments markdown-it-py

# Ruby: yard. (Ruby itself comes from brew — the container can't compile it.)
gem install --no-document yard

# Go: gomarkdoc, installed into the on-PATH shim dir for a predictable location.
GOBIN="$TOOLS/bin" go install github.com/princjef/gomarkdoc/cmd/gomarkdoc@latest

# Rust: rustdoc ships with the rust toolchain (brew). Nothing to install.

# Java: javadoc ships with the JDK (mise temurin). Nothing to install.

# C++ / PHP: doxygen from brew (no Linux/arm64 release binary upstream).
command -v doxygen >/dev/null 2>&1 || brew install doxygen
# Fetch the doxygen-awesome theme.
if [ ! -d "$TOOLS/doxygen-awesome-css" ]; then
  git clone -q --depth 1 https://github.com/jothepro/doxygen-awesome-css.git \
    "$TOOLS/doxygen-awesome-css"
fi

# .NET: docfx as a local dotnet tool (requires the .NET SDK on PATH).
if command -v dotnet >/dev/null 2>&1; then
  dotnet tool install --global docfx 2>/dev/null || dotnet tool update --global docfx
fi

# Perl: Pod::Simple ships with core perl. Nothing to install.

# Minimal fontconfig file for headless rendering (see project memory).
cat > "$TOOLS/fonts.conf" <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>/home/linuxbrew/.linuxbrew/share/fonts</dir>
  <dir prefix="xdg">fonts</dir>
  <cachedir prefix="xdg">fontconfig</cachedir>
</fontconfig>
EOF

echo "setup complete"
