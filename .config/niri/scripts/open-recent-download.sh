#!/bin/bash
selected=$(find ~/Downloads -mindepth 1 -printf '%T@ %p\n' | sort -rn | cut -d' ' -f2- | vicinae dmenu -p 'Select file')
if [ -n "$selected" ]; then
    xdg-open "$selected"
fi
