#!/usr/bin/env bash
set -euo pipefail

echo "Logging out Codex..."
rm -rf "$HOME/.codex"
pkill -USR2 waybar || true

echo "Codex logout complete."
