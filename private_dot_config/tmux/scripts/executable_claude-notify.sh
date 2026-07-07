#!/usr/bin/env bash
# Claude Code hook (Notification/Stop): desktop notification + tmux window bell.
# Receives the hook payload as JSON on stdin.

input=$(cat)
event=$(printf '%s' "$input" | jq -r '.hook_event_name // "Claude"')
msg=$(printf '%s' "$input" | jq -r '.message // empty')
[ -z "$msg" ] && { [ "$event" = "Stop" ] && msg="finished" || msg="needs attention"; }
project=$(basename "$(printf '%s' "$input" | jq -r --arg pwd "$PWD" '.cwd // $pwd')")

notify-send "Claude — ${project}" "${msg}"

# Ring the pane's bell: tmux flags the window (!) and kitty flashes the taskbar
if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ]; then
  tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}')
  [ -w "$tty" ] && printf '\a' > "$tty"
fi

exit 0
