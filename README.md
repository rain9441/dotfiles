# rain9441 neovim dotfiles & setup

## windows

Download & install & setup

* Clone
  * `git clone https://github.com/rain9441/dotfiles`
* Install Git for Windows
  * https://gitforwindows.org/
  * Ensure bin folder is added to PATH
    * Probable path: `C:\Program Files\Git\usr\bin`
* Install neovim
  * `winget install neovim.neovim`
* Download and install a GUI
  * Neovide
    * `winget install Neovide.Neovide`
  * Neovim-QT
      * `https://github.com/equalsraf/neovim-qt`
      * Install into `C:\Program Files\Neovim-qt\`
* Symlink all dotfiles to this repo
  * `bash win32.sh`
  * unlink and force relinking: `bash win32.sh -f` 
  * Restart PowerToys
* Run windows registry files for right click "Open with ..." support (in /win32)
  * `clink-alias.reg` -- add aliases macrofile to clink shell
  * `neovide.reg` -- add "Open with Neovide" support
  * `neovide-del.reg` -- remove "Open with Neovide" support
  * `nvim-qt.reg` -- add "Open with NVIM" support
  * `nvim-qt-del.reg` -- remove "Open with NVIM" support
* Dependencies
  * Ripgrep: `winget install BurnSushi.ripgrep.MSVC`
  * Fd: `winget install sharkdp.fd`
* Treesitter Support (And other plugin support)
  * Download and install VS Build Tools - C++ Development Environment
    * [https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=buildtools](https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=buildtools)
  * Install llvm.llvm interactively *and add it to the path for all users*
    * `winget install -i llvm.llvm`

## linux

TBD
