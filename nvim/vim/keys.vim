set nocompatible
filetype off

" Comma leader lets go
let mapleader = ","

set sessionoptions=blank,buffers,curdir,folds,localoptions
set backspace=indent,eol,start

" this setting controls how long to wait (in ms) before fetching type / symbol information / saving files.
set updatetime=300

syn enable

nnoremap Y Y
set clipboard=unnamed,unnamedplus

set hidden

" Stop the annoying gvim ding sounds
set belloff=all
set expandtab
set ignorecase
set smartcase

" don't leave files everywhere
set nobackup
set noswapfile
set nowritebackup

" Indent
set autoindent
set smartindent
set breakindent
set breakindentopt+=shift:4

" Highlight the whole line
set cursorline
set cursorlineopt=screenline,number

" Set up color column in all file types as 120
autocmd FileType * set colorcolumn=120

" Line numbers, yes please!
set number
set numberwidth=4

" default to utf-8 encoding everywhere
set encoding=utf-8

set incsearch
set nohlsearch

set title
set titlestring=%{getcwd()}

" And ignore node_modules entirely and /dist too
set wildignore+=**/node_modules**
set wildignore+=**/dist**
set wildignore+=**/coverage**

" Always show the signcolumn, otherwise it would shift the text each time diagnostics appear/become resolved
set signcolumn=yes

" Show matching parens and braces and such
set showmatch
set completeopt=menu,menuone,noselect

" Split settings to lower right by default
set splitbelow
set splitright

" Tabs, tabs, omg tabs what number should we use?
set shiftwidth=4
set tabstop=4

" Many colors
set termguicolors

" keep 8 lines above/below our cursor
set scrolloff=4

" Always show the tabline
set showtabline=2

" Only show one status line
set laststatus=3

" Reduce the history from 10000 to 50, 10000 is a bit unreasonable and crashes
" shada file writing.  Limit shada due to lots of shada file issues.
set history=50
set shada=!,'0,<3,@20,s1,f0,h


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""                             Fixes / Overrides                            """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Turn off buflisted for some buffers to avoid them affecting main window feel
augroup CustomUnlistBuffers
    autocmd!
    autocmd TermOpen * set nobl
    autocmd FileType qf set nobl
augroup END

" Apply local tab settings for different file types
augroup FileTypeBasedShiftWidths
    autocmd!
    autocmd FileType typescript setlocal shiftwidth=2 tabstop=2
    autocmd FileType javascript,json setlocal shiftwidth=2 tabstop=2
    autocmd FileType lua setlocal shiftwidth=2 tabstop=2
    autocmd FileType html setlocal shiftwidth=2 tabstop=2
augroup END

" QuickFix window always on bottom
augroup QuickFixToBottom
    autocmd!
    autocmd FileType qf wincmd J
augroup END

" Fix the q: q/ q? bindings
nnoremap <silent> q :<C-u>call <SID>SmartQ()<cr>
function! s:SmartQ()
  if exists("g:recording_macro")
    let r = g:recording_macro
    unlet g:recording_macro
    normal! q
    execute 'let @'.r.' = @'.r.'[:-2]'
  else
    let c = nr2char(getchar())
    if c == ':'
    " do nothing
    else
      if c =~ '\v[0-9a-zA-Z"]'
        let g:recording_macro = c
      endif
      execute 'normal! q'.c
    endif
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                               Vanilla NVIM                               """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Font size controls
let s:fontsize = 10.5
function! SetFontSize(amount)
    let s:fontsize = a:amount
    let s:font = 'RobotoMono\ Nerd\ Font'
    echo 'Font Size: ' . string(s:fontsize)
    :execute 'GuiFont! ' . s:font . ':h' . string(s:fontsize) . ':cDEFAULT'
endfunction
function! AdjustFontSize(amount)
    call SetFontSize(s:fontsize + a:amount)
endfunction

" In normal mode, pressing numpad's+ increases the font
noremap <kPlus> <cmd>call AdjustFontSize(+0.25)<cr>
noremap <S-kPlus> <cmd>call AdjustFontSize(+1.00)<cr>
noremap <kMinus> <cmd>call AdjustFontSize(-0.25)<cr>
noremap <S-kMinus> <cmd>call AdjustFontSize(-1.00)<cr>
noremap <C-kMinus> <cmd>call SetFontSize(9)<cr>
noremap <C-kPlus> <cmd>call SetFontSize(10.5)<cr>
noremap <C-kEnter> <cmd>call SetFontSize(16)<cr>
" In insert mode, pressing ctrl + numpad's+ increases the font
inoremap <C-kPlus> <C-o><cmd>call AdjustFontSize(+0.25)<cr>
inoremap <C-kMinus> <C-o><cmd>call AdjustFontSize(-0.25)<cr>

" Quick Fix
nnoremap <expr> <leader>qq "<cmd>".(get(getqflist({"winid": 1}), "winid") != 0? "cclose" : "bot copen")."<cr>"
nmap <leader>qo <cmd>bot copen<cr>
nmap <leader>qc <cmd>cclose<cr>

" Quickfix next/prev
nmap [q <cmd>cp<cr>
nmap ]q <cmd>cn<cr>

" Location List (drawer for :WinterDeltaDiff and any :lopen list)
nnoremap <expr> <leader>ww "<cmd>".(get(getloclist(0, {"winid": 1}), "winid") != 0? "lclose" : "bot lopen")."<cr>"
nmap <leader>wo <cmd>bot lopen<cr>
nmap <leader>wc <cmd>lclose<cr>

" Location list next/prev
nmap [w <cmd>lprevious<cr>
nmap ]w <cmd>lnext<cr>

" Control N and C-S N for find next/prev and center
nnoremap <C-N> nzz
nnoremap <C-S-N> Nzz

" C-s for quick save
nnoremap <C-s> <cmd>update<cr>
inoremap <C-s> <C-o><cmd>update<cr>

" Command :Gf <file> to find in files across all files in the current git repo
command! -nargs=1 Gf noautocmd lvimgrep /<args>/gj `git ls-files` | lw
command! -nargs=1 Gfc noautocmd lvimgrep /<args>\C/gj `git ls-files` | lw
 
" Quick goto for config
nmap <leader>co <cmd>execute 'edit' g:configpath . '/init.lua'<cr>

" Use C-[hjkl] to navigate between splits
nmap <C-k> <cmd>wincmd k<cr>
nmap <C-j> <cmd>wincmd j<cr>
nmap <C-h> <cmd>wincmd h<cr>
nmap <C-l> <cmd>wincmd l<cr>

tmap <C-\><C-k> <cmd>wincmd k<cr>
tmap <C-\><C-j> <cmd>wincmd j<cr>
tmap <C-\><C-h> <cmd>wincmd h<cr>
tmap <C-\><C-l> <cmd>wincmd l<cr>

" When leaving insert mode on an empty line, coerce autoindent to leave the indentation
inoremap <CR> <CR>x<BS>
nnoremap o ox<BS>
nnoremap O Ox<BS>

" Use gj to navigate in wrapped lines more elegantly
noremap <expr> j v:count ? 'j' : 'gj'
noremap <expr> k v:count ? 'k' : 'gk'

" Filetypes
nmap <leader><leader>json <cmd>set filetype=json<cr>
nmap <leader><leader>ts <cmd>set filetype=typescript<cr>
nmap <leader><leader>js <cmd>set filetype=javascript<cr>
nmap <leader><leader>sql <cmd>set filetype=sql<cr>

" Tabs
nnoremap <C-1> <cmd>tabn 1<cr>
nnoremap <C-2> <cmd>tabn 2<cr>
nnoremap <C-3> <cmd>tabn 3<cr>
nnoremap <C-4> <cmd>tabn 4<cr>
nnoremap <C-w><C-w> <cmd>tabc<cr>

" Quick stuff
nnoremap <leader>nsb <cmd>set noscrollbind<cr>
nnoremap <leader>wr <cmd>set wrap<cr>
nnoremap <leader>nwr <cmd>set nowrap<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                                   Lazy                                   """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <leader>ll <cmd>Lazy<cr>
nmap <leader>lp <cmd>Lazy profile<cr>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                                    IDE                                   """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Trouble
map <leader>qe <cmd>Trouble<cr>

" Neotree
" Routed through neotree-safe so codediff tabs first switch out, or suppress.
map <F2> <cmd>lua require('custom/neotree-safe').run('Neotree toggle last')<cr>
map <F3> <cmd>lua require('custom/neotree-safe').run('Neotree reveal')<cr>
map <leader><F1> <cmd>lua require('custom/neotree-safe').run('Neotree focus filesystem')<cr>
map <leader><F2> <cmd>lua require('custom/neotree-safe').run('Neotree focus buffers')<cr>
map <leader><F3> <cmd>lua require('custom/neotree-safe').run('Neotree focus git_status')<cr>

" Rest Client
nmap <leader><leader>http <cmd>set filetype=http<cr>:lua require('rest-nvim').run()<cr>
augroup HttpRestClient
    autocmd!
    nnoremap <leader>hr <cmd>lua require('rest-nvim').run(true)<cr>
    nnoremap <leader>hl <cmd>lua require('rest-nvim').last()<cr>
augroup END



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                                   Git                                    """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>gs <cmd>lua require('gitsigns').stage_hunk()<cr>
nnoremap <leader>gbs <cmd>lua require('gitsigns').stage_buffer()<cr>
nnoremap <leader>gr <cmd>lua require('gitsigns').reset_hunk()<cr>
nnoremap <leader>gbr <cmd>lua require('gitsigns').reset_buffer()<cr>
vnoremap <leader>gs <cmd>lua require('gitsigns').stage_hunk({ vim.fn.line('.'), vim.fn.line('v')})<cr>
vnoremap <leader>gr <cmd>lua require('gitsigns').reset_hunk({ vim.fn.line('.'), vim.fn.line('v')})<cr>
nnoremap <leader>gR <cmd>lua require('gitsigns').reset_buffer()<cr>
nnoremap <leader>gp <cmd>lua require('gitsigns').preview_hunk()<cr>
nnoremap <leader>gbb <cmd>lua require('gitsigns').blame()<cr>
nnoremap <leader>gbl <cmd>lua require('gitsigns').blame_line()<cr>
nnoremap <leader>b <cmd>lua require('custom/main-window').activate()<cr><cmd>BlameToggle<cr>
nnoremap <leader>gd <cmd>lua require('gitsigns').diffthis()<cr>
nnoremap <leader>gD <cmd>lua require('gitsigns').diffthis('~')<cr>
nnoremap <leader>gtd <cmd>lua require('gitsigns').toggle_deleted()<cr>
nnoremap <leader>gtw <cmd>lua require('gitsigns').toggle_word_diff()<cr>
nnoremap <leader>gtl <cmd>lua require('gitsigns').toggle_linehl()<cr>
nnoremap <leader>gtn <cmd>lua require('gitsigns').toggle_numhl()<cr>
nnoremap ]c <cmd>lua require('gitsigns').next_hunk()<cr>
nnoremap [c <cmd>lua require('gitsigns').prev_hunk()<cr>
nnoremap <leader>gg <cmd>Neogit<cr>

nnoremap <leader>vv <cmd>CodeDiff<cr>
nnoremap <leader>vd <cmd>CodeDiff<cr>
nnoremap <leader>ve <cmd>CodeDiff HEAD~1<cr>
nnoremap <leader>vh <cmd>CodeDiff history<cr>
nnoremap <leader>va <cmd>CodeDiff main...<cr>
nnoremap <leader>vs <cmd>CodeDiff master...<cr>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                               Interactions                               """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ripgrep
vnoremap <C-8> y<Esc><cmd>Rg <C-R>"<cr>
nnoremap <C-8> <cmd>Rg<cr>

" Comment
nnoremap t <Plug>(comment_toggle_linewise_current)
nnoremap <C-T> <Plug>(comment_toggle_blockwise_current)
vnoremap t <Plug>(comment_toggle_linewise_visual)
vnoremap <C-T> <Plug>(comment_toggle_blockwise_visual)

" Snacks
nnoremap <C-Tab> <cmd>lua require('custom/main-window').activate()<cr><cmd>lua Snacks.picker.buffers()<cr>
nnoremap <C-S-Tab> <cmd>lua require('custom/main-window').activate()<cr><cmd>lua Snacks.picker.recent({filter = {cwd = true}})<cr>

nnoremap <A-w><A-w> <cmd>lua require('custom/main-window').activate()<cr><cmd>lua require('snacks').bufdelete()<cr><cmd>lua require('custom/main-window').goto_mru_buf()<cr>
nnoremap <A-w><A-a> <cmd>lua require('custom/main-window').activate()<cr><cmd>lua require('snacks').bufdelete.all()<cr>
nnoremap <A-w><A-q> <cmd>lua require('custom/main-window').activate()<cr><cmd>lua require('snacks').bufdelete.other()<cr>
nnoremap & <cmd>lua require('snacks').words.jump(1,1)<cr>
nnoremap <C-7> <cmd>lua require('snacks').words.jump(-1,1)<cr>

" nnoremap <F2> <cmd>lua require ('./custom/actions').focus_explorer()<cr>
" nnoremap <F3> <cmd>lua require ('./custom/actions').reveal_explorer()<cr>
" nnoremap <F3> <cmd>lua Snacks.explorer.reveal()<cr>lua Snacks.explorer.open()<cr>
nnoremap <C-p> <cmd>lua Snacks.picker.files()<cr>
nnoremap <leader>fp <cmd>lua Snacks.picker()<cr>
nnoremap <leader>fg <cmd>lua Snacks.picker.grep()<cr>
nnoremap <leader>fo <cmd>lua Snacks.picker.grep()<cr>
nnoremap <leader>fb <cmd>lua Snacks.picker.git_branches()<cr>
nnoremap <leader>fl <cmd>lua Snacks.picker.git_log()<cr>
nnoremap <leader>fs <cmd>lua Snacks.picker.git_status()<cr>
nnoremap <leader>fd <cmd>WinterDashboard<cr>
nnoremap <leader>fw <cmd>WinterWorktrees<cr>
nnoremap <leader>err <cmd>lua Snacks.notifier.show_history()<cr>

nnoremap <leader>tt <cmd>lua package.loaded['custom/main-window'] = nil and require('custom/main-window')<cr>
nnoremap <leader>ty <cmd>lua require('custom/main-window').goto_mru_buf()<cr>

" Session Manager
nnoremap <leader>sl <cmd>SessionManager load_session<cr>
nnoremap <leader>ss <cmd>SessionManager save_current_session<cr>
nnoremap <leader>sd <cmd>SessionManager delete_session<cr>

" Color picker
nnoremap <leader>cp <cmd>CccPick<cr>

" Treesj (join / split funcitons
nnoremap <leader>m <cmd>TSJToggle<cr>

" Treesitter
nnoremap <leader>hi <cmd>TSHighlightCapturesUnderCursor<cr>
nnoremap <leader>hp <cmd>TSPlaygroundToggle<cr>

" MoveLine
nnoremap <A-Up> <cmd>MoveLine(-1)<cr>
nnoremap <A-Down> <cmd>MoveLine(1)<cr>
vnoremap <A-Up> <cmd>MoveBlock(-1)<cr>
vnoremap <A-Down> <cmd>MoveBlock(1)<cr>

"VimBeBetter
nnoremap <leader>vbb <cmd>VimBeBetter<cr>

" Substitute
nnoremap s <cmd>lua require('substitute').operator()<cr>
nnoremap ss <cmd>lua require('substitute').line()<cr>
nnoremap S <cmd>lua require('substitute').eol()<cr>
vnoremap s <cmd>lua require('substitute').visual()<cr>

nnoremap <leader>sqt <cmd>lua require('sqlit').open()<cr>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                                    LSP                                   """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap [g <cmd>lua vim.diagnostic.goto_prev()<cr>
nnoremap ]g <cmd>lua vim.diagnostic.goto_next()<cr>
nnoremap [e <cmd>lua vim.diagnostic.goto_prev()<cr>
nnoremap ]e <cmd>lua vim.diagnostic.goto_next()<cr>
nnoremap K <cmd>lua vim.lsp.buf.hover()<cr>
nnoremap <A-k><A-c> <cmd>lua vim.lsp.buf.code_action()<cr>
nnoremap <C-.> <cmd>lua require ('./custom/actions').code_action_apply_first()<cr>
nnoremap <A-k><A-d> <cmd>lua vim.lsp.buf.format()<cr>
nnoremap <C-'> <cmd>lua vim.lsp.buf.declaration()<cr>
nnoremap <C-]> <cmd>lua vim.lsp.buf.definition()<cr>
nnoremap <C-;> <cmd>lua vim.lsp.buf.implementation()<cr>
nnoremap <C-\> <cmd>lua vim.lsp.buf.references()<cr>
nnoremap <leader>rn <cmd>lua vim.lsp.buf.rename()<cr>

" Bind standard LSP keys to NOP until they are bound to their LSP specific command
nnoremap <A-k><A-u> <nop>
nnoremap <A-k><A-s> <nop>
nnoremap <A-k><A-i> <nop>
nnoremap <A-k><A-r> <nop>

" Typescript specific
augroup Typescript
  autocmd!
  autocmd FileType typescript,javascript nnoremap <buffer> <A-k><A-u> <cmd>VtsExec remove_unused_imports<cr>
  autocmd FileType typescript,javascript nnoremap <buffer> <A-k><A-s> <cmd>VtsExec sort_imports<cr>
  autocmd FileType typescript,javascript nnoremap <buffer> <A-k><A-i> <cmd>VtsExec add_missing_imports<cr>
  autocmd FileType typescript,javascript nnoremap <buffer> <A-k><A-r> <cmd>VtsExec rename_file<cr>
augroup end

" augroup Csharp
"     autocmd!
"     autocmd FileType cs nnoremap <buffer> <C-]> <CMD>lua require('omnisharp_extended').lsp_definition()<cr>
"     autocmd FileType cs nnoremap <buffer> <leader><C-]> <CMD>lua require('omnisharp_extended').lsp_type_definition()<cr>
"     autocmd FileType cs nnoremap <buffer> <C-]> <CMD>lua require('omnisharp_extended').lsp_definition()<cr>
"     autocmd FileType cs nnoremap <buffer> <C-\> <CMD>lua require('omnisharp_extended').lsp_references()<cr>
"     autocmd FileType cs nnoremap <buffer> <C-;> <CMD>lua require('omnisharp_extended').lsp_implementation()<cr>
" augroup end


" Prompt Yank
nnoremap <leader>y1 <cmd>PromptYank format claude<cr>
nnoremap <leader>y2 <cmd>PromptYank format default<cr>
nnoremap <leader>y3 <cmd>PromptYank format minimal<cr>
nnoremap <leader>y4 <cmd>PromptYank format xml<cr>
nnoremap <leader>y5 <cmd>PromptYank style markdown<cr>
nnoremap <leader>y6 <cmd>PromptYank style xml<cr>
nnoremap <leader>yy :let @+=expand("%:p")<CR>:let @*=expand("%:p")<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                           Config finalizations                           """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" WebDev Icons fix: after a re-source, fix syntax matching issues (concealing brackets):
if exists('g:loaded_webdevicons')
    call webdevicons#refresh()
endif

colorscheme dracula
