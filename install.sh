#!/bin/bash

# Ask Y/n
function ask() {
    read -p "$1 (Y/n): " resp
    if [ -z "$resp" ]; then
        response_lc="y" # empty is Yes
    else
        response_lc=$(echo "$resp" | tr '[:upper:]' '[:lower:]') # case insensitive
    fi

    [ "$response_lc" = "y" ]
}

# Check what shell is being used
SH="${HOME}/.bashrc"
ZSHRC="${HOME}/.zshrc"
if [ -f "$ZSHRC" ]; then
	SH="$ZSHRC"
fi

# Check if we want to create a new .zshrc if it doesn't exist
if [ ! -f "$ZSHRC" ]; then
    if ask "Do you want to create a new .zshrc?"; then
        SH="$ZSHRC"
    fi
fi


echo '# -------------- mnadalc: Install packages ---------------'
# Ask which packages should be installed
if ask "Do you want to install all packages?"; then
    for file in packages/*.sh; do
        source "$file"
    done
else
    for file in packages/*.sh; do
        if ask "Do you want to install $file?"; then
            source "$file"
        fi
    done
fi


echo '# -------------- mnadalc: .config ---------------'
# Ask which config files should be linked
if ask "Do you want to add all .config into root?"; then
    for folder in .config/*; do
        echo "  - $folder"
        folder_name=$(basename "$folder")
        ln -s "$(realpath "$folder")" "$HOME/.config/$folder_name"
    done
else
    for folder in .config/*; do
        if ask "Do you want to add $folder into root?"; then
            echo "  - $folder"
            folder_name=$(basename "$folder")
            ln -s "$(realpath "$folder")" "$HOME/.config/$folder_name"
        fi
    done
fi

echo '# -------------- mnadalc: dotfiles install ---------------' >> $SH
# Ask which files should be sourced
echo "Do you want $SH to source: "
for file in shell/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        if ask "${filename}?"; then
            echo "source $(realpath "$file")" >> "$SH"
        fi
    fi
done
echo '# -------------- mnadalc: end dotfiles install ---------------' >> $SH

# Tmux conf --> moved into .config
# if ask "Do you want to install .tmux.conf?"; then
#     ln -s "$(realpath ".tmux.conf")" ~/.tmux.conf
# fi
# Git config
if ask "Do you want to install .gitconfig?"; then
    ln -s "$(realpath ".gitconfig")" ~/.gitconfig
fi
