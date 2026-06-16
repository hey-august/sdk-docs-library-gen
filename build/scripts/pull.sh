#!/usr/bin/env bash
# Clone-or-pull every SDK source listed in sdks.tsv into _build/sdks/.
# Idempotent: clones if missing, otherwise fetches + fast-forwards the default branch.
# Sources are gitignored; only the configs under build/ are committed.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SDK_DIR="$ROOT/_build/sdks"
MANIFEST="$ROOT/build/scripts/sdks.tsv"
mkdir -p "$SDK_DIR"

# Only clone repos named on the command line, or all if none given.
want=("$@")

grep -vE '^\s*#|^\s*$' "$MANIFEST" | while IFS=$'\t' read -r lang repo gen; do
  if [ "${#want[@]}" -gt 0 ] && ! printf '%s\n' "${want[@]}" | grep -qx "$lang"; then
    continue
  fi
  dest="$SDK_DIR/$repo"
  url="https://github.com/signalwire/$repo.git"
  if [ -d "$dest/.git" ]; then
    echo ">>> $lang: pulling $repo"
    git -C "$dest" remote set-url origin "$url"   # force HTTPS
    branch="$(git -C "$dest" symbolic-ref --short HEAD 2>/dev/null || echo main)"
    GIT_TERMINAL_PROMPT=0 git -C "$dest" fetch -q origin "$branch"
    git -C "$dest" merge -q --ff-only "origin/$branch" || {
      echo "    ! local diverged from origin/$branch; leaving as-is" >&2
    }
  else
    echo ">>> $lang: cloning $repo"
    GIT_TERMINAL_PROMPT=0 git clone -q "$url" "$dest"
  fi
  git -C "$dest" --no-pager log -1 --format='    %h %ci %s'
done
