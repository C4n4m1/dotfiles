#!/bin/bash
selected=$(find ~/Documents/IAI/L2/S4 -mindepth 1 -printf '%T@ %p\n' | sort -rn | cut -d' ' -f2- | vicinae dmenu -p 'Select file')
if [ -n "$selected" ]; then
    xdg-open "$selected"
fi
