# Troubleshooting

## Claude login doesn’t update Waybar
- The login menu watches `~/.claude/.credentials.json`
- If it doesn’t update, run:
```bash
pkill -USR2 waybar
```

## Codex logout still shows
- Codex output is cached in `/tmp/codex-quota.json`
- Logout removes it, but if it persists:
```bash
rm -f /tmp/codex-quota.json
pkill -USR2 waybar
```

## Antigravity missing
- If IDE is closed, Cloud fallback must be logged in
```bash
~/.config/waybar/scripts/antigravity-waybar-usage-login
```

## Tooltip alignment off
- Your Waybar font may be proportional
- Use a monospaced font in your own CSS if needed
