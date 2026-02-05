# LLM Usage Waybar (Claude + Codex + Antigravity)

This repo documents how to reproduce the Waybar module that shows **Claude Code**, **Codex**, and **Antigravity** quotas in Omarchy/Waybar.

**Scope:** Documentation + scripts only

---

## What You Get

- A Waybar module that shows current % remaining for:
  - Claude (Anthropic OAuth)
  - Codex (Codex CLI logs via `codex-quota.py`)
  - Antigravity (local LSP probe)
- A rich tooltip with:
  - 5h + 7d limits for Claude/Codex
  - Reset ETA + exact reset time
  - Antigravity per-model quotas
- A clean, aligned hover layout with **Catppuccin** colors

---

## Prerequisites (REQUIRED)

**System:** Linux + Waybar (Omarchy or similar)

### Core dependencies

- `bash`
- `jq`
- `curl`
- `python3`
- `lsof`
- `expect` (for automated Claude login)

### Claude Code

- `claude` CLI installed
- Logged in (OAuth tokens in `~/.claude/.credentials.json`)

### Codex CLI

- `codex` CLI installed
- Logged in (ChatGPT OAuth or API key)
- CLI binary available (example path: `~/.cache/.bun/bin/codex`)

### Antigravity

- Antigravity IDE installed
- Antigravity IDE running (language server must be active)
- Optional Cloud fallback: `npm i -g antigravity-usage` + `antigravity-waybar-usage-login`

---

## Quick Start (Human)

1. Copy the scripts:
  - `scripts/waybar-llm-usage.sh` → `~/.config/waybar/scripts/waybar-llm-usage.sh`
  - `scripts/codex-quota.py` → `~/.config/waybar/scripts/codex-quota.py`
  - `scripts/antigravity-waybar-usage-login` → `~/.config/waybar/scripts/antigravity-waybar-usage-login`
  - `scripts/antigravity-waybar-usage-fetch` → `~/.config/waybar/scripts/antigravity-waybar-usage-fetch`
  - `chmod +x ~/.config/waybar/scripts/waybar-llm-usage.sh`
  - `chmod +x ~/.config/waybar/scripts/codex-quota.py`
  - `chmod +x ~/.config/waybar/scripts/antigravity-waybar-usage-login`
  - `chmod +x ~/.config/waybar/scripts/antigravity-waybar-usage-fetch`
2. Add Waybar config snippet:
  - Append the block from `snippets/waybar-config.jsonc` into your `~/.config/waybar/config.jsonc`
3. Add CSS snippet:
  - Append the block from `snippets/waybar-style.css` into `~/.config/waybar/style.css`
4. Reload Waybar:
  - `pkill -USR2 waybar`

---

## Files

- `scripts/waybar-llm-usage.sh`
- `scripts/codex-quota.py`
- `scripts/antigravity-waybar-usage-login`
- `scripts/antigravity-waybar-usage-fetch`
- `scripts/llm-usage-menu` (right-click menu for login + auto-install)
- `snippets/waybar-config.jsonc`
- `snippets/waybar-style.css`
- `docs/AGENTS_GUIDE.md` (for agents)
- `docs/PREREQS.md`
- `docs/TROUBLESHOOTING.md`
- `docs/ANTIGRAVITY_MANAGER.md`
- `SETUP.md`

---

## Troubleshooting

### Codex stays at 99–100%

- The script uses `codex-quota.py --fresh` and caches for 2 minutes.
- If it looks stuck:
  - Run `codex` in a terminal and issue `/status` once.
  - Then wait 2 minutes for the cache refresh.
- Ensure `CODEX_BIN` points to your `codex` binary.

### Claude shows 0%

- This is correct when 5h usage is fully consumed.
- The 7d line still shows weekly remaining.

### Antigravity shows ?

- Ensure the Antigravity IDE is running.
- The script probes the local LSP; it won’t work if the IDE is closed.

