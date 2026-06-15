-- winter.nvim — Neovim integration for winter workspaces.
-- Integrations: a snacks.nvim worktrees picker (<leader>fw "find workspace"),
-- and the cross-repo feature diff viewer (:WinterDiff) rendered via delta.lua.
--
-- Tracks the published plugin over GitHub. To iterate on a live local checkout,
-- swap the `'paul-gross/winter-nvim',` spec for
-- `dir = vim.fn.expand('~/projects/winter-workspace/alpha/winter-nvim')`.

-- Buffer-local keys for a :WinterDiff buffer. The plugin exposes the verbs as
-- buffer-local commands; the keys live here, in my config. Bound on the
-- `User WinterDiffOpened` event so nothing is imposed globally.
vim.api.nvim_create_autocmd('User', {
  pattern = 'WinterDiffOpened',
  callback = function(ev)
    local buf = ev.data.buf
    -- Defer with vim.schedule so these win over any FileType/treesitter
    -- autocmds that bind buffer-local keys (]f, q, ...) as delta attaches.
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      local map = function(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true })
      end
      map('n', ']c', '<cmd>WinterDiffNextHunk<cr>')
      map('n', '[c', '<cmd>WinterDiffPrevHunk<cr>')
      map('n', ']f', '<cmd>WinterDiffNextFile<cr>')
      map('n', '[f', '<cmd>WinterDiffPrevFile<cr>')
      map('n', 'R', '<cmd>WinterDiffRefresh<cr>')
      map('n', '<leader>wd', '<cmd>WinterDiffDrawer<cr>')
      -- goto-file family (standard nvim conventions), buffer-local to the diff
      map('n', 'gf', '<cmd>WinterDiffGotoFile<cr>')
      map('n', '<C-w>f', '<cmd>WinterDiffGotoFileSplit<cr>')
      map('n', '<C-w>gf', '<cmd>WinterDiffGotoFileTab<cr>')
      map('n', '<C-w>v', '<cmd>WinterDiffGotoFileVSplit<cr>')
      -- prompt-yank owns the ,y* prefix, so the diff-buffer yank lives on gy
      map('n', 'gy', '<cmd>WinterDiffYank<cr>')
      map('x', 'gy', ':WinterDiffYank<cr>')
    end)
  end,
})

local M = {
  {
    'paul-gross/winter-nvim',
    dependencies = { 'folke/snacks.nvim', 'kokusenz/delta.lua' },
    lazy = false,
    opts = {},
  },
}

return M
