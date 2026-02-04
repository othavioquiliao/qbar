# AGENTS GUIDE — LLM Usage Waybar

This guide is for autonomous agents implementing the setup safely and repeatably.

## Goal
Implement a Waybar module that shows usage for:
- Claude (Anthropic OAuth)
- Codex (CLI logs via codex-quota)
- Antigravity (local LSP)

## Important Safety Notes
- Do **not** overwrite user config without backup.
- Always show diffs before editing `~/.config/waybar/config.jsonc` and `~/.config/waybar/style.css`.
- Do not run external installers.

---

## Step 0 — Verify prerequisites
Use `docs/PREREQS.md`. Confirm:
- `claude` CLI logged in
- `codex` CLI logged in
- Antigravity IDE running
- `jq`, `curl`, `lsof`, `python3` installed

---

## Step 1 — Place the script
Copy:
- `scripts/waybar-llm-usage.sh` → `~/.config/waybar/scripts/waybar-llm-usage.sh`
- `scripts/codex-quota.py` → `~/.config/waybar/scripts/codex-quota.py`
- `chmod +x ~/.config/waybar/scripts/waybar-llm-usage.sh`
- `chmod +x ~/.config/waybar/scripts/codex-quota.py`

---

## Step 2 — Inject Waybar config
Append `snippets/waybar-config.jsonc` into the user’s `~/.config/waybar/config.jsonc`.

Key requirements:
- `custom/llm-usage` module configured
- `markup: "pango"` enabled
- `interval: 60` (or as requested)

---

## Step 3 — Inject CSS
Append `snippets/waybar-style.css` into `~/.config/waybar/style.css`.

Ensure:
- `.custom-llm-usage` styles are present
- No conflicting selectors override them

---

## Step 4 — Reload Waybar
`pkill -USR2 waybar`

---

## Step 5 — Validate outputs
Run:
- `~/.config/waybar/scripts/waybar-llm-usage.sh`

Confirm:
- Bar text: `| Cld xx% · Cdx yy% · AG zz% |`
- Tooltip lines aligned with block bars
- Reset times show (ETA + HH:MM)

---

## Step 6 — Codex refresh behavior
The script uses `codex-quota.py --fresh` and caches to `/tmp/codex-quota.json`.
If Codex looks stuck at 99–100%:
- Run `codex` and issue `/status` once
- Wait 2 minutes for refresh

---

## Failure Handling
If any provider fails:
- Preserve `?` and do not crash
- Do not delete files
- Print logs only in stderr
