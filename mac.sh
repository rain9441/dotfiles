#!/bin/bash
# mac.sh - Symlink mac-specific dotfiles
# Usage: bash mac.sh [-f]
#   -f  Force: overwrite existing files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=false
[ "$1" = "-f" ] && FORCE=true

link_file() {
    local src="$1"
    local dest="$2"
    local dest_dir
    dest_dir="$(dirname "$dest")"

    mkdir -p "$dest_dir"

    if [ -L "$dest" ]; then
        if [ "$FORCE" = true ]; then
            rm "$dest"
        else
            echo "  SKIP $dest (symlink exists, use -f to overwrite)"
            return
        fi
    elif [ -e "$dest" ]; then
        if [ "$FORCE" = true ]; then
            mv "$dest" "$dest.bak"
            echo "  BACKUP $dest → $dest.bak"
        else
            echo "  SKIP $dest (file exists, use -f to overwrite)"
            return
        fi
    fi

    ln -s "$src" "$dest"
    echo "  LINK $dest → $src"
}

echo "=== Mac dotfiles setup ==="

# Core dotfiles
echo "Linking core dotfiles..."
link_file "$SCRIPT_DIR/core/.wezterm.lua" "$HOME/.wezterm.lua"
link_file "$SCRIPT_DIR/core/.gitconfig" "$HOME/.gitconfig"
link_file "$SCRIPT_DIR/core/.gitignore" "$HOME/.gitignore"
link_file "$SCRIPT_DIR/nvim" "$HOME/.config/nvim"
link_file "$SCRIPT_DIR/core/.tmux.conf" "$HOME/.tmux.conf"
link_file "$SCRIPT_DIR/core/.zshrc" "$HOME/.zshrc"
link_file "$SCRIPT_DIR/core/.zshenv" "$HOME/.zshenv"
link_file "$SCRIPT_DIR/core/.zprofile" "$HOME/.zprofile"
link_file "$SCRIPT_DIR/core/.fdignore" "$HOME/.fdignore"
link_file "$SCRIPT_DIR/core/.rgignore" "$HOME/.rgignore"

# Karabiner-Elements
if ! brew list karabiner-elements &>/dev/null; then
    echo ""
    echo "Karabiner-Elements is not installed. Install it with:"
    echo "  brew install --cask karabiner-elements"
    echo ""
fi

echo "Linking Karabiner config..."
link_file "$SCRIPT_DIR/mac/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

echo ""
echo "Done! If Karabiner-Elements is running, it will pick up changes automatically."
