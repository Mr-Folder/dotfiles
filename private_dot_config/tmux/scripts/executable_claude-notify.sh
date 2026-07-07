#!/usr/bin/env bash
# Claude Code hook: tracks session state for the tmux side panel (M-i)
# and raises desktop/tmux alerts when an agent needs attention.
# Receives the hook payload as JSON on stdin.

STATUS_DIR="$HOME/.cache/claude-status"
mkdir -p "$STATUS_DIR"

input=$(cat)
event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty')
sid=$(printf '%s' "$input" | jq -r '.session_id // empty')
msg=$(printf '%s' "$input" | jq -r '.message // empty')
project=$(basename "$(printf '%s' "$input" | jq -r --arg pwd "$PWD" '.cwd // $pwd')")

# --- status file for the panel ---
if [ -n "$sid" ]; then
  case "$event" in
    SessionStart|UserPromptSubmit) state="working" ;;
    Notification)                  state="waiting" ;;
    Stop)                          state="idle" ;;
    SessionEnd)                    rm -f "$STATUS_DIR/$sid"; state="" ;;
    *)                             state="" ;;
  esac
  if [ -n "$state" ]; then
    printf '%s\t%s\t%s\t%s\n' "$(date +%s)" "$state" "$project" "${TMUX_PANE:-}" > "$STATUS_DIR/$sid"
  fi
fi

# --- alerts only when the agent needs the human ---
case "$event" in
  Notification|Stop) ;;
  *) exit 0 ;;
esac

[ -z "$msg" ] && { [ "$event" = "Stop" ] && msg="finished" || msg="needs attention"; }
notify-send "Claude — ${project}" "${msg}"

# Ring the pane's bell: tmux flags the window (!) and kitty flashes the taskbar
if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ]; then
  tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}')
  [ -w "$tty" ] && printf '\a' > "$tty"
fi

exit 0
