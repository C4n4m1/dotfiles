#!/bin/sh

# Ensure KITTY_WINDOW_ID is set (it is when launched via keymap)
KITTY_WINDOW_ID=$KITTY_WINDOW_ID

# Get the OS window ID for the current window using kitty @ ls and jq
os_window_id=$(kitty @ ls | jq -r ".[] | select(.windows[] | .id == $KITTY_WINDOW_ID) | .id")

# Use a state file specific to this OS window
STATE_FILE=~/.kitty_tab_bar_style_$os_window_id

# Read the current style from the state file, default to powerline if not set
if [ -f "$STATE_FILE" ]; then
    current_style=$(cat "$STATE_FILE")
else
    current_style="powerline"
fi

# Toggle the style
if [ "$current_style" = "powerline" ]; then
    kitty @ set-tab-bar-style hidden --match id:$KITTY_WINDOW_ID
    echo "hidden" > "$STATE_FILE"
else
    kitty @ set-tab-bar-style powerline --match id:$KITTY_WINDOW_ID
    echo "powerline" > "$STATE_FILE"
fi
