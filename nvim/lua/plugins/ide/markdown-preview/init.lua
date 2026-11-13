-- Live markdown preview (iamcco/markdown-preview.nvim) in a chromeless
-- Chrome app window, scroll-synced to the cursor.

-- Appended to the plugin's GitHub markdown.css: lift the 900px column cap
-- (#page-ctn in page.css) and stretch mermaid diagrams to the column width.
local css_overrides = [[

/* dotfiles overrides */
#page-ctn { max-width: 95vw; }
.mermaid svg { width: 100% !important; max-width: 100% !important; height: auto; }
]]

-- g:mkdp_markdown_css *replaces* the stock markdown.css, so build a combined
-- copy (stock + overrides) in the cache dir and point the plugin at that.
local function build_css(plugin_dir)
  local src = plugin_dir .. '/app/_static/markdown.css'
  local f = io.open(src, 'r')
  if not f then return nil end -- plugin not built yet; fall back to stock css
  local stock = f:read('*a')
  f:close()
  local dst = vim.fn.stdpath('cache') .. '/mkdp-markdown.css'
  local out = io.open(dst, 'w')
  if not out then return nil end
  out:write(stock, css_overrides)
  out:close()
  return dst
end

return {
  'iamcco/markdown-preview.nvim',
  ft = { 'markdown' },
  cmd = { 'MarkdownPreview', 'MarkdownPreviewStop', 'MarkdownPreviewToggle' },
  -- Downloads the prebuilt server binary; no node/yarn needed (node only
  -- exists behind lazy-loaded nvm in zsh, which nvim jobs don't see).
  build = 'cd app && ./install.sh v0.0.10', -- pinned: latest-tag lookup fails
  -- ,m keymap lives in vim/keys.vim
  init = function(plugin)
    vim.g.mkdp_theme = 'dark'
    vim.g.mkdp_auto_close = 0       -- keep preview when leaving the buffer
    vim.g.mkdp_combine_preview = 1  -- reuse one window across markdown buffers
    vim.g.mkdp_combine_preview_auto_refresh = 1
    vim.g.mkdp_echo_preview_url = 1
    -- Fixed port so Chrome remembers the app window's size and zoom level.
    vim.g.mkdp_port = '8090'

    local css = build_css(plugin.dir)
    if css then vim.g.mkdp_markdown_css = css end

    -- Setting this replaces the plugin defaults wholesale, so keep them all.
    vim.g.mkdp_preview_options = {
      mkit = vim.empty_dict(),
      katex = vim.empty_dict(),
      uml = vim.empty_dict(),
      -- passed straight to mermaid.initialize()
      maid = {
        themeVariables = { fontSize = '18px' },
        flowchart = { useMaxWidth = false },
        sequence = { useMaxWidth = false },
      },
      disable_sync_scroll = 0,
      sync_scroll_type = 'middle',
      hide_yaml_meta = 1,
      sequence_diagrams = vim.empty_dict(),
      flowchart_diagrams = vim.empty_dict(),
      content_editable = false,
      disable_filename = 0,
      toc = vim.empty_dict(),
    }

    vim.cmd([[
      function! MkdpOpenChromeApp(url) abort
        call jobstart(['google-chrome', '--app=' . a:url, '--window-size=1600,1200'], {'detach': v:true})
      endfunction
    ]])
    vim.g.mkdp_browserfunc = 'MkdpOpenChromeApp'
  end,
}
