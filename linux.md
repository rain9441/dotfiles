# Linux Setup

## Automated

Run `bash linux.sh` to symlink dotfiles. Use `bash linux.sh -f` to force re-link.

After running, create machine-local shell config files as needed:

- `~/.zshenv.local` - machine-specific env (NVM, brew, etc.)
- `~/.zshrc.local` - machine-specific shell config

## Manual Steps

### KDE Shortcuts

Set up custom shortcuts in System Settings > Shortcuts > Custom Shortcuts:

| Shortcut | Command | Description |
|----------|---------|-------------|
| `Ctrl+\`` | `~/.raise-or-run.sh wezterm wezterm` | Raise/cycle/launch terminal |
| `Meta+B` | `~/.raise-or-run.sh Chrome chrome` | Raise/cycle/launch Chrome |
| `Meta+H` | `~/.raise-or-run.sh github github-desktop` | Raise/cycle/launch GitHub Desktop |
| `Meta+K` | `kcalc` | Launch KCalc |
| `Meta+M` | `~/.raise-or-run.sh Claude claude-desktop` | Raise/cycle/launch Claude Desktop |
| `Meta+N` | `~/.raise-or-run.sh neovide neovide` | Raise/cycle/launch Neovide |

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
