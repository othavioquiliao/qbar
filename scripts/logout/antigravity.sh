#!/usr/bin/env bash
set -euo pipefail

echo "Logging out Antigravity..."
rm -rf "$HOME/.config/antigravity-usage"
pkill -USR2 waybar || true

echo "Antigravity logout complete."
