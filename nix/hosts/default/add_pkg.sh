#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles/nix"
PKG_FILE="$DOTFILES_DIR/hosts/default/packages.nix"

cd "$DOTFILES_DIR"

read -rp "Package to add (leave empty to edit manually): " pkg_name

# CHANGE FILE
if [[ -z "$pkg_name" ]]; then
    $EDITOR "$PKG_FILE"
        if git diff --quiet -- "$PKG_FILE"; then
            echo "No changes detected, exiting."
            exit 0
        fi
else
    total_lines=$(wc -l <"$PKG_FILE")
    insert_at=$((total_lines - 1)) # 2 lines before EOF ("];" and "}")
    sed -i "${insert_at}i\\    ${pkg_name}" "$PKG_FILE"
    echo "Added '$pkg_name' to $PKG_FILE"
fi


# REBUILD
nh os switch . -q

# COMMIT
current=$(nixos-rebuild list-generations | awk '$NF=="True" {printf "gen #%s, %s %s, NixOS %s", $1, $2, substr($3,1,5), $4}')

if [[ -n "$pkg_name" ]]; then
    commit_msg="NIXOS ADD PKG: $pkg_name ($current)"
else
    commit_msg="$current"
fi

# VERSION CONTROL
if ! git commit -aq -m "$commit_msg" >/tmp/git-commit.log 2>&1; then
    # if any error happens during commiting
    cat /tmp/git-commit.log
    exit 1
fi
echo "Committed: $commit_msg"

notify-send --icon=/home/credo/.local/share/icons/Colloid-Light/apps/scalable/distributor-logo-nixos.svg --app-name=helium "NixOS" "$pkg_name succesfully added"

read -rp "Done. Press enter to close..."
