#!/bin/bash
entry=$(zoxide query -l | vicinae dmenu -p 'Search directory' --no-quick-look --no-section)
if [[ -n "$entry" ]]; then
    echo "foo $entry"
    ghostty -e "nvim $entry"
fi
