nnoremap Y Y
set clipboard=unnamed,unnamedplus

set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

let $CONFIGPATH="~/.config/nvim"
if has('win32')
    let $CONFIGPATH="~/AppData/Local/nvim"
endif

" MRU Close custom code
source $CONFIGPATH/config/mruclose.vim

" Load LUA init
luafile $CONFIGPATH/config/init.lua

" Load main configuration
source $CONFIGPATH/config/nvim.vim

" Load CoC configuration
source $CONFIGPATH/config/coc.vim

" Load MSWIN'ish overrides
source $CONFIGPATH/config/mswin.vim

