#!/usr/bin/env bash

SESSION_NAME="claude"
WIDTH="100%"
HEIGHT="100%"
BORDER_COLOR="colour45"
TITLE=" claude "

if [ "$(tmux display-message -p '#{session_name}')" = "$SESSION_NAME" ]; then
  tmux detach-client
else
  if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME"
    tmux set-option -t "$SESSION_NAME" status off
  fi

  tmux set-option -t "$SESSION_NAME" detach-on-destroy on
  tmux popup \
    -S fg="$BORDER_COLOR" \
    -T "$TITLE" \
    -w "$WIDTH" \
    -h "$HEIGHT" \
    -b rounded \
    -E \
    "tmux attach-session -t \"$SESSION_NAME\""
fi
