# LLM Usage Waybar (Claude + Codex + Antigravity)

Waybar module that shows **Claude Code**, **Codex**, and **Antigravity** quotas in Omarchy/Waybar.

---

## Install (choose one)

### ✅ Manual (copy scripts)
- Best for one‑off installs
- Guide: `docs/SETUP_MANUAL.md`

### ✅ Symlink (clone + link)
- Best if you want easy updates
- Guide: `docs/SETUP_SYMLINK.md`

---

## Prerequisites

See: `docs/PREREQS.md`

---

## What you get

- Bar: `| Cld XX% · Cdx YY% · AG ZZ% |`
- Hover tooltip with aligned block bars, ETA, and reset time
- Login menu + Logout menu

---

## Key scripts

- `scripts/waybar-llm-usage.sh` — renders bar + tooltip
- `scripts/codex-quota.py` — codex quota fetcher (local)
- `scripts/llm-usage-menu` — login + logout menu
- `scripts/llm-usage-logout` — provider logout submenu
- `scripts/llm-usage-details` — terminal details view
- `scripts/antigravity-waybar-usage-login`
- `scripts/antigravity-waybar-usage-fetch`

---

## Troubleshooting

See: `docs/TROUBLESHOOTING.md`
