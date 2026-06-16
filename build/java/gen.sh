#!/usr/bin/env bash
# Java pane: Javadoc via the Gradle wrapper (resolves the dependency classpath).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC="$ROOT/_build/sdks/signalwire-java"
OUT="$ROOT/langs/java"

cd "$SRC"
./gradlew --quiet --no-daemon javadoc \
  -Dorg.gradle.jvmargs="-Xmx1g" || true

rm -rf "$OUT"; mkdir -p "$OUT"
cp -a build/docs/javadoc/. "$OUT"/
echo "java -> $OUT ($(find "$OUT" -name '*.html' | wc -l) pages)"
