nnoremap Y Y
set clipboard=unnamed,unnamedplus

set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" MRU Close custom code
source ~/AppData/Local/nvim/config/mruclose.vim

" Load LUA init
luafile ~/AppData/Local/nvim/config/init.lua

" Load main configuration
source ~/AppData/Local/nvim/config/nvim.vim

" Load CoC configuration
source ~/AppData/Local/nvim/config/coc.vim

" Load MSWIN'ish overrides
source ~/AppData/Local/nvim/config/mswin.vim

