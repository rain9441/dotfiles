# rain9441 neovim dotfiles & setup

## windows

Download & install & setup

* Install neovim
  * `winget install neovim.neovim`
* Download and install Neovim-QT (Neovim >= 1.0)
  * `https://github.com/equalsraf/neovim-qt`
  * Install into `C:\Program Files\Neovim-qt\`
* Clone dotfiles
  * `mkdir "%HOME%/AppData/Local/nvim"`
  * `pushd "%HOME%/AppData/Local/nvim"`
  * `git clone https://github.com/rain9441/dotfiles`
  * `popd`
* Run windows registry file for right click "Open with NVIM" support
  * `nvim.regs
* Ripgrep
  * `winget install BurnSushi.ripgrep.MSVC`
* Treesitter Support (And other plugin support)
  * Download and install VS Build Tools - C++ Development Environment
    * [https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=buildtools](https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=buildtools)
  * Install llvm.llvm interactively *and add it to the path for all users*
    * `winget install -i llvm.llvm`

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

