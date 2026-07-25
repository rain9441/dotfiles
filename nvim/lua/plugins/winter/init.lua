-- winter.nvim — Neovim integration for winter workspaces.
-- Integrations: a snacks.nvim worktrees picker (<leader>fw "find workspace"),
-- a status dashboard (:WinterDashboard, <leader>fd), and the cross-repo feature
-- diff viewer (:WinterDiff) rendered via codediff.nvim.
--
-- Tracks the published plugin over GitHub. To iterate on the plugin against a
-- live local checkout instead, swap the `'paul-gross/winter-nvim',` spec for
-- `dir = vim.fn.expand('~/projects/winter-workspace/<env>/winter-nvim'), name = 'winter-nvim',`.

-- Diff navigation keys are provided natively by codediff.nvim in its own diff
-- buffers — winter.nvim deliberately no longer exposes :WinterDiff* navigation
-- commands (next/prev hunk, goto-file, refresh, drawer, yank), so the old
-- `User WinterDiffOpened` buffer-local keymap handler was removed. Use codediff's
-- built-in keymaps inside the diff explorer instead.

return {
  'paul-gross/winter-nvim',
  dependencies = { 'folke/snacks.nvim', 'paul-gross/codediff.nvim' },
  lazy = false,
  opts = {
    -- Open the dashboard as a near-full-screen centered float rather than the
    -- default 15-line bottom dock.
    dashboard = {
      position = 'float',
      size = { width = 0.9, height = 0.9 },
    },
    -- Dashboard quick-diff (d / D) and :WinterDiff default to working-tree
    -- (dirty) changes rather than the diff against origin/<main>.
    diff = {
      mode = 'uncommitted',
    },
  },
  -- Dashboard (<leader>fd) and worktrees (<leader>fw) keymaps live in
  -- vim/keys.vim alongside the other <leader>f* finder bindings.
}
