#!/bin/bash
brightnessctl -q s +5% 
brightness=$(brightnessctl -m | awk -F, '{print $4}')
icon="display-brightness-high-symbolic"
dunstcl close-all
dunstify -u low -i $icon -h int:value:"$brightness"  -h string:hlcolor:#dddddd "Brightness"

