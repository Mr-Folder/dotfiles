#!/usr/bin/env bash
# Claude session side panel for tmux.
#   claude-panel.sh          render loop (run inside a pane)
#   claude-panel.sh toggle   open/close the panel in the current window
# State comes from ~/.cache/claude-status/, written by claude-notify.sh hooks.

STATUS_DIR="$HOME/.cache/claude-status"
PANEL_WIDTH=46

if [ "$1" = "toggle" ]; then
  pane=$(tmux list-panes -F '#{pane_id} #{pane_start_command}' | awk '/claude-panel/{print $1; exit}')
  if [ -n "$pane" ]; then
    tmux kill-pane -t "$pane"
  else
    tmux split-window -h -l "$PANEL_WIDTH" -d "exec $0"
  fi
  exit 0
fi

human_age() {
  local s=$1
  if   [ "$s" -lt 60 ];   then echo "${s}s"
  elif [ "$s" -lt 3600 ]; then echo "$((s/60))m"
  else echo "$((s/3600))h"
  fi
}

while true; do
  now=$(date +%s)
  out=" \033[1mCLAUDE SESSIONS\033[0m\n"
  out+=" \033[2m   project          where       age\033[0m\n"
  found=0
  for f in "$STATUS_DIR"/*; do
    [ -f "$f" ] || continue
    IFS=$'\t' read -r ts state project pane < "$f"
    age=$((now - ts))
    # sessions silent for a day are gone
    [ "$age" -gt 86400 ] && { rm -f "$f"; continue; }
    case "$state" in
      working) icon="⏳"; colour='\033[33m' ;;
      waiting) icon="🔔"; colour='\033[1;31m' ;;
      idle)    icon="✅"; colour='\033[32m' ;;
      *)       icon="· "; colour='\033[0m' ;;
    esac
    loc=""
    if [ -n "$pane" ]; then
      loc=$(tmux display-message -p -t "$pane" '#{session_name}:#{window_index}' 2>/dev/null)
    fi
    line=$(printf ' %s %-16.16s %-10.10s %4s' "$icon" "$project" "${loc:--}" "$(human_age "$age")")
    out+="${colour}${line}\033[0m\n"
    found=1
  done
  [ "$found" -eq 0 ] && out+="\n  (no active sessions)\n"
  clear
  printf "%b" "$out"
  [ -n "$CLAUDE_PANEL_ONCE" ] && exit 0
  sleep 2
done
