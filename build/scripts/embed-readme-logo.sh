#!/usr/bin/env bash
# The SDK READMEs head with a GitHub user-attachments logo URL that 404s outside
# github.com. Rewrite it to the committed local SignalWire wordmark in a
# generated pane's HTML. Root-relative so it resolves from any pane (served at /).
set -euo pipefail

PANE="$1"
DEAD="https://github.com/user-attachments/assets/0c8ed3b9-8c50-4dc6-9cc4-cc6cd137fd50"
LOGO="/assets/img/signalwire-wordmark.png"

grep -rl "$DEAD" "$PANE" 2>/dev/null | while read -r f; do
  sed -i "s#$DEAD#$LOGO#g" "$f"
done
