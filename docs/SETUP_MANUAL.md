# Setup — Manual (Copy Scripts)

## ✅ Human (step‑by‑step)

### 1) Verify prerequisites
See `docs/PREREQS.md`.

### 2) Copy scripts
```bash
mkdir -p ~/.config/waybar/scripts
cp scripts/waybar-llm-usage.sh ~/.config/waybar/scripts/waybar-llm-usage.sh
cp scripts/codex-quota.py ~/.config/waybar/scripts/codex-quota.py
cp scripts/antigravity-waybar-usage-login ~/.config/waybar/scripts/antigravity-waybar-usage-login
cp scripts/antigravity-waybar-usage-fetch ~/.config/waybar/scripts/antigravity-waybar-usage-fetch
cp scripts/llm-usage-menu ~/.config/waybar/scripts/llm-usage-menu
cp scripts/llm-usage-logout ~/.config/waybar/scripts/llm-usage-logout
cp scripts/llm-usage-details ~/.config/waybar/scripts/llm-usage-details
cp scripts/llm-usage-open-terminal ~/.config/waybar/scripts/llm-usage-open-terminal
cp -r scripts/logout ~/.config/waybar/scripts/
chmod +x ~/.config/waybar/scripts/*
chmod +x ~/.config/waybar/scripts/logout/*.sh
```

### 3) Update Waybar config
Append `snippets/waybar-config.jsonc` into `~/.config/waybar/config.jsonc`.

### 4) Update Waybar CSS
Append `snippets/waybar-style.css` into `~/.config/waybar/style.css`.

### 5) Reload Waybar
```bash
pkill -USR2 waybar
```

---

## 🤖 Agent (step‑by‑step)

### 1) Verify prerequisites
Check `docs/PREREQS.md`.

### 2) Copy scripts (with backup)
```bash
mkdir -p ~/.config/waybar/scripts
cp -a scripts/waybar-llm-usage.sh ~/.config/waybar/scripts/
cp -a scripts/codex-quota.py ~/.config/waybar/scripts/
cp -a scripts/antigravity-waybar-usage-login ~/.config/waybar/scripts/
cp -a scripts/antigravity-waybar-usage-fetch ~/.config/waybar/scripts/
cp -a scripts/llm-usage-menu ~/.config/waybar/scripts/
cp -a scripts/llm-usage-logout ~/.config/waybar/scripts/
cp -a scripts/llm-usage-details ~/.config/waybar/scripts/
cp -a scripts/llm-usage-open-terminal ~/.config/waybar/scripts/
cp -a scripts/logout ~/.config/waybar/scripts/
chmod +x ~/.config/waybar/scripts/*
chmod +x ~/.config/waybar/scripts/logout/*.sh
```

### 3) Inject config + CSS
- Append `snippets/waybar-config.jsonc`
- Append `snippets/waybar-style.css`

### 4) Reload Waybar
```bash
pkill -USR2 waybar
```

### 5) Validate
```bash
~/.config/waybar/scripts/waybar-llm-usage.sh
```
Expected:
- Bar renders correctly
- Tooltip aligned
