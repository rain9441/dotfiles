# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="arrow"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=()

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
export EDITOR='nvim'

# Claude Code aliases
alias clauded='claude --dangerously-skip-permissions'
alias clauder='claude --resume'
alias claudedr='claude --dangerously-skip-permissions --resume'
alias claudeu='npx ccusage --breakdown --since $(date -v-1d +%Y%m%d 2>/dev/null || date -d yesterday +%Y%m%d)'
alias ccd='claude --dangerously-skip-permissions'
alias ccr='claude --resume'
alias ccdr='claude --dangerously-skip-permissions --resume'
alias ccu='npx ccusage --breakdown --since $(date -v-1d +%Y%m%d 2>/dev/null || date -d yesterday +%Y%m%d)'

# Source machine-local overrides (not tracked in dotfiles)
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
