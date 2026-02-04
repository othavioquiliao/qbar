#!/usr/bin/env bash
set -euo pipefail

echo "Logging out Claude..."
rm -f "$HOME/.claude/.credentials.json"
rm -rf "$HOME/.claude/cache" "$HOME/.claude/ide" "$HOME/.claude/debug" "$HOME/.claude/todos" "$HOME/.claude/projects" "$HOME/.claude/plugins" 2>/dev/null || true
pkill -USR2 waybar || true

echo "Claude logout complete."
