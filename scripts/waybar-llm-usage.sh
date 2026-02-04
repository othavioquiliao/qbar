#!/bin/bash
# LLM Usage Waybar Script — Claude + Codex + Antigravity

export PATH="$HOME/.cache/.bun/bin:$PATH"
export CODEX_BIN="$HOME/.cache/.bun/bin/codex"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Helpers ---
color_for() {
  local pct="$1"
  if [ "$pct" = "?" ]; then
    echo "#cdd6f4"
  elif [ "$pct" -ge 60 ] 2>/dev/null; then
    echo "#a6e3a1"
  elif [ "$pct" -ge 30 ] 2>/dev/null; then
    echo "#f9e2af"
  elif [ "$pct" -ge 10 ] 2>/dev/null; then
    echo "#fab387"
  else
    echo "#f38ba8"
  fi
}

fmt_span() {
  local label="$1"; local pct="$2"; local color
  color=$(color_for "$pct")
  echo "<span foreground='${color}'>${label} ${pct}%</span>"
}

bar_5pct() {
  local pct="$1"
  if [ "$pct" = "?" ]; then
    echo "░░░░░░░░░░░░░░░░░░░░"
    return
  fi
  local filled=$((pct / 5))
  local empty=$((20 - filled))
  local color
  color=$(color_for "$pct")
  local filled_str empty_str
  filled_str=$(printf "%0.s█" $(seq 1 $filled))
  empty_str=$(printf "%0.s░" $(seq 1 $empty))
  echo "<span foreground='${color}'>${filled_str}</span><span foreground='#6c7086'>${empty_str}</span>"
}

human_eta() {
  local iso="$1"
  if [ -z "$iso" ] || [ "$iso" = "?" ]; then
    echo "?"; return
  fi
  local now=$(date +%s)
  local ts=$(date -d "$iso" +%s 2>/dev/null)
  if [ -z "$ts" ]; then echo "?"; return; fi
  local diff=$((ts - now))
  if [ $diff -lt 0 ]; then echo "0m"; return; fi
  local h=$((diff / 3600))
  local m=$(((diff % 3600) / 60))
  if [ $h -gt 0 ]; then
    printf "%dh %dm" "$h" "$m"
  else
    printf "%dm" "$m"
  fi
}

# --- Claude (OAuth) ---
CLAUDE_CREDS="$HOME/.claude/.credentials.json"
C5_REM="?"; C5_RESET="?"; C5_RESET_ISO=""
C7_REM="?"; C7_RESET="?"; C7_RESET_ISO=""
C_PLAN="?"

if [ -f "$CLAUDE_CREDS" ]; then
  ACCESS_TOKEN=$(jq -r '.claudeAiOauth.accessToken // empty' "$CLAUDE_CREDS" 2>/dev/null)
  C_PLAN=$(jq -r '.claudeAiOauth.subscriptionType // "free"' "$CLAUDE_CREDS" 2>/dev/null)
  if [ -n "$ACCESS_TOKEN" ]; then
    USAGE=$(curl -s --max-time 5 "https://api.anthropic.com/api/oauth/usage" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "anthropic-beta: oauth-2025-04-20" 2>/dev/null)
    if echo "$USAGE" | jq -e '.five_hour' &>/dev/null; then
      C5_USED=$(echo "$USAGE" | jq -r '.five_hour.utilization // 0' | xargs printf "%.0f")
      C7_USED=$(echo "$USAGE" | jq -r '.seven_day.utilization // 0' | xargs printf "%.0f")
      C5_REM=$((100 - C5_USED))
      C7_REM=$((100 - C7_USED))
      C5_RESET_ISO=$(echo "$USAGE" | jq -r '.five_hour.resets_at // ""')
      C7_RESET_ISO=$(echo "$USAGE" | jq -r '.seven_day.resets_at // ""')
      [ -n "$C5_RESET_ISO" ] && C5_RESET=$(date -d "$C5_RESET_ISO" +"%H:%M" 2>/dev/null || echo "?")
      [ -n "$C7_RESET_ISO" ] && C7_RESET=$(date -d "$C7_RESET_ISO" +"%d/%m" 2>/dev/null || echo "?")
    fi
  fi
fi

# --- Codex (codex-quota) ---
X5_REM="?"; X5_RESET="?"; X5_RESET_ISO=""
X7_REM="?"; X7_RESET="?"; X7_RESET_ISO=""
CODEX_CACHE="/tmp/codex-quota.json"
CODEX_REFRESH_SEC=120

if [ ! -f "$CODEX_CACHE" ] || [ $(( $(date +%s) - $(stat -c %Y "$CODEX_CACHE" 2>/dev/null || echo 0) )) -gt $CODEX_REFRESH_SEC ]; then
  CODEX_JSON=$(python "$SCRIPT_DIR/codex-quota.py" --json --fresh 2>/dev/null)
  if echo "$CODEX_JSON" | jq -e '.primary' >/dev/null 2>&1; then
    echo "$CODEX_JSON" > "$CODEX_CACHE"
  else
    CODEX_JSON=""
  fi
fi

if [ -f "$CODEX_CACHE" ]; then
  CODEX_JSON=$(cat "$CODEX_CACHE")
fi

if [ -n "$CODEX_JSON" ]; then
  P_USED=$(echo "$CODEX_JSON" | jq -r '.primary.used_percent // 0' 2>/dev/null | xargs printf "%.0f")
  S_USED=$(echo "$CODEX_JSON" | jq -r '.secondary.used_percent // 0' 2>/dev/null | xargs printf "%.0f")
  X5_REM=$((100 - P_USED))
  X7_REM=$((100 - S_USED))
  X5_RESET_ISO=$(echo "$CODEX_JSON" | jq -r '.primary.resets_at // ""' 2>/dev/null)
  X7_RESET_ISO=$(echo "$CODEX_JSON" | jq -r '.secondary.resets_at // ""' 2>/dev/null)
  [ -n "$X5_RESET_ISO" ] && X5_RESET=$(date -d "$X5_RESET_ISO" +"%H:%M" 2>/dev/null || echo "?")
  [ -n "$X7_RESET_ISO" ] && X7_RESET=$(date -d "$X7_RESET_ISO" +"%d/%m" 2>/dev/null || echo "?")
fi

# --- Antigravity (LSP) ---
AG_CLAUDE="?"; AG_GEM_PRO="?"; AG_GEM_FLASH="?"
AG_CLAUDE_RESET="?"; AG_GEM_PRO_RESET="?"; AG_GEM_FLASH_RESET="?"
AG_CLAUDE_RESET_ISO=""; AG_GEM_PRO_RESET_ISO=""; AG_GEM_FLASH_RESET_ISO=""
AG_ACCOUNT="?"
AG_PROCESS=$(ps aux | grep "language_server_linux" | grep -v grep | head -1)
if [ -n "$AG_PROCESS" ]; then
  AG_CSRF=$(echo "$AG_PROCESS" | grep -oP '(?<=--csrf_token )[a-f0-9-]+')
  if [ -n "$AG_CSRF" ]; then
    for port in $(lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | grep "language_" | awk '{print $9}' | cut -d: -f2 | head -3); do
      AG_JSON=$(curl -sk --max-time 3 "https://127.0.0.1:$port/exa.language_server_pb.LanguageServerService/GetUserStatus" \
        -H "X-Codeium-Csrf-Token: $AG_CSRF" \
        -H "Connect-Protocol-Version: 1" \
        -H "Content-Type: application/json" \
        -d '{"metadata":{"ideName":"antigravity"}}' 2>/dev/null)
      if echo "$AG_JSON" | jq -e '.userStatus.email' &>/dev/null; then
        AG_ACCOUNT=$(echo "$AG_JSON" | jq -r '.userStatus.name // .userStatus.email' | cut -d' ' -f1)
        AG_CLAUDE=$(echo "$AG_JSON" | jq -r '[.userStatus.cascadeModelConfigData.clientModelConfigs[] | select(.label | test("Claude Opus.*Thinking"; "i")) | .quotaInfo.remainingFraction // 1] | .[0] * 100 | floor')
        AG_GEM_PRO=$(echo "$AG_JSON" | jq -r '[.userStatus.cascadeModelConfigData.clientModelConfigs[] | select(.label | test("Gemini 3 Pro.*High"; "i")) | .quotaInfo.remainingFraction // 1] | .[0] * 100 | floor')
        AG_GEM_FLASH=$(echo "$AG_JSON" | jq -r '[.userStatus.cascadeModelConfigData.clientModelConfigs[] | select(.label | test("Gemini 3 Flash"; "i")) | .quotaInfo.remainingFraction // 1] | .[0] * 100 | floor')
        AG_CLAUDE_RESET_ISO=$(echo "$AG_JSON" | jq -r '.userStatus.cascadeModelConfigData.clientModelConfigs[] | select(.label | test("Claude Opus.*Thinking"; "i")) | .quotaInfo.resetTime // ""' | head -1)
        AG_GEM_PRO_RESET_ISO=$(echo "$AG_JSON" | jq -r '.userStatus.cascadeModelConfigData.clientModelConfigs[] | select(.label | test("Gemini 3 Pro.*High"; "i")) | .quotaInfo.resetTime // ""' | head -1)
        AG_GEM_FLASH_RESET_ISO=$(echo "$AG_JSON" | jq -r '.userStatus.cascadeModelConfigData.clientModelConfigs[] | select(.label | test("Gemini 3 Flash"; "i")) | .quotaInfo.resetTime // ""' | head -1)
        [ -n "$AG_CLAUDE_RESET_ISO" ] && AG_CLAUDE_RESET=$(date -d "$AG_CLAUDE_RESET_ISO" +"%H:%M" 2>/dev/null || echo "?")
        [ -n "$AG_GEM_PRO_RESET_ISO" ] && AG_GEM_PRO_RESET=$(date -d "$AG_GEM_PRO_RESET_ISO" +"%H:%M" 2>/dev/null || echo "?")
        [ -n "$AG_GEM_FLASH_RESET_ISO" ] && AG_GEM_FLASH_RESET=$(date -d "$AG_GEM_FLASH_RESET_ISO" +"%H:%M" 2>/dev/null || echo "?")
        break
      fi
    done
  fi
fi

# --- Bar Text ---
Cld=$(fmt_span "Cld" "$C5_REM")
Cdx=$(fmt_span "Cdx" "$X5_REM")
AG=$(fmt_span "AG" "$AG_CLAUDE")
SEP="<span weight='bold'>·</span>"
TEXT="| ${Cld} ${SEP} ${Cdx} ${SEP} ${AG} |"

# --- Tooltip ---
line_fmt() {
  local label="$1"; local pct="$2"; local reset_iso="$3"; local reset_hm="$4"
  local bar eta
  bar=$(bar_5pct "$pct")
  eta=$(human_eta "$reset_iso")
  printf "%-16s %s - %3s%% - %-7s (%s)" "$label" "$bar" "$pct" "$eta" "$reset_hm"
}

T="━━━ Claude (${C_PLAN}) ━━━\\n"
T+="$(line_fmt "Claude 4.5 Opus" "$C5_REM" "$C5_RESET_ISO" "$C5_RESET")\\n"
T+="$(line_fmt "Weekly" "$C7_REM" "$C7_RESET_ISO" "$C7_RESET")\\n"

T+="\\n━━━ Codex ━━━\\n"
T+="$(line_fmt "Codex 5h" "$X5_REM" "$X5_RESET_ISO" "$X5_RESET")\\n"
T+="$(line_fmt "Codex 7d" "$X7_REM" "$X7_RESET_ISO" "$X7_RESET")\\n"

if [ "$AG_ACCOUNT" != "?" ]; then
  T+="\\n━━━ Antigravity (${AG_ACCOUNT}) ━━━\\n"
  T+="$(line_fmt "Claude Opus" "$AG_CLAUDE" "$AG_CLAUDE_RESET_ISO" "$AG_CLAUDE_RESET")\\n"
  T+="$(line_fmt "Gemini Pro" "$AG_GEM_PRO" "$AG_GEM_PRO_RESET_ISO" "$AG_GEM_PRO_RESET")\\n"
  T+="$(line_fmt "Gemini Flash" "$AG_GEM_FLASH" "$AG_GEM_FLASH_RESET_ISO" "$AG_GEM_FLASH_RESET")"
fi

echo "{\"text\": \"$TEXT\", \"tooltip\": \"$T\", \"class\": \"codexbar\"}"
