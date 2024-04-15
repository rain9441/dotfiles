set nocompatible
filetype off

" Comma leader lets go
let mapleader = ","

set sessionoptions=blank,buffers,curdir,folds,help,localoptions,tabpages,winsize,winpos,terminal

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

" Set up color column in all file types as 120
autocmd FileType * set colorcolumn=120

" Line numbers, yes please!
set number
set numberwidth=4

" default to utf-8 encoding everywhere
set encoding=utf-8
set termencoding=utf-8

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
set scrolloff=8

" Always show the tabline
set showtabline=2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                             Fixes / Overrides                            """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Turn off buflisted for some buffers to avoid them affecting main window feel
augroup CustomUnlistBuffers
    autocmd!
    autocmd TermOpen * set nobl
    autocmd FileType qf set nobl
    " autocmd FileType dapui-console set nobl
    " autocmd FileType dap-repl set nobl
    " autocmd FileType OverseerList set nobl
augroup END

" Apply local tab settings for different file types
augroup FileTypeBasedShiftWidths
    autocmd!
    autocmd FileType typescript setlocal shiftwidth=4 tabstop=4
    autocmd FileType javascript,json setlocal shiftwidth=4 tabstop=4
    autocmd FileType lua setlocal shiftwidth=2 tabstop=2
    autocmd FileType html setlocal shiftwidth=4 tabstop=4
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

" Custom C-Tab type behavior (main window feel)
function! GotoMainWindow()
    let info = getbufinfo('%')[0]
    let buftype = getbufvar(bufnr(), '&buftype')
    if !info.listed || !empty(buftype)
        let wininfo = getwininfo()
        for win in wininfo
            if win.bufnr > 0 && getbufinfo(win.bufnr)[0].listed == 1
                " echo "found" .. getbufinfo(win.bufnr)[0]
                exec win.winnr .. "wincmd w"
                break
            endif
        endfor
    endif
endfunction

nnoremap <C-Tab> <cmd>call GotoMainWindow()<cr><cmd>lua Snacks.picker.recent()<cr>
nnoremap <C-S-Tab> <cmd>call GotoMainWindow()<cr><cmd>lua Snacks.picker.recent()<cr>

" Quick Fix
nnoremap <expr> <leader>qq "<cmd>".(get(getqflist({"winid": 1}), "winid") != 0? "cclose" : "bot copen")."<cr>"
nmap <leader>qo <cmd>bot copen<cr>
nmap <leader>qc <cmd>cclose<cr>

" Quickfix next/prev
nmap [q <cmd>cp<cr>
nmap ]q <cmd>cn<cr>

" Control N and C-S N for find next/prev and center
nnoremap <C-N> nzz
nnoremap <C-S-N> Nzz

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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                                   Lazy                                   """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <leader>ll <cmd>Lazy<cr>
nmap <leader>lp <cmd>Lazy profile<cr>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                                 Debugger                                 """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Debugger
nmap <F4> <cmd>lua require('dap').pause()<cr>
nmap <F5> <cmd>lua require('dap.ext.vscode').load_launchjs()<cr><cmd>lua require('dap').continue()<cr>
nmap <F6> <cmd>lua require('dap').terminate()<cr>
" nmap <F9> <cmd>lua require('dap').toggle_breakpoint()<cr>
" nmap <C-F9> <cmd>lua require('dap').set_breakpoint(vim.fn.input("Breakpoint condition: "))<cr>
nmap <F9> <cmd>lua require('persistent-breakpoints.api').toggle_breakpoint()<cr>
nmap <C-F9> <cmd>lua require('persistent-breakpoints.api').set_conditional_breakpoint()<cr>
nmap <F10> <cmd>lua require('dap').step_over()<cr>
nmap <F11> <cmd>lua require('dap').step_into()<cr>
nmap <S-F11> <cmd>lua require('dap').step_out()<cr>
nmap <F12> <cmd>lua require('dap').run_to_cursor()<cr>
nmap <leader>dl <cmd>lua require('dap').list_breakpoints()<cr><cmd>copen<cr>
nmap <leader>de <cmd>lua require('dap').set_exception_breakpoints()<cr>
nmap <leader>ds <cmd>lua print(require('dap').status())<cr>
nmap <leader>du <cmd>lua require('dapui').toggle()<cr>
" nmap <leader>db <cmd>lua require('dap').set_exception_breakpoints({ 'all' })<cr>
lua vim.fn.sign_define('DapBreakpointCondition', {text = '🤔', texthl = '', linehl = '', numhl = ''})
lua vim.fn.sign_define('DapBreakpoint', {text = '🟦', texthl = '', linehl = '', numhl = ''})
lua vim.fn.sign_define('DapBreakpointRejected', {text = '🟥', texthl = '', linehl = '', numhl = ''})
lua vim.fn.sign_define('DapStopped', {text = '👉', texthl = '', linehl = '', numhl = ''})

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                                    IDE                                   """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Trouble
map <leader>qe <cmd>Trouble<cr>

" NvimTree
"map <F2> <cmd>NvimTreeToggle<cr>
"map <F3> <cmd>NvimTreeFindFile<cr>

" Neotree
map <F2> <cmd>Neotree toggle last<cr>
map <F3> <cmd>Neotree reveal<cr>
map <leader><F1> <cmd>Neotree focus filesystem<cr>
map <leader><F2> <cmd>Neotree focus buffers<cr>
map <leader><F3> <cmd>Neotree focus git_status<cr>

" Overseer
nmap <leader>ol <cmd>OverseerToggle<cr>
nmap <leader>ot <cmd>OverseerToggle<cr>
nmap <leader>oi <cmd>OverseerInfo<cr>
nmap <leader>ob <cmd>OverseerBuild<cr>
nmap <leader>or <cmd>OverseerRun<cr>
nmap <leader>tr <cmd>lua require('neotest').overseer.run({})<cr>

" Comment Box
map <leader>cb1 <cmd>CBlabox<cr>
map <leader>cb2 <cmd>CBcabox<cr>
map <leader>cb3 <cmd>CBllbox<cr>
map <leader>cb4 <cmd>CBccbox<cr>
map <leader>cl1 <cmd>CBllline<cr>
map <leader>cl2 <cmd>CBccline<cr>
map <leader>cbd <cmd>CBd<cr>

" Aerial
nmap <leader>ae <cmd>call GotoMainWindow()<cr><cmd>AerialToggle! left<cr>
nmap [a <cmd>AerialPrev<cr>
nmap ]a <cmd>AerialNext<cr>

" Sessions
augroup SessionHooks
    autocmd!
    autocmd User SessionLoadPre lua require('./custom/overseer-session').reset_tasks() 
    autocmd User SessionLoadPost lua require('./custom/overseer-session').load_session()
    autocmd User SessionSavePre lua require('./custom/overseer-session').save_session()
    "autocmd User SessionLoadPost lua require('nvim-tree.api').tree.change_root(vim.fn.getcwd())
    "autocmd User SessionLoadPost lua require('nvim-tree.api').tree.toggle({ focus = false })
augroup END

" Rest Client
nmap <leader><leader>http <cmd>set filetype=http<cr>:lua require('rest-nvim').run()<cr>
augroup HttpRestClient
    autocmd!
    nnoremap <leader>hr <cmd>lua require('rest-nvim').run(true)<cr>
    nnoremap <leader>hl <cmd>lua require('rest-nvim').last()<cr>
augroup END


" Neotest
nnoremap <leader>n <cmd>lua require('neogen').generate()<cr>

" DBUI
nmap <leader>db <cmd>DBUIToggle<cr>
nmap <leader>di <cmd>DBUILastQueryInfo<cr>
augroup DBUI
  autocmd!
  autocmd FileType sql,plsql,mysql map <C-Enter> <Plug>(DBUI_ExecuteQuery)
  autocmd FileType sql,plsql,mysql imap <C-Enter> <C-o><Plug>(DBUI_ExecuteQuery)
  autocmd FileType sql,plsql,mysql nmap <F3> <cmd>DBUIFindBuffer<cr>
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                                   Git                                    """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>gs <cmd>lua require('gitsigns').stage_hunk()<cr>
nnoremap <leader>gr <cmd>lua require('gitsigns').reset_hunk()<cr>
vnoremap <leader>gs <cmd>lua require('gitsigns').stage_hunk({ vim.fn.line('.'), vim.fn.line('v')})<cr>
vnoremap <leader>gr <cmd>lua require('gitsigns').reset_hunk({ vim.fn.line('.'), vim.fn.line('v')})<cr>
nnoremap <leader>gu <cmd>lua require('gitsigns').undo_stage_hunk()<cr>
nnoremap <leader>gR <cmd>lua require('gitsigns').reset_buffer()<cr>
nnoremap <leader>gp <cmd>lua require('gitsigns').preview_hunk()<cr>
nnoremap <leader>b <cmd>call GotoMainWindow()<cr><cmd>BlameToggle<cr>
nnoremap <leader>gd <cmd>lua require('gitsigns').diffthis()<cr>
nnoremap <leader>gD <cmd>lua require('gitsigns').diffthis('~')<cr>
nnoremap <leader>gtd <cmd>lua require('gitsigns').toggle_deleted()<cr>
nnoremap ]c <cmd>lua require('gitsigns').next_hunk()<cr>
nnoremap [c <cmd>lua require('gitsigns').prev_hunk()<cr>
nnoremap <leader>gl <cmd>GitLink<cr>
vnoremap <leader>gL <cmd>GitLink blame<cr>
nnoremap <leader>gg <cmd>Neogit<cr>

nnoremap <leader>vh <cmd>DiffviewFileHistory<cr>
nnoremap <leader>vf <cmd>DiffviewFileHistory %<cr>
nnoremap <leader>v% <cmd>DiffviewFileHistory %<cr>
nnoremap <leader>vv <cmd>DiffviewOpen<cr>

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
nnoremap <A-w><A-w> <cmd>call GotoMainWindow()<cr><cmd>lua require('snacks').bufdelete()<cr>
nnoremap <A-w><A-a> <cmd>call GotoMainWindow()<cr><cmd>lua require('snacks').bufdelete.all()<cr>
nnoremap <A-w><A-q> <cmd>call GotoMainWindow()<cr><cmd>lua require('snacks').bufdelete.other()<cr>
nnoremap & <cmd>lua require('snacks').words.jump(1,1)<cr>
nnoremap <C-7> <cmd>lua require('snacks').words.jump(-1,1)<cr>

nnoremap <C-p> <cmd>lua Snacks.picker.files()<cr>
nnoremap <leader>fp <cmd>lua Snacks.picker()<cr>
nnoremap <leader>fg <cmd>lua Snacks.picker.grep()<cr>
nnoremap <leader>fo <cmd>lua Snacks.picker.grep()<cr>
nnoremap <leader>fb <cmd>lua Snacks.picker.git_branches()<cr>
nnoremap <leader>fd <cmd>lua Snacks.picker.diagnostics()<cr>


" AI
noremap <leader>fa <cmd>CodeCompanionActions<cr>
noremap <leader>at <cmd>CodeCompanionChat Toggle<cr>
vnoremap <leader>aa <cmd>CodeCompanionChat Add<cr>

" Telescope
" nnoremap <C-p> <cmd>Telescope find_files<cr>
" nnoremap <leader>fg <cmd>Telescope live_grep<cr>
" nnoremap <leader>fo <cmd>lua require('telescope.builtin').live_grep({ grep_open_files = true })<cr>
" nnoremap <leader>ff <cmd>Telescope current_buffer_fuzzy_find<cr>
" nnoremap <leader>fs <cmd>Telescope grep_string<cr>
" nnoremap <leader>fq <cmd>Telescope quickfix<cr>
" nnoremap <leader>fQ <cmd>Telescope quickfixhistory<cr>
" nnoremap <leader>fr <cmd>Telescope registers<cr>
" nnoremap <leader>fb <cmd>Telescope buffers<cr>
" nnoremap <leader>fh <cmd>Telescope help_tarequire('gitsigns')<cr>
" nnoremap <leader>ftt <cmd>Telescope git_commits<cr>
" nnoremap <leader>ftb <cmd>Telescope git_bcommits<cr>
" nnoremap <leader>fts <cmd>Telescope git_status<cr>
" nnoremap <leader>fa <cmd>Telescope aerial<cr>
" nnoremap <leader>fl <cmd>Telescope builtin<cr>

" Session Manager
nnoremap <leader>sl <cmd>SessionManager load_session<cr>
nnoremap <leader>ss <cmd>SessionManager save_current_session<cr>
nnoremap <leader>sd <cmd>SessionManager delete_session<cr>

" Color picker
nnoremap <leader>ep <cmd>CccPick<cr>

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

" Multicursor.nvim
noremap <up> <cmd>lua require('multicursor-nvim').lineAddCursor(-1)<cr>
noremap <down> <cmd>lua require('multicursor-nvim').lineAddCursor(1)<cr>
noremap <left> <cmd>lua require('multicursor-nvim').prevCursor()<cr>
noremap <right> <cmd>lua require('multicursor-nvim').nextCursor()<cr>

noremap [; <cmd>lua require('multicursor-nvim').prevCursor()<cr>
noremap ]; <cmd>lua require('multicursor-nvim').nextCursor()<cr>

noremap <leader>n <cmd>lua require('multicursor-nvim').lineAddCursor(1)<cr>
noremap <leader>N <cmd>lua require('multicursor-nvim').lineAddCursor(-1)<cr>
noremap <leader>k <cmd>lua require('multicursor-nvim').lineSkipCursor(1)<cr>
noremap <leader>K <cmd>lua require('multicursor-nvim').lineSkipCursor(-1)<cr>

noremap <leader>ca <cmd>lua require('multicursor-nvim').matchAllAddCursors()<cr>
noremap <leader>cx <cmd>lua require('multicursor-nvim').deleteCursor()<cr>
nnoremap <leader>cr <cmd>lua require('multicursor-nvim').restoreCursors()<cr>
nnoremap <leader>ca <cmd>lua require('multicursor-nvim').alignCursors()<cr>
vnoremap <leader>ct <cmd>lua require('multicursor-nvim').transposeCursors(1)<cr>
vnoremap <leader>cT <cmd>lua require('multicursor-nvim').transposeCursors(-1)<cr>

noremap <c-q> <cmd>lua require('multicursor-nvim').toggleCursor()<cr>
noremap ; <cmd>lua require('multicursor-nvim').toggleCursor()<cr>
noremap <leader><c-q> <cmd>lua require('multicursor-nvim').duplicateCursors()<cr>
nnoremap <esc> <cmd>lua if not require('multicursor-nvim').cursorsEnabled() then require('multicursor-nvim').enableCursors() elseif require('multicursor-nvim').hasCursors() then mc.clearCursors() else end<cr>

vnoremap S <cmd>lua require('multicursor-nvim').splitCursors()<cr>
vnoremap I <cmd>lua require('multicursor-nvim').insertVisual()<cr>
vnoremap A <cmd>lua require('multicursor-nvim').appendVisual()<cr>
vnoremap M <cmd>lua require('multicursor-nvim').matchCursors()<cr>
vnoremap T <cmd>lua require('multicursor-nvim').transposeCursors(1)<cr>
vnoremap <C-T> <cmd>lua require('multicursor-nvim').transposeCursors(-1)<cr>

" Cellular
nnoremap <leader><leader>1 <cmd>CellularAutomaton make_it_rain<cr>
nnoremap <leader><leader>2 <cmd>CellularAutomaton scramble<cr>
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

augroup Lsp
  autocmd!
  " Automatically open diagnostics window after updatetime (300)ms
  autocmd CursorHold * lua vim.diagnostic.open_float({ scope = 'cursor', focusable = false })
augroup end

" Typescript specific
augroup Typescript
  autocmd!
  autocmd FileType typescript,javascript nnoremap <buffer> <A-k><A-u> <cmd>VtsExec remove_unused_imports<cr>
  autocmd FileType typescript,javascript nnoremap <buffer> <A-k><A-s> <cmd>VtsExec sort_imports<cr>
  autocmd FileType typescript,javascript nnoremap <buffer> <A-k><A-i> <cmd>VtsExec add_missing_imports<cr>
  autocmd FileType typescript,javascript nnoremap <buffer> <A-k><A-r> <cmd>VtsExec rename_file<cr>

  " autocmd FileType typescript,javascript nnoremap <buffer> <A-k><A-u> <cmd>TypescriptRemoveUnused<cr>
  " autocmd FileType typescript,javascript nnoremap <buffer> <A-k><A-s> <cmd>TypescriptOrganizeImports<cr>
  " autocmd FileType typescript,javascript nnoremap <buffer> <A-k><A-i> <cmd>TypescriptAddMissingImports<cr>
  " autocmd FileType typescript,javascript nnoremap <buffer> <A-k><A-r> <cmd>TypescriptRenameFile<cr>
  " autocmd FileType typescript,javascript nnoremap <buffer> <C-]> <cmd>TSToolsGoToSourceDefinition<cr>
augroup end

augroup Csharp
    autocmd!
    autocmd FileType cs nnoremap <buffer> <C-]> <CMD>lua require('omnisharp_extended').lsp_definition()<cr>
    autocmd FileType cs nnoremap <buffer> <leader><C-]> <CMD>lua require('omnisharp_extended').lsp_type_definition()<cr>
    autocmd FileType cs nnoremap <buffer> <C-]> <CMD>lua require('omnisharp_extended').lsp_definition()<cr>
    autocmd FileType cs nnoremap <buffer> <C-\> <CMD>lua require('omnisharp_extended').lsp_references()<cr>
    autocmd FileType cs nnoremap <buffer> <C-;> <CMD>lua require('omnisharp_extended').lsp_implementation()<cr>
augroup end

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                           Config finalizations                           """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" WebDev Icons fix: after a re-source, fix syntax matching issues (concealing brackets):
if exists('g:loaded_webdevicons')
    call webdevicons#refresh()
endif

colorscheme dracula
