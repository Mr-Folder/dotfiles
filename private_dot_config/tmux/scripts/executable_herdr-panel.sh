#!/usr/bin/env bash
# Herdr agent status popup for tmux (M-i): lists agents from the herdr
# server with their state (idle/working/blocked). Any key closes it.

out=$(herdr agent list 2>/dev/null)
n=$(printf '%s' "$out" | jq '.result.agents | length' 2>/dev/null)

printf '\n \033[1mAGENTS\033[0m\n\n'
if [ -z "$n" ]; then
  printf '  herdr server not running\n'
elif [ "$n" -eq 0 ]; then
  printf '  (no agents)\n'
else
  printf '%s' "$out" | jq -r '.result.agents[] | [.agent_status, .agent, .cwd] | @tsv' |
  while IFS=$'\t' read -r status agent cwd; do
    case "$status" in
      working) icon="⏳"; c=$'\033[33m'   ;;
      blocked) icon="🔔"; c=$'\033[1;31m' ;;
      idle)    icon="✅"; c=$'\033[32m'   ;;
      *)       icon="· "; c=$'\033[2m'    ;;
    esac
    printf ' %s %b%-8s\033[0m %-8s %s\n' "$icon" "$c" "$status" "$agent" "$(basename "$cwd")"
  done
fi
printf '\n \033[2many key to close\033[0m'
read -r -n1 -s
