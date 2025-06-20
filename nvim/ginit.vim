" Neovide
if exists("g:neovide")
    " Put anything you want to happen only in Neovide here
    set guifont=RobotoMono\ Nerd\ Font:h10.5:cANSI
    let g:neovide_cursor_animation_length = 0.0
    let g:neovide_cursor_short_animation_length = 0.0
    let g:neovide_position_animation_length = 0.0
    let g:neovide_scroll_animation_length = 0.10
endif

" Nvim-qt
if exists('g:GuiLoaded')
    GuiFont! RobotoMono\ Nerd\ Font:h10.5:cANSI
endif
