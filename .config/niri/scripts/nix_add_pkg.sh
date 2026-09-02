#!/bin/bash

case "$(hostname)" in
  work)
    script="$HOME/dotfiles/nix/hosts/work/add_pkg.sh"
    ;;
  default|*)
    script="$HOME/dotfiles/nix/hosts/default/add_pkg.sh"
    ;;
esac

ghostty --class='ghostty.floating' -e "$script"
