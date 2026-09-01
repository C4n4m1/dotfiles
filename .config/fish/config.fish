if status is-interactive
    # Commands to run in interactive sessions can go here
end

# ctrl z to toggle send process to background / foreground
# didn't work :(
# bind ctrl-z '__fish_echo fg 2>/dev/null'

# CLI setup
fzf_configure_bindings --directory=\cp --variables=\e\cv
zoxide init fish | source
starship init fish | source
# tv init fish | source
# fzf --fish | source
#---------------------------------------------------------------------------------------------

# ABBREVIATIONS & ALIAS
abbr ll "exa -l -g --icons=auto"
abbr c clear
abbr ff fastfetch
abbr shutdown "systemctl poweroff"
abbr logout "systemctl restart sddm"
abbr v nvim
abbr sv sudoedit
abbr hx helix
abbr lf "ls | fzf"
abbr lt "exa -T"
abbr nv "nvim ."
abbr data "cd /run/media/credo/Data/"
abbr nirib "~/.local/bin/niri"
abbr pkg "pacman -Qq | fzf"
abbr sv sudoedit
abbr emu 'emulator -avd Flutter_dev -gpu host -no-snapshot &'
abbr ytdl 'yt-dlp -x --audio-format mp3 --output "%(title)s - %(channel)s.%(ext)s"'
abbr nrs 'sudo nixos-rebuild switch --flake /home/credo/dotfiles/nix/'

# alias
alias daddy sudo
alias h "~/helper.sh"
alias ls exa
alias run "clear && ~/runner.sh"
alias manga_dl "~/Mangas/comics-downloader-linux-x86-64"

# Shortcuts functions

# function run
#     clear
#     ~/runner.sh $1
# end
# ---------------------------------------- FUNCTIONS ----------------------------------------
# Greeter
function fish_greeting

end

function fish_title
    # If we're connected via ssh, we print the hostname.
    set -l ssh
    set -q SSH_TTY
    and set ssh "["(prompt_hostname | string sub -l 10 | string collect)"]"
    # An override for the current command is passed as the first parameter.
    # This is used by `fg` to show the true process name, among others.
    if set -q argv[1]
        echo -- $ssh (string sub -l 20 -- $argv[1]) (string replace -r "^$HOME" "~" $PWD)
    else
        # Don't print "fish" because it's redundant
        set -l command (status current-command)
        if test "$command" = fish
            set command
        end
        echo -- $ssh (string sub -l 20 -- $command) (string replace -r "^$HOME" "~" $PWD)
    end
end

function mssql
    set opt $argv[1]
    if test $opt = start
        sudo systemctl start mssql-server.service
    else if test $opt = stop
        sudo systemctl stop mssql-server.service
    else if test $opt = status
        sudo systemctl status mssql-server.service
    else
        echo "Wrong argument "
        echo "--- Available options --- "
        echo "→ start : to launch the mssql server"
        echo "→ stop : to stop the mssql server"
    end
end

function lamp
    # mariaDB is the service
    set opt $argv[1]
    if test $opt = start
        sudo systemctl start httpd mariadb
    else if test $opt = stop
        sudo systemctl stop httpd mariadb
    else if test $opt = status
        sudo systemctl status httpd mariadb
    else
        echo "Wrong argument "
        echo "--- Available options --- "
        echo "→ start : to launch APACHE ( httpd ) and MYSQL ( using mariaDB on arch )"
        echo "→ stop : to stop APACHE ( httpd ) and MYSQL ( using mariaDB on arch )"
    end
end

function restart
    set opt $argv[1]
    echo "Restarting $opt"
    echo "***"
    pkill opt && echo "Closing $opt"
    setsid opt && echo "$opt is starting"
end

function png
    set opt $argv[1]
    set base "$opt"
    set newext png

    set result (string replace -r '\.[^.]*$' ".$newext" -- $base)

    gowall convert $opt -f png --output $result
end

function webp
    set opt $argv[1]
    set base "$opt"
    set newext png

    set result (string replace -r '\.[^.]*$' ".$newext" -- $base)

    gowall convert $opt -f webp --output $result
end

# function rm
#     if test "$1" != -rm
#         for file in $argv
#             if test $file != "$1"
#                 mv $file /home/credo/trash
#                 echo $file 'moved to trash'
#             end
#         end
#     else
#         for dir in $argv
#             if test $dir != $1
#                 echo $1
#                 rm -i -rf $dir
#             end
#         end
#     end
# end
#
# function ls
#     if set -q argv[1]
#         set dir (zoxide query $argv[1])
#         echo $dir
#         exa --icons $dir
#     else
#         exa --icons
#     end
# end

# VARIABLES
# -g : global, -x : export for others process
set -g fish_greeting
set -gx EDITOR nvim
set -gx BROWSER zen-browser
set -gx GDK_RGB 1
set -gx LIBVIRT_DEFAULT_URI 'qemu:///system'
set -gx QT_SCALE_FACTOR 1

# ls and fd colors mathcing kitty theme
set -gx LS_COLORS "$(vivid generate ~/.config/vivid/themes/oldworld.yml)"

# fzf.fish
set fzf_history_time_format "%d-%m-%y %H:%M"
set fzf_directory_opts --bind "ctrl-o:execute($EDITOR {} &> /dev/tty)"
# To exclude timestamp from the history search
# set -gx fzf_history_opts "--nth=4.."

# chronologiacal order in history
# set fzf_history_opts --no-sort

# Created by `pipx` on 2025-08-12 00:16:03
fish_add_path /home/credo/.local/bin

# bun
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path $BUN_INSTALL/bin
fish_add_path /usr/bin/vendor_perl

# Android Dev
# set -gx ANDROID_HOME /opt/android-sdk
# set -gx ANDROID_SDK_ROOT /opt/android-sdk
# set -gx ANDROID_AVD_HOME "$HOME/.android/avd"
#
# # Java 24 settings
# set -gx JAVA_HOME /usr/lib/jvm/java-21-openjdk
#
# # Android SDK settings (AUR compatible)
# set -gx ANDROID_HOME /opt/android-sdk
# set -gx ANDROID_SDK_ROOT /opt/android-sdk
# set -gx ANDROID_AVD_HOME "$HOME/.android/avd"
#
# # Path settings
# fish_add_path $ANDROID_HOME/platform-tools
# fish_add_path $ANDROID_HOME/cmdline-tools/latest/bin
# fish_add_path $ANDROID_HOME/emulator
# fish_add_path $ANDROID_HOME/tools/bin
#
# # Flutter path
# fish_add_path /opt/flutter/bin

# dotnet
fish_add_path /home/credo/.dotnet/tools
# Pub cache
set -gx PUB_CACHE "$HOME/.pub-cache"
