#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"' | sed 's/ ([^)]*context[^)]*)//; s/ [0-9]*[KkMm] context//')
IN=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUT=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
[ "$PCT" -gt 100 ] 2>/dev/null && PCT=100
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0' | xargs printf '%.2f')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

# Rate limits
FIVE_HOUR=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
WEEKLY=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Format session duration as minutes
DURATION_MIN=$(( DURATION_MS / 60000 ))

# Colors
RST='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
ORANGE='\033[38;5;208m'

# Build output
OUT_STR="${BOLD}${ORANGE}${MODEL}${RST}"
OUT_STR="$OUT_STR ${DIM}│${RST} ${RED}${IN}↑${RST} ${DIM}input${RST} ${DIM}│${RST} ${GREEN}${OUT}↓${RST} ${DIM}output${RST}"
OUT_STR="$OUT_STR ${DIM}│${RST} ${BLUE}${PCT}%${RST} ${DIM}context${RST}"
OUT_STR="$OUT_STR ${DIM}│${RST} ${YELLOW}\$${COST}${RST} ${DIM}in ${DURATION_MIN}min${RST}"

# Append rate limits if available
if [ -n "$FIVE_HOUR" ]; then
  FIVE_HOUR_INT=$(printf '%.0f' "$FIVE_HOUR")
  [ "$FIVE_HOUR_INT" -gt 100 ] 2>/dev/null && FIVE_HOUR_INT=100
  FIVE_HOUR_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
  if [ -n "$FIVE_HOUR_RESET" ]; then
    RESET_TIME=$(date -r "$FIVE_HOUR_RESET" '+%H:%M')
    OUT_STR="$OUT_STR ${DIM}│${RST} ${ORANGE}5h: ${FIVE_HOUR_INT}%${RST} ${DIM}(${RESET_TIME})${RST}"
  else
    OUT_STR="$OUT_STR ${DIM}│${RST} ${ORANGE}5h: ${FIVE_HOUR_INT}%${RST}"
  fi
fi
if [ -n "$WEEKLY" ]; then
  WEEKLY_INT=$(printf '%.0f' "$WEEKLY")
  [ "$WEEKLY_INT" -gt 100 ] 2>/dev/null && WEEKLY_INT=100
  WEEKLY_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
  if [ -n "$WEEKLY_RESET" ]; then
    WEEKLY_RESET_TIME=$(date -r "$WEEKLY_RESET" '+%a %H:%M')
    OUT_STR="$OUT_STR ${DIM}│${RST} ${RED}7d: ${WEEKLY_INT}%${RST} ${DIM}(${WEEKLY_RESET_TIME})${RST}"
  else
    OUT_STR="$OUT_STR ${DIM}│${RST} ${RED}7d: ${WEEKLY_INT}%${RST}"
  fi
fi

# Append logged-in email
EMAIL=$(claude auth status 2>/dev/null | jq -r '.email // empty' 2>/dev/null)
if [ -n "$EMAIL" ]; then
  OUT_STR="$OUT_STR ${DIM}│${RST} ${DIM}${EMAIL}${RST}"
fi

echo -e "$OUT_STR"
