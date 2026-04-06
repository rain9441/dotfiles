# Linux Setup

## Automated

Run `bash linux.sh` to symlink dotfiles. Use `bash linux.sh -f` to force re-link.

After running, create machine-local shell config files as needed:

- `~/.zshenv.local` - machine-specific env (NVM, brew, etc.)
- `~/.zshrc.local` - machine-specific shell config

## Manual Steps

### Global Shortcuts (keymapper)

App launcher shortcuts are managed by [keymapper](https://github.com/houmain/keymapper) via `~/.config/keymapper.conf` (symlinked from `core/keymapper.conf`).

Install keymapper from GitHub releases (RPM):

```bash
sudo dnf install https://github.com/houmain/keymapper/releases/download/5.4.2/keymapper-5.4.2-Linux-x86_64.rpm
sudo systemctl enable --now keymapperd.service
```

The `keymapper` client auto-starts via `/etc/xdg/autostart/keymapper.desktop`.

### Flatpak Aliases

Symlink flatpak apps into `~/.local/bin/` so raise-or-run can launch them:

```bash
ln -s /var/lib/flatpak/exports/bin/com.google.Chrome ~/.local/bin/chrome
ln -s /var/lib/flatpak/exports/bin/io.github.shiftey.Desktop ~/.local/bin/github-desktop
```

### Packages

Key packages to install:

- `neovim`, `neovide`
- `wezterm`
- `tmux`
- `delta` (git pager)
- `kdotool` (KDE window control)
- `fd-find`, `ripgrep`
- `oh-my-zsh`
- `nvm`
- `keymapper` (global shortcuts — see above)
