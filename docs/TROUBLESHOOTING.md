# Troubleshooting (Advanced)

## Codex stays at 99–100%
**Cause:** `rate_limits` not written yet.

**Fix:**
1. Run `codex` and type `/status` once.
2. Wait 2 minutes for cache refresh.
3. Ensure `CODEX_BIN` is correct in the script.

---

## Claude shows 0%
**Cause:** 5h usage is fully consumed.

**Fix:**
- Check weekly line (7d)
- Wait for reset time shown

---

## Antigravity shows ?
**Cause:** IDE not running or LSP not reachable.

**Fix:**
- Start Antigravity IDE
- Ensure `language_server_linux` is running

---

## Tooltip alignment off
**Cause:** Waybar font changes or CSS overrides.

**Fix:**
- Force monospaced font in `style.css` for `#custom-llm-usage`

---

## Waybar not updating
**Fix:**
- `pkill -USR2 waybar`
- Confirm `interval` in config.jsonc
- Test script manually

---

## Debug commands
```bash
~/.local/bin/waybar-llm-usage.sh
CODEX_BIN=~/.cache/.bun/bin/codex ~/.local/bin/codex-quota.py --json --fresh
```
