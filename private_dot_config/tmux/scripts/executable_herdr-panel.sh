#!/usr/bin/env bash
# Herdr agent picker for tmux (M-i, runs inside a display-popup).
# fzf list of agents (blocked > working > idle) with a live-refreshing
# preview of each agent's screen; list and preview reload every 2s.
# Enter focuses the agent in herdr and opens the floating claude
# session (starting herdr in it if needed); Esc or M-i again closes.

CLAUDE_SESSION="claude"

# "list" mode: one ansi line per agent (used at start and on each reload)
if [ "$1" = "list" ]; then
  herdr agent list 2>/dev/null | jq -r '
    .result.agents
    | sort_by({"blocked":0,"working":1,"idle":2}[.agent_status] // 3)
    | .[] | [.agent_status, .agent, (.cwd | split("/") | last), .terminal_id] | @tsv' |
  while IFS=$'\t' read -r status agent project id; do
    case "$status" in
      working) icon="⏳"; c=$'\033[33m'   ;;
      blocked) icon="🔔"; c=$'\033[1;31m' ;;
      idle)    icon="✅"; c=$'\033[32m'   ;;
      *)       icon="· "; c=$'\033[2m'    ;;
    esac
    printf '%s %b%-8s\033[0m %-8s %s\t%s\n' "$icon" "$c" "$status" "$agent" "$project" "$id"
  done
  exit 0
fi

initial=$("$0" list)
if [ -z "$initial" ]; then
  printf '\n  no agents (is herdr running?)\n'
  read -r -n1 -s
  exit 0
fi

# background ticker: reload the list and refresh the preview every 2s
sock=$(mktemp -u "${TMPDIR:-/tmp}/herdr-panel-XXXXXX.sock")
( while sleep 2; do
    curl -s --unix-socket "$sock" -X POST -d "reload($0 list)+refresh-preview" \
      http://localhost/ >/dev/null 2>&1
  done ) &
ticker=$!
trap 'kill $ticker 2>/dev/null; rm -f "$sock"' EXIT

sel=$(printf '%s\n' "$initial" | fzf --ansi --delimiter=$'\t' --with-nth=1 \
      --prompt='agent> ' --no-info --height=100% --reverse \
      --listen-unsafe="$sock" \
      --bind 'alt-i:abort' \
      --preview 'herdr agent read {2} --source visible --format ansi 2>/dev/null | jq -r ".result.read.text"' \
      --preview-window='right,55%')
[ -z "$sel" ] && exit 0
id=${sel##*$'\t'}

# make sure herdr is actually running inside the floating session
if tmux has-session -t "$CLAUDE_SESSION" 2>/dev/null; then
  win=$(tmux list-panes -s -t "$CLAUDE_SESSION" -F '#{window_index} #{pane_current_command}' |
    awk '$2=="herdr"{print $1; exit}')
  if [ -n "$win" ]; then
    tmux select-window -t "$CLAUDE_SESSION:$win"
  else
    tmux new-window -t "$CLAUDE_SESSION" -n herdr herdr
  fi
else
  tmux new-session -d -s "$CLAUDE_SESSION" -n herdr herdr
  tmux set-option -t "$CLAUDE_SESSION" status off
fi

herdr agent focus "$id" >/dev/null 2>&1

# jump into the floating session once this popup has closed
client=$(tmux display-message -p '#{client_name}')
[ -z "$client" ] && client=$(tmux list-clients -F '#{client_name}' | head -1)
setsid sh -c "sleep 0.15; tmux popup -c '$client' -S fg=colour45 -T ' claude ' -w 100% -h 100% -b rounded -E 'tmux attach-session -t $CLAUDE_SESSION'" >/dev/null 2>&1 &
exit 0
