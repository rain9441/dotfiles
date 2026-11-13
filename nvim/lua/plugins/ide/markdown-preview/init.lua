-- Live markdown preview (iamcco/markdown-preview.nvim) in a chromeless
-- Chrome app window, scroll-synced to the cursor.

-- Look of the preview page. Each key becomes a --preview-<key> CSS variable
-- used by preview.css; `font` and `font-size` are also handed to mermaid.
local style = {
  ['font'] = '"RobotoMono Nerd Font", monospace',
  ['font-size'] = '14px',
  ['line-height'] = '1.6',
  ['max-width'] = '95vw',
  ['mermaid-padding'] = '2rem',
}

local here = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h')

-- g:mkdp_markdown_css replaces the stock markdown.css rather than adding to
-- it, so write stock + style variables + preview.css to one cached file.
-- Returns nil before the plugin is installed (the stock css is used then).
local function build_css(plugin_dir)
  local stock = plugin_dir .. '/app/_static/markdown.css'
  if vim.fn.filereadable(stock) == 0 then return nil end

  local keys = vim.tbl_keys(style)
  table.sort(keys)
  local vars = { '', ':root {' }
  for _, key in ipairs(keys) do
    table.insert(vars, ('  --preview-%s: %s;'):format(key, style[key]))
  end
  table.insert(vars, '}')

  local lines = vim.fn.readfile(stock)
  vim.list_extend(lines, vars)
  vim.list_extend(lines, vim.fn.readfile(here .. '/preview.css'))

  local out = vim.fn.stdpath('cache') .. '/mkdp-markdown.css'
  vim.fn.writefile(lines, out)
  return out
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
    vim.g.mkdp_port = '8090'        -- fixed so Chrome remembers window size/zoom
    vim.g.mkdp_markdown_css = build_css(plugin.dir)

    -- Setting this replaces the plugin's defaults wholesale, so all keys
    -- are listed; only `maid` differs from the defaults.
    vim.g.mkdp_preview_options = {
      mkit = vim.empty_dict(),
      katex = vim.empty_dict(),
      uml = vim.empty_dict(),
      -- Passed to mermaid.initialize(). The font is set here rather than in
      -- CSS so mermaid sizes node boxes for it.
      maid = {
        fontFamily = style.font,
        themeVariables = { fontFamily = style.font, fontSize = style['font-size'] },
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

    -- mkdp_browserfunc must name a Vimscript function.
    vim.cmd([[
      function! MkdpOpenChromeApp(url) abort
        call jobstart(['google-chrome', '--app=' . a:url, '--window-size=1600,1200'], {'detach': v:true})
      endfunction
    ]])
    vim.g.mkdp_browserfunc = 'MkdpOpenChromeApp'
  end,
}
