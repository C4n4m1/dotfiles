#!/bin/bash
class=$(hyprctl activewindow -j | jq  .class)

if [[ $class = \"zen\" ]]; then
    wtype -M  ctrl T && sleep 0.03  &&  wtype -k asciicircum  && wtype -k space
else
    wtype -M ctrl H
fi
