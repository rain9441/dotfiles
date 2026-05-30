-- winter.nvim — Neovim integration for winter workspaces.
-- First integration: a snacks.nvim worktrees picker (<leader>fw "find workspace")
-- that fuzzy-finds any <env>/<repo> worktree or standalone repo and jumps into it.
--
-- Tracks the published plugin over GitHub. Swap the `'paul-gross/winter-nvim'`
-- spec for `dir = vim.fn.expand('~/projects/winter-workspace/alpha/winter-nvim')`
-- to load from a live local checkout instead.

local M = {
  {
    'paul-gross/winter-nvim',
    dependencies = { 'folke/snacks.nvim' },
    lazy = false,
    opts = {},
  },
}

return M
