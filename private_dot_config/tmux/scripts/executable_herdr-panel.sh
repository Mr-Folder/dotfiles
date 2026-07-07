#!/usr/bin/env bash
# Herdr agent picker for tmux (M-i, runs inside a display-popup).
# fzf list of agents (blocked > working > idle) with a live preview of
# each agent's screen. Enter focuses the agent in herdr and opens the
# floating claude session (where herdr lives); Esc just closes.

CLAUDE_SESSION="claude"

out=$(herdr agent list 2>/dev/null)
n=$(printf '%s' "$out" | jq '.result.agents | length' 2>/dev/null)

if [ -z "$n" ]; then
  printf '\n  herdr server not running\n'
  read -r -n1 -s
  exit 0
elif [ "$n" -eq 0 ]; then
  printf '\n  (no agents)\n'
  read -r -n1 -s
  exit 0
fi

rows=$(printf '%s' "$out" | jq -r '
  .result.agents
  | sort_by({"blocked":0,"working":1,"idle":2}[.agent_status] // 3)
  | .[] | [.agent_status, .agent, (.cwd | split("/") | last), .terminal_id] | @tsv')

lines=""
while IFS=$'\t' read -r status agent project id; do
  case "$status" in
    working) icon="⏳"; c=$'\033[33m'   ;;
    blocked) icon="🔔"; c=$'\033[1;31m' ;;
    idle)    icon="✅"; c=$'\033[32m'   ;;
    *)       icon="· "; c=$'\033[2m'    ;;
  esac
  lines+=$(printf '%s %b%-8s\033[0m %-8s %s\t%s' "$icon" "$c" "$status" "$agent" "$project" "$id")$'\n'
done <<< "$rows"

sel=$(printf '%s' "$lines" | fzf --ansi --delimiter=$'\t' --with-nth=1 \
      --prompt='agent> ' --no-info --height=100% --reverse \
      --preview 'herdr agent read {2} --source visible --format ansi 2>/dev/null | jq -r ".result.read.text"' \
      --preview-window='right,55%')
[ -z "$sel" ] && exit 0

id=${sel##*$'\t'}
herdr agent focus "$id" >/dev/null 2>&1

# Jump into the floating claude session once this popup has closed
client=$(tmux display-message -p '#{client_name}')
[ -z "$client" ] && client=$(tmux list-clients -F '#{client_name}' | head -1)
if ! tmux has-session -t "$CLAUDE_SESSION" 2>/dev/null; then
  tmux new-session -d -s "$CLAUDE_SESSION"
  tmux set-option -t "$CLAUDE_SESSION" status off
fi
setsid sh -c "sleep 0.15; tmux popup -c '$client' -S fg=colour45 -T ' claude ' -w 100% -h 100% -b rounded -E 'tmux attach-session -t $CLAUDE_SESSION'" >/dev/null 2>&1 &
exit 0
