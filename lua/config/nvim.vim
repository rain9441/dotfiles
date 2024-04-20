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

" Fix some weird error with Fugitive
let g:fugitive_pty = 0

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
nnoremap <silent> q :<C-u>call <SID>SmartQ()<CR>
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
noremap <kPlus> :call AdjustFontSize(+0.25)<CR>
noremap <S-kPlus> :call AdjustFontSize(+1.00)<CR>
noremap <kMinus> :call AdjustFontSize(-0.25)<CR>
noremap <S-kMinus> :call AdjustFontSize(-1.00)<CR>
noremap <C-kMinus> :call SetFontSize(9)<CR>
noremap <C-kPlus> :call SetFontSize(10.5)<CR>
noremap <C-kEnter> :call SetFontSize(16)<CR>
" In insert mode, pressing ctrl + numpad's+ increases the font
inoremap <C-kPlus> <Esc>:call AdjustFontSize(+0.25)<CR>a
inoremap <C-kMinus> <Esc>:call AdjustFontSize(-0.25)<CR>a

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
function! CustomTab()
    let info = getbufinfo('%')[0]
    let buftype = getbufvar(bufnr(), '&buftype')
    if info.listed && empty(buftype)
        lua require('telescope.builtin').buffers()
    else
        let wininfo = getwininfo()
        for win in wininfo
            if win.bufnr > 0 && getbufinfo(win.bufnr)[0].listed == 1
                " echo "found" .. getbufinfo(win.bufnr)[0]
                exec win.winnr .. "wincmd w"
                lua require('telescope.builtin').buffers()
                break
            endif
        endfor
    endif
endfunction
nnoremap <silent> <C-Tab> <cmd>call GotoMainWindow()<CR><cmd>call CustomTab()<CR>
nnoremap <silent> <C-S-Tab> <cmd>call GotoMainWindow()<CR><cmd>call CustomTab()<CR>
nnoremap <silent> <A-w><A-w> <cmd>call GotoMainWindow()<CR><cmd>BufferCloseAndGoToMRU<CR>
nnoremap <silent> <A-w><A-a> <cmd>call GotoMainWindow()<CR><cmd>BufferCloseOthers<CR>
nnoremap <silent> <A-w><A-q> <cmd>call GotoMainWindow()<CR><cmd>BufferCloseAll<CR>

" Quick Fix
nnoremap <silent><expr> <leader>qq "<cmd>".(get(getqflist({"winid": 1}), "winid") != 0? "cclose" : "bot copen")."<cr>"
nmap <silent> <leader>qo :bot copen<CR>
nmap <silent> <leader>qc :cclose<CR>

" Quickfix next/prev
nmap <silent> [q :cp<CR>
nmap <silent> ]q :cn<CR>

" Control N and C-S N for find next/prev and center
nnoremap <silent> <C-N> nzz
nnoremap <silent> <C-S-N> Nzz

" Command :Gf <file> to find in files across all files in the current git repo
command! -nargs=1 Gf noautocmd lvimgrep /<args>/gj `git ls-files` | lw
command! -nargs=1 Gfc noautocmd lvimgrep /<args>\C/gj `git ls-files` | lw
 
" Quick goto for config
nmap <silent> <leader>cc :e $CONFIGPATH/config/coc.vim<CR>
nmap <silent> <leader>ci :e $CONFIGPATH/config/init.lua<CR>
nmap <silent> <leader>cl :e $CONFIGPATH/config/lsp.vim<CR>
nmap <silent> <leader>cm :e $CONFIGPATH/config/mruclose.vim<CR>
nmap <silent> <leader>cw :e $CONFIGPATH/config/mswin.vim<CR>
nmap <silent> <leader>cn :e $CONFIGPATH/config/nvim.vim<CR>
nmap <silent> <leader>co :e $CONFIGPATH<CR>

" Use C-[hjkl] to navigate between splits
nmap <silent> <C-k> :wincmd k<CR>
nmap <silent> <C-j> :wincmd j<CR>
nmap <silent> <C-h> :wincmd h<CR>
nmap <silent> <C-l> :wincmd l<CR>

" Filetypes
nmap <silent> <leader><leader>json <cmd>set filetype=json<CR>
nmap <silent> <leader><leader>ts <cmd>set filetype=typescript<CR>
nmap <silent> <leader><leader>js <cmd>set filetype=javascript<CR>

" Tabs
nnoremap <silent> <C-1> <cmd>tabn 1<CR>
nnoremap <silent> <C-2> <cmd>tabn 2<CR>
nnoremap <silent> <C-3> <cmd>tabn 3<CR>
nnoremap <silent> <C-4> <cmd>tabn 4<CR>
nnoremap <silent> <C-w><C-w> <cmd>tabc<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                                   Lazy                                   """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <silent> <leader>ll <cmd>Lazy<CR>
nmap <silent> <leader>lp <cmd>Lazy profile<CR>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                                 Debugger                                 """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Debugger
nmap <silent> <F4> <cmd>lua require('dap').pause()<CR>
nmap <silent> <F5> <cmd>lua require('dap.ext.vscode').load_launchjs()<CR><cmd>lua require('dap').continue()<CR>
nmap <silent> <F6> <cmd>lua require('dap').terminate()<CR>
" nmap <silent> <F9> <cmd>lua require('dap').toggle_breakpoint()<CR>
" nmap <silent> <C-F9> <cmd>lua require('dap').set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>
nmap <silent> <F9> <cmd>lua require('persistent-breakpoints.api').toggle_breakpoint()<CR>
nmap <silent> <C-F9> <cmd>lua require('persistent-breakpoints.api').set_conditional_breakpoint()<CR>
nmap <silent> <F10> <cmd>lua require('dap').step_over()<CR>
nmap <silent> <F11> <cmd>lua require('dap').step_into()<CR>
nmap <silent> <S-F11> <cmd>lua require('dap').step_out()<CR>
nmap <silent> <F12> <cmd>lua require('dap').run_to_cursor()<CR>
nmap <silent> <leader>dl <cmd>lua require('dap').list_breakpoints()<CR><cmd>copen<CR>
nmap <silent> <leader>de <cmd>lua require('dap').set_exception_breakpoints()<CR>
nmap <silent> <leader>ds <cmd>lua print(require('dap').status())<CR>
nmap <silent> <leader>du <cmd>lua require('dapui').toggle()<CR>
nmap <silent> <leader>db <cmd>lua require('dap').set_exception_breakpoints({ 'all' })<CR>
lua vim.fn.sign_define('DapBreakpointCondition', {text = '🤔', texthl = '', linehl = '', numhl = ''})
lua vim.fn.sign_define('DapBreakpoint', {text = '🟦', texthl = '', linehl = '', numhl = ''})
lua vim.fn.sign_define('DapBreakpointRejected', {text = '🟥', texthl = '', linehl = '', numhl = ''})
lua vim.fn.sign_define('DapStopped', {text = '👉', texthl = '', linehl = '', numhl = ''})

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                                    IDE                                   """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Trouble
map <silent> <leader>qe :Trouble<CR>

" NvimTree
"map <silent> <F2> :NvimTreeToggle<CR>
"map <silent> <F3> :NvimTreeFindFile<CR>

" Neotree
map <silent> <F2> :Neotree toggle last<CR>
map <silent> <F3> :Neotree reveal<CR>
map <silent> <leader><F1> :Neotree focus filesystem<CR>
map <silent> <leader><F2> :Neotree focus buffers<CR>
map <silent> <leader><F3> :Neotree focus git_status<CR>

" Overseer
nmap <silent> <leader>ol <cmd>OverseerToggle<CR>
nmap <silent> <leader>ot <cmd>OverseerToggle<CR>
nmap <silent> <leader>oi <cmd>OverseerInfo<CR>
nmap <silent> <leader>ob <cmd>OverseerBuild<CR>
nmap <silent> <leader>or <cmd>OverseerRun<CR>
nmap <silent> <leader>tr <cmd>lua require('neotest').overseer.run({})<CR>

" Sessions
lua << EOF
    function get_cwd_as_name()
      local dir = vim.fn.getcwd(0)
      return dir:gsub('[^A-Za-z0-9]', '_')
    end
EOF
augroup SessionHooks
    autocmd!
    autocmd User SessionLoadPre lua for _, task in ipairs(require('overseer').list_tasks({})) do task:dispose(true) end
    "autocmd User SessionLoadPost lua require('nvim-tree.api').tree.change_root(vim.fn.getcwd())
    "autocmd User SessionLoadPost lua require('nvim-tree.api').tree.toggle({ focus = false })
    autocmd User SessionLoadPost lua require('overseer').load_task_bundle(get_cwd_as_name(), { ignore_missing = true, autostart = false })
    autocmd User SessionSavePre lua require('overseer').save_task_bundle(get_cwd_as_name(), nil, { on_conflict = 'overwrite' })
augroup END

" Rest Client
nmap <silent> <leader><leader>http :set filetype=http<CR>:lua require('rest-nvim').run()<CR>
augroup HttpRestClient
    autocmd!
    nnoremap <silent> <leader>hr :lua require('rest-nvim').run(true)<CR>
    nnoremap <silent> <leader>hl :lua require('rest-nvim').last()<CR>
augroup END


" Neotest
nnoremap <silent> <leader>n <cmd>lua require('neogen').generate()<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                                   Git                                    """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>hs <cmd>lua require('gitsigns').stage_hunk()<CR>
nnoremap <leader>hr <cmd>lua require('gitsigns').reset_hunk()<CR>
vnoremap <leader>hs <cmd>lua require('gitsigns').stage_hunk({ vim.fn.line('.'), vim.fn.line('v')})<CR>
vnoremap <leader>hr <cmd>lua require('gitsigns').reset_hunk({ vim.fn.line('.'), vim.fn.line('v')})<CR>
nnoremap <leader>hu <cmd>lua require('gitsigns').undo_stage_hunk()<CR>
nnoremap <leader>hR <cmd>lua require('gitsigns').reset_buffer()<CR>
nnoremap <leader>hp <cmd>lua require('gitsigns').preview_hunk()<CR>
nnoremap <leader>b <cmd>BlameToggle<CR>
nnoremap <leader>hd <cmd>lua require('gitsigns').diffthis()<CR>
nnoremap <leader>hD <cmd>lua require('gitsigns').diffthis('~')<CR>
nnoremap <leader>td <cmd>lua require('gitsigns').toggle_deleted()<CR>
nnoremap ]c <cmd>lua require('gitsigns').next_hunk()<CR>
nnoremap [c <cmd>lua require('gitsigns').prev_hunk()<CR>
nnoremap <leader>hl <cmd>GitLink<CR>
vnoremap <leader>hL <cmd>GitLink blame<CR>
nnoremap <leader>hh <cmd>Neogit<CR>

nnoremap <leader>vh <cmd>DiffviewFileHistory<CR>
nnoremap <leader>vf <cmd>DiffviewFileHistory %<CR>
nnoremap <leader>v% <cmd>DiffviewFileHistory %<CR>
nnoremap <leader>vv <cmd>DiffviewOpen<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                               Interactions                               """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ripgrep
vnoremap <silent> <C-8> y<Esc>:Rg <C-R>"<CR>
nnoremap <silent> <C-8> :Rg<CR>

" Comment
nnoremap <silent> t <Plug>(comment_toggle_linewise_current)
nnoremap <silent> <C-T> <Plug>(comment_toggle_blockwise_current)
vnoremap <silent> t <Plug>(comment_toggle_linewise_visual)
vnoremap <silent> <C-T> <Plug>(comment_toggle_blockwise_visual)


" Telescope
nnoremap <silent> <C-p> <cmd>Telescope find_files<cr>
nnoremap <silent> <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <silent> <leader>fo <cmd>lua require('telescope.builtin').live_grep({ grep_open_files = true })<cr>
nnoremap <silent> <leader>ff <cmd>Telescope current_buffer_fuzzy_find<cr>
nnoremap <silent> <leader>fs <cmd>Telescope grep_string<cr>
nnoremap <silent> <leader>fq <cmd>Telescope quickfix<cr>
nnoremap <silent> <leader>fQ <cmd>Telescope quickfixhistory<cr>
nnoremap <silent> <leader>fr <cmd>Telescope registers<cr>
nnoremap <silent> <leader>fb <cmd>Telescope buffers<cr>
nnoremap <silent> <leader>fh <cmd>Telescope help_tarequire('gitsigns')<cr>
nnoremap <silent> <leader>ftt <cmd>Telescope git_commits<cr>
nnoremap <silent> <leader>ftb <cmd>Telescope git_bcommits<cr>
nnoremap <silent> <leader>fts <cmd>Telescope git_status<cr>
nnoremap <silent> <leader>fl <cmd>Telescope builtin<cr>
nnoremap <silent> <leader>sl <cmd>SessionManager load_session<cr>
nnoremap <silent> <leader>ss <cmd>SessionManager save_current_session<cr>
nnoremap <silent> <leader>sd <cmd>SessionManager delete_session<cr>

" Color picker
nnoremap <silent> <leader>ep :CccPick<CR>

" Treesj (join / split funcitons
nnoremap <silent> <leader>m :TSJToggle<CR>

" Treesitter
nnoremap <silent> <leader>hi :TSHighlightCapturesUnderCursor<CR>
nnoremap <silent> <leader>hp :TSPlaygroundToggle<CR>

" MoveLine
nnoremap <silent> <A-Up> :MoveLine(-1)<CR>
nnoremap <silent> <A-Down> :MoveLine(1)<CR>
vnoremap <silent> <A-Up> :MoveBlock(-1)<CR>
vnoremap <silent> <A-Down> :MoveBlock(1)<CR>

" Quack
nnoremap <silent> <leader>= <cmd>lua require("duck").hatch()<CR>
nnoremap <silent> <leader>- <cmd>lua require("duck").cook()<CR>

" Harpoon
nnoremap <silent> <leader>1 <cmd>lua require("harpoon"):list():select(1)<CR>
nnoremap <silent> <leader>2 <cmd>lua require("harpoon"):list():select(2)<CR>
nnoremap <silent> <leader>3 <cmd>lua require("harpoon"):list():select(3)<CR>
nnoremap <silent> <leader>4 <cmd>lua require("harpoon"):list():select(4)<CR>
nnoremap <silent> <leader>qh <cmd>lua require("harpoon").ui:toggle_quick_menu(require('harpoon'):list())<CR>
nnoremap <silent> <leader>a <cmd>lua require("harpoon"):list():add()<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                                    LSP                                   """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
lua << EOF
  function code_action_apply_first()
    local diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
    if not next(diagnostics) then
      diagnostics = vim.diagnostic.get(0)
    end

    if not next(diagnostics) then
      print('No code actions available')
      return
    end

    local range
    if diagnostics[1].range then
      range = {
        start = { diagnostics[1].range.start.line + 1, diagnostics[1].range.start.character+ 1 },
        ['end'] = { diagnostics[1].range['end'].line + 1, diagnostics[1].range['end'].character+ 1 }
      }
    else
      range = { 
        start = { diagnostics[1].lnum + 1, diagnostics[1].col + 1},
        ['end'] = { diagnostics[1].lnum + 1 , diagnostics[1].end_col+ 1 }
      }
    end

    isFirst = { first = true }
    vim.lsp.buf.code_action({
      context = {
        diagnostics = { diagnostics[1] }
      },
      range = range,
      filter = function(ix) 
        local wasFirst = isFirst.first
        isFirst.first = false
        return wasFirst
      end,
      apply = true
    })
  end
EOF

nnoremap <silent> [g :lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> ]g :lua vim.diagnostic.goto_next()<CR>
nnoremap <silent> [e :lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> ]e :lua vim.diagnostic.goto_next()<CR>
nnoremap <silent> K :lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <A-k><A-c> :lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> <C-.> :lua code_action_apply_first()<CR>
nnoremap <silent> <A-k><A-d> <cmd>lua vim.lsp.buf.format()<CR>
nnoremap <silent> <C-'> :lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <C-]> :lua vim.lsp.buf.definition()<CR>
nnoremap <silent> <C-;> :lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <C-\> :lua vim.lsp.buf.references()<CR>
nnoremap <silent> <leader>rn :lua vim.lsp.buf.rename()<CR>

augroup Lsp
  autocmd!
  " Automatically open diagnostics window after updatetime (300)ms
  autocmd CursorHold * lua vim.diagnostic.open_float({ scope = 'cursor', focusable = false })
augroup end

" Typescript specific
augroup TSTools
  autocmd!
  autocmd FileType typescript,javascript nnoremap <buffer> <silent> <A-k><A-u> :TypescriptRemoveUnused<CR>
  autocmd FileType typescript,javascript nnoremap <buffer> <silent> <A-k><A-s> :TypescriptOrganizeImports<CR>
  autocmd FileType typescript,javascript nnoremap <buffer> <silent> <A-k><A-i> :TypescriptAddMissingImports<CR>
  autocmd FileType typescript,javascript nnoremap <buffer> <silent> <A-k><A-r> :TypescriptRenameFile<CR>
  " autocmd FileType typescript,javascript nnoremap <buffer> <silent> <C-]> :TSToolsGoToSourceDefinition<CR>
augroup end

augroup Csharp
    autocmd!
    autocmd FileType cs nnoremap <buffer> <silent> <C-]> <CMD>lua require('omnisharp_extended').lsp_definition()<CR>
    autocmd FileType cs nnoremap <buffer> <silent> <leader><C-]> <CMD>lua require('omnisharp_extended').lsp_type_definition()<CR>
    autocmd FileType cs nnoremap <buffer> <silent> <C-]> <CMD>lua require('omnisharp_extended').lsp_definition()<CR>
    autocmd FileType cs nnoremap <buffer> <silent> <C-\> <CMD>lua require('omnisharp_extended').lsp_references()<CR>
    autocmd FileType cs nnoremap <buffer> <silent> <C-;> <CMD>lua require('omnisharp_extended').lsp_implementation()<CR>
augroup end

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""                           Config finalizations                           """
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" WebDev Icons fix: after a re-source, fix syntax matching issues (concealing brackets):
if exists('g:loaded_webdevicons')
    call webdevicons#refresh()
endif

colorscheme dracula
