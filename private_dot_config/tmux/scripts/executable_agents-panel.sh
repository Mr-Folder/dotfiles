#!/usr/bin/env bash
# Claude Code agent picker for tmux (M-i, runs inside a display-popup).
# fzf list of live `claude` sessions running in tmux panes (blocked/waiting >
# working > idle) with a live-refreshing preview of each agent's pane; list
# and preview reload every 2s. Enter jumps the real client to that pane;
# Esc or M-i again closes.

# "list" mode: one ansi line per agent (used at start and on each reload).
# Source of truth is `claude agents --json`; each agent's pid is mapped to
# a tmux pane by matching ttys (agents not running inside a tmux pane, e.g.
# background/dispatched agents, are skipped).
if [ "$1" = "list" ]; then
  panes=$(tmux list-panes -a -F $'#{pane_tty}\t#{pane_id}\t#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null)
  [ -z "$panes" ] && exit 0

  claude agents --json 2>/dev/null | jq -r '
    .[] | [
        ({"waiting":0,"blocked":0,"busy":1,"working":1,"idle":2}[(.state // .status // "unknown")] // 3),
        (.state // .status // "unknown"),
        (.name // (.cwd | split("/") | last)),
        (.cwd | split("/") | last),
        .pid
      ] | @tsv' |
  sort -t $'\t' -k1,1n |
  while IFS=$'\t' read -r _ status agent project pid; do
    tty=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
    [ -z "$tty" ] && continue
    [ "$tty" = "?" ] && continue
    tty="/dev/$tty"

    pane_line=$(printf '%s\n' "$panes" | awk -F'\t' -v t="$tty" '$1==t{print; exit}')
    [ -z "$pane_line" ] && continue
    pane_id=$(cut -f2 <<<"$pane_line")
    info=$(cut -f3 <<<"$pane_line")

    case "$status" in
      waiting|blocked) icon="🔔"; c=$'\033[1;31m' ;;
      busy|working)    icon="⏳"; c=$'\033[33m'   ;;
      idle)            icon="✅"; c=$'\033[32m'   ;;
      *)               icon="· "; c=$'\033[2m'    ;;
    esac
    printf '%s %b%-8s\033[0m %-15s %-15s %s\t%s\n' "$icon" "$c" "$status" "$agent" "$project" "$info" "$pane_id"
  done
  exit 0
fi

initial=$("$0" list)
if [ -z "$initial" ]; then
  printf '\n  no claude sessions in tmux\n'
  read -r -n1 -s
  exit 0
fi

# background ticker: reload the list and refresh the preview every 2s
sock=$(mktemp -u "${TMPDIR:-/tmp}/agents-panel-XXXXXX.sock")
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
      --preview 'tmux capture-pane -pet {2} 2>/dev/null' \
      --preview-window='right,55%')
[ -z "$sel" ] && exit 0
pane_id=${sel##*$'\t'}

# jump the real client to that pane; run from inside the popup, so
# #{client_name} is the client that's actually looking at this popup, and
# #{client_session} tells us whether that client IS the M-o claude popup
client=$(tmux display-message -p '#{client_name}')
[ -z "$client" ] && client=$(tmux list-clients -F '#{client_name}' | head -1)
client_session=$(tmux display-message -p '#{client_session}')

target_session=$(tmux display-message -p -t "$pane_id" '#{session_name}')
if [ "$target_session" = "claude" ]; then
  # the claude session is only ever viewed through the M-o popup: switching
  # the real client into it would make M-o run detach-client and kick the
  # user out of tmux entirely. select the pane inside the session, then open
  # the popup; run-shell -b because a popup can't open while this popup is
  # still up
  tmux select-window -t "$pane_id"
  tmux select-pane -t "$pane_id"
  # unless the picker was opened from inside the claude popup itself: the
  # session is already on screen, selecting the pane is enough, and another
  # display-popup would nest inside the current one
  if [ "$client_session" != "claude" ]; then
    tmux run-shell -b "sleep 0.1; tmux display-popup -c '$client' -S fg=colour45 -T ' claude ' -w 100% -h 100% -b rounded -E 'tmux attach-session -t claude'"
  fi
elif [ "$client_session" = "claude" ]; then
  # picked a normal agent from inside the claude popup: the popup client
  # must stay on "claude", so jump the real outer client instead, then
  # detach the popup client — that ends the attach-session the popup runs,
  # closing the popup (and this picker riding on it; we exit right after)
  outer=$(tmux list-clients -F $'#{client_name}\t#{client_session}' |
    awk -F'\t' -v me="$client" '$1!=me && $2!="claude"{print $1; exit}')
  [ -n "$outer" ] && tmux switch-client -c "$outer" -t "$pane_id" 2>/dev/null
  tmux detach-client -t "$client"
else
  # switches session, window and pane in one shot
  tmux switch-client -c "$client" -t "$pane_id" 2>/dev/null
fi
exit 0
