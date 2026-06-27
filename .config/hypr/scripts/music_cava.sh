#!/bin/bash
toggle=/home/credo/.local/share/cava_script

cat "$toggle" || touch "$toggle" &&  setsid kitty +kitten panel --edge=background -o font_size=40 cava
cat "$toggle" && rm "$toggle" && killall cava 
