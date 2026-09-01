# The script is not directly used, his content is the value of waypaper config post command option
~/.config/hypr/scripts/wallpaper.sh "$wallpaper" && sed '735s/off/on/' ~/.config/niri_blur/config.kdl.bak > ~/.config/niri_blur/config.kdl

# The 1st part on the command was initially the post command value of waypaper config
# So we add the second part to help niri reload blur
