" Exit quickly if already running or when 'compatible' is set. {{{1
"
" Create commands
command! BufferCloseAndGoToMRU :call BufferCloseAndGoToMRU()
command! BufferCloseOthers :call BufferCloseOthers()
command! BufferCloseAll :call BufferCloseAll()

" Script variables {{{2
let s:MRU_Exclude_List = [] "["[BufExplorer]","__MRU_Files__","[Buf\ List]",]
let s:MRUList = []
let s:name = 'hgiadfasef' "'[BufExplorer]'

" Setup the autocommands that handle the MRUList and other stuff. {{{2

augroup BufferCloseCommands
    autocmd!
    autocmd VimEnter * call s:Setup()
    " Reset MRUList and buffer->tab associations after loading a session. {{{2
    autocmd SessionLoadPost * call s:Reset()
augroup END

" Setup {{{2
function! s:Setup()
    call s:Reset()

    " Now that the MRUList is created, add the other autocmds.
    augroup BufferClose
        autocmd!
        autocmd BufEnter,BufNew * call s:ActivateBuffer()
        autocmd BufLeave * call s:LeaveBuffer()
        autocmd BufWipeOut * call s:DeactivateBuffer(1)
        autocmd BufDelete * call s:DeactivateBuffer(0)
    augroup END
endfunction

" Reset {{{2
function! s:Reset()
    " Build initial MRUList. This makes sure all the files specified on the
    " command line are picked up correctly. Check buffers exist so this also
    " works after wiping buffers and loading a session (e.g. sessionman.vim)
    let s:MRUList = filter(range(1, bufnr('$')), 'bufexists(v:val) && BufferCloseShouldIgnore(v:val) == 0')
endfunction

" ActivateBuffer {{{2
function! s:ActivateBuffer()
    let _bufnr = bufnr("%")
    call s:MRUPush(_bufnr)
endfunction

" DeactivateBuffer {{{2
function! s:DeactivateBuffer(remove)
    let _bufnr = str2nr(expand("<abuf>"))
    call s:MRUPop(_bufnr)
endfunction

function! s:LeaveBuffer()
    let _bufnr = bufnr("%")
    let _bufinfo = getbufinfo(_bufnr)
    if empty(getbufvar(_bufnr, "&buftype")) == 1 && empty(getbufvar(_bufnr, "name")) && _bufinfo[0].changed == 0 && len(s:MRUList) > 1
        " execute "keepalt silent bd" _bufnr
    endif
endfunction

" MRUPop {{{2
function! s:MRUPop(bufnr)
    call filter(s:MRUList, 'v:val != '.a:bufnr)
endfunction

" MRUPush {{{2
function! s:MRUPush(buf)
    " Skip temporary buffer with buftype set. Don't add the BufExplorer window
    " to the list.
    if s:ShouldIgnore(a:buf) == 1
        return
    endif

    " Remove the buffer number from the list if it already exists.
    call s:MRUPop(a:buf)

    " Add the buffer number to the head of the list.
    call insert(s:MRUList, a:buf)
endfunction

" ShouldIgnore {{{2
function! s:ShouldIgnore(buf)
    " Ignore temporary buffers with buftype set.
    if empty(getbufvar(a:buf, "&buftype")) == 0
        return 1
    endif

    if getbufinfo(a:buf)[0].listed != 1
        return 1
    endif

    " Ignore buffers with no name.
    "if empty(bufname(a:buf)) == 1
    "    return 1
    "endif

    " Ignore the BufExplorer buffer.
    if fnamemodify(bufname(a:buf), ":t") == s:name
        return 1
    endif

    " Ignore any buffers in the exclude list.
    if index(s:MRU_Exclude_List, bufname(a:buf)) >= 0
        return 1
    endif

    " Else return 0 to indicate that the buffer was not ignored.
    return 0
endfunction

function! BufferCloseShouldIgnore(buf)
    return s:ShouldIgnore(a:buf)
endfunction

function! BufferCloseAndGoToMRU()
    return s:BufferCloseSingle()
endfunction

function! s:BufferCloseSingle()
    if s:ShouldIgnore('%')
        return
    endif
    
    let l:isModified = (getbufvar('%', '&modified') > 0)

    if l:isModified
        echo 'Unable to close buffer due to unsaved changes'
        return
    endif


    if len(s:MRUList) > 1
        let l:bufToRemove = bufnr('%')
        execute "keepalt silent b!" s:MRUList[1]
        execute "keepalt silent bd" l:bufToRemove
    elseif len(s:MRUList) == 1
        let l:bufToRemove = bufnr('%')
        execute "keepalt silent enew"
        execute "keepalt silent bd" l:bufToRemove
    endif
endfunction

function! BufferCloseOthers()
    let filteredBuffers = filter(getbufinfo(), 'v:val.listed && v:val.bufnr != bufnr("%") && v:val.changed == 0')
    let bufferNumbers = map(filteredBuffers, 'v:val.bufnr')
    if len(bufferNumbers) > 0
        execute 'bd! ' . join(bufferNumbers)
    endif
endfunction

function! BufferCloseAll()

    let filteredBuffers = filter(getbufinfo(), 'v:val.listed && v:val.changed == 0')
    let bufferNumbers = map(filteredBuffers, 'v:val.bufnr')
    if len(bufferNumbers) == 1 && bufferNumbers[0] == bufnr()
        call s:BufferCloseSingle()
    elseif len(bufferNumbers) > 0
        execute 'bd! ' . join(bufferNumbers)
    endif
endfunction

let s:init = 0
if s:init == 0
    let s:init = 1
    call s:Setup()
endif

