-- Live markdown preview (iamcco/markdown-preview.nvim) in a chromeless
-- Chrome app window, scroll-synced to the cursor.
return {
  'iamcco/markdown-preview.nvim',
  ft = { 'markdown' },
  cmd = { 'MarkdownPreview', 'MarkdownPreviewStop', 'MarkdownPreviewToggle' },
  -- Downloads the prebuilt server binary; no node/yarn needed (node only
  -- exists behind lazy-loaded nvm in zsh, which nvim jobs don't see).
  build = 'cd app && ./install.sh v0.0.10', -- pinned: latest-tag lookup fails
  -- ,m keymap lives in vim/keys.vim
  init = function()
    vim.g.mkdp_theme = 'dark'
    vim.g.mkdp_auto_close = 0       -- keep preview when leaving the buffer
    vim.g.mkdp_combine_preview = 1  -- reuse one window across markdown buffers
    vim.g.mkdp_combine_preview_auto_refresh = 1
    vim.g.mkdp_echo_preview_url = 1
    vim.cmd([[
      function! MkdpOpenChromeApp(url) abort
        call jobstart(['google-chrome', '--app=' . a:url], {'detach': v:true})
      endfunction
    ]])
    vim.g.mkdp_browserfunc = 'MkdpOpenChromeApp'
  end,
}
