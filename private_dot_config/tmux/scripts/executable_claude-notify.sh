#!/usr/bin/env bash
# Claude Code hook (Notification/Stop): desktop notification when an
# agent needs input or finishes. Receives the hook payload JSON on stdin.

input=$(cat)
event=$(printf '%s' "$input" | jq -r '.hook_event_name // "Claude"')
msg=$(printf '%s' "$input" | jq -r '.message // empty')
[ -z "$msg" ] && { [ "$event" = "Stop" ] && msg="finished" || msg="needs attention"; }
project=$(basename "$(printf '%s' "$input" | jq -r --arg pwd "$PWD" '.cwd // $pwd')")

notify-send "Claude — ${project}" "${msg}"
exit 0
