# Setup — Step by Step (Human)

This is the safest, most detailed manual setup.

---

## 1) Verify prerequisites

Use `docs/PREREQS.md` and confirm each item:
- `claude` CLI logged in
- `codex` CLI logged in
- Antigravity IDE running
- `jq`, `curl`, `python3`, `lsof` installed
- Optional: `npm i -g antigravity-usage` + `antigravity-waybar-usage-login`

---

## 2) Copy scripts

```bash
mkdir -p ~/.config/waybar/scripts
cp scripts/waybar-llm-usage.sh ~/.config/waybar/scripts/waybar-llm-usage.sh
cp scripts/codex-quota.py ~/.config/waybar/scripts/codex-quota.py
cp scripts/antigravity-waybar-usage-login ~/.config/waybar/scripts/antigravity-waybar-usage-login
cp scripts/antigravity-waybar-usage-fetch ~/.config/waybar/scripts/antigravity-waybar-usage-fetch
cp scripts/llm-usage-menu ~/.config/waybar/scripts/llm-usage-menu
chmod +x ~/.config/waybar/scripts/waybar-llm-usage.sh
chmod +x ~/.config/waybar/scripts/codex-quota.py
chmod +x ~/.config/waybar/scripts/antigravity-waybar-usage-login
chmod +x ~/.config/waybar/scripts/antigravity-waybar-usage-fetch
chmod +x ~/.config/waybar/scripts/llm-usage-menu
```

---

## 3) Update Waybar config

Open `~/.config/waybar/config.jsonc` and add:
```jsonc
// Add to modules-right (example)
"modules-right": [
  ..., "custom/llm-usage"
],

"custom/llm-usage": {
  "format": "{}",
  "exec": "$HOME/.config/waybar/scripts/waybar-llm-usage.sh",
  "return-type": "json",
  "interval": 60,
  "markup": "pango",
  "on-click-right": "$HOME/.config/waybar/scripts/llm-usage-menu"
}
```

---

## 4) Update Waybar CSS

Append this to `~/.config/waybar/style.css`:
```css
#custom-llm-usage {
  margin-left: 10px;
  margin-right: 10px;
  font-weight: 500;
}

#custom-llm-usage span {
  padding: 0 2px;
}
```

---

## 5) Reload Waybar

```bash
pkill -USR2 waybar
```

---

## 6) Validate output

Run manually:
```bash
~/.config/waybar/scripts/waybar-llm-usage.sh
```

Expected:
- Bar: `| Cld XX% · Cdx YY% · AG ZZ% |`
- Hover: aligned block bars, ETA + reset time
