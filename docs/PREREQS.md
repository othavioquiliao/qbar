# Prerequisites Checklist

## System
- Linux + Waybar installed
- `jq`, `curl`, `python3`, `lsof` installed

## Claude Code (Anthropic)
- `claude` CLI installed
- Logged in (OAuth tokens present)
  - File: `~/.claude/.credentials.json`
  - Required scope: `user:profile`

## Codex CLI (OpenAI)
- `codex` CLI installed (via npm or bun)
- Logged in with ChatGPT OAuth or API key
- Binary path known (example): `~/.cache/.bun/bin/codex`
- Logs exist under `~/.codex/sessions/`

## Antigravity
- Antigravity IDE installed
- Antigravity IDE **running** (language server active)

## Optional (Quality)
- Catppuccin theme installed (for visual consistency)
