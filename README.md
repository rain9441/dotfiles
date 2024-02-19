# rain9441 neovim dotfiles & setup

## linux
(Use latest version from https://github.com/neovim/neovim/releases)

Download & install & setup
```
apt-get install wget clang git
wget https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz
tar xzfv nvim-linux64.tar.gz -C /usr --strip-components=1
git clone https://github.com/rain9441/dotfiles
mkdir -p ~/.config/nvim
mv dotfiles/** ~/.config/nvim
```
