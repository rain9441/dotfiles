#!/bin/bash

# This script should setup symlinks for dotfiles where appropriate
# launch with `bash linux.sh` to run
# launch with `bash linux.sh -f` to replace existing symlinks (it will not remove directories)
echo "Installing configuration files..."
LOCAL_PATH=$(dirname "$(readlink -f "$0")")
export MSYS=winsymlinks:nativestrict
FORCE=0
if [ "$1" == "-f" ]; then
    echo "[WARNING] Force mode enabled: files will be unlinked and relinked "
    FORCE=1
fi

function install() {
    if [ $FORCE != 0 ]; then
        if [ -f "$2" ]; then
            echo "[$3] $2 (file) already exists, unlinking"
            unlink "$2"
        elif [ -d "$2" ]; then
            echo "[$3] $2 (directory) already exists, unlinking"
            unlink "$2"
        fi
    fi

    if [ -f "$2" ]; then
        echo "[$3] $2 (file) already exists, ignoring"
        return 0
    elif [ -d "$2" ]; then
        echo "[$3] $2 (directory) already exists, ignoring"
        return 0
    fi

    echo "[$3] Sym-linking $1 to $2"
    ln -s "$1" "$2"
}

install "$LOCAL_PATH/core/.wezterm.lua" "$HOME/.wezterm.lua" "Wezterm"
install "$LOCAL_PATH/core/.gitconfig" "$HOME/.gitconfig" "GitConfig"
install "$LOCAL_PATH/core/.gitignore" "$HOME/.gitignore" "GitIgnore"
install "$LOCAL_PATH/nvim" "$HOME/.config/nvim" "Neovim"
install "$LOCAL_PATH/core/.tmux.conf" "$HOME/.tmux.conf" "Tmux"
install "$LOCAL_PATH/core/.zshrc" "$HOME/.zshrc" "Zsh"
install "$LOCAL_PATH/core/.zshenv" "$HOME/.zshenv" "Zsh"
install "$LOCAL_PATH/core/.zprofile" "$HOME/.zprofile" "Zsh"
install "$LOCAL_PATH/core/.fdignore" "$HOME/.fdignore" "fd"
install "$LOCAL_PATH/core/.rgignore" "$HOME/.rgignore" "rg"

install "$LOCAL_PATH/core/keymapper.conf" "$HOME/.config/keymapper.conf" "Keymapper"

# KDE-specific
if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
    echo "[KDE] Detected KDE desktop, installing KDE-specific files"
    install "$LOCAL_PATH/linux/kde/raise-or-run.sh" "$HOME/.raise-or-run.sh" "RaiseOrRun"
else
    echo "[KDE] Not a KDE desktop, skipping KDE-specific files"
fi

