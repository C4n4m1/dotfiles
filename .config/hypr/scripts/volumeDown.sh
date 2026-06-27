#!/bin/bash

wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
volume=$(wpctl get-volume @DEFAULT_SINK@ | awk -F': ' '{ printf "%.0f", $2 * 100 }')
muted=$(wpctl get-volume @DEFAULT_SINK@ | grep -c  "MUTE")

if [[ $muted -eq 1 ]]; then
    icon="􀊣 "
else
    if [[ $volume -gt 90 ]]; then
        icon=" "
    elif [[ $volume -gt 40 ]]; then
        icon="􀊥 "
    else 
        icon="􀊡 "
    fi
fi

# dunstify "$icon: " -a "Volume" -h int:value:"$volume"
dunstcl close-all
icon="audio-volume-low"
dunstify -a "changeVolume" -u low -i $icon -h int:value:"$volume" -h string:hlcolor:#dddddd  "Volume "
