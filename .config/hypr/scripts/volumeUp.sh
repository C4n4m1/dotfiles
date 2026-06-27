#!/bin/bash

wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
volume=$(wpctl get-volume @DEFAULT_SINK@ | awk -F': ' '{ printf "%.0f", $2 * 100 }')
muted=$(wpctl get-volume @DEFAULT_SINK@ | grep -c  "MUTE")

if [[ $muted -eq 1 ]]; then
    icon="audio-volume-mute"
else
    if [[ $volume -gt 90 ]]; then
        icon="audio-volume-high"
    elif [[ $volume -gt 40 ]]; then
        icon="􀊥 "
    else 
        icon="􀊡 "
    fi
fi

dunstcl close-all
icon="audio-volume-high"
dunstify -a "changeVolume" -u low -i $icon -h int:value:"$volume" -h string:hlcolor:#dddddd "Volume "

