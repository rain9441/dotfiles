#/bin/bash

echo "Installing configuration files..."
LOCAL_PATH=$(dirname "$(readlink -f "$0")")
export MSYS=winsymlinks:nativestrict
function install() {
    if [ -f "$2" ]; then
        echo "[$3] $2 (file) alread exists, ignoring"
    elif [ -d "$2" ]; then
        echo "[$3] $2 (directory) alread exists, ignoring"
    else
        echo "[$3] Sym-linking $1 to $2"
        ln -s "$1" "$2"
    fi
}

install "$LOCAL_PATH/core/.wezterm.lua" "$HOME/.wezterm.lua" "Wezterm"
install "$LOCAL_PATH/core/.gitconfig" "$HOME/.gitconfig" "GitConfig"
install "$LOCAL_PATH/core/.gitignore" "$HOME/.gitignore" "GitIgnore"
install "$LOCAL_PATH/nvim" "$HOME/AppData/Local/nvim-ln" "Neovim"

