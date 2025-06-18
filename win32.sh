#/bin/bash

# This script should setup symlinks for dotfiles where appropriate
# launch with `bash win32.sh` to run
# launch with `bash win32.sh -f` to replace existing symlinks (it will not remove directories)
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
            echo "[$3] $2 (directory) alread exists, unlinking"
            unlink "$2"
        fi
    fi

    if [ -f "$2" ]; then
        echo "[$3] $2 (file) already exists, ignoring"
        return 0
    elif [ -d "$2" ]; then
        echo "[$3] $2 (directory) alread exists, ignoring"
        return 0
    fi

    echo "[$3] Sym-linking $1 to $2"
    ln -s "$1" "$2"
}

install "$LOCAL_PATH/aliases" "$HOME/aliases" "Aliases"
install "$LOCAL_PATH/core/.wezterm.lua" "$HOME/.wezterm.lua" "Wezterm"
install "$LOCAL_PATH/core/.gitconfig" "$HOME/.gitconfig" "GitConfig"
install "$LOCAL_PATH/core/.gitignore" "$HOME/.gitignore" "GitIgnore"
install "$LOCAL_PATH/nvim" "$HOME/AppData/Local/nvim" "Neovim"
install "$LOCAL_PATH/win32/powertoys/default.json" "$HOME/AppData/Local/Microsoft/PowerToys/Keyboard Manager/default.json" "Keyboard Manager"

