vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Must be set before lazy.nvim loads (it snapshots mapleader at setup time).
-- The canonical value lives in vim/keys.vim; this just gets it in place early.
vim.g.mapleader = ','

vim.diagnostic.config({
  virtual_text = false,
  float = {
    header = '',
    source = 'if_many',
    border = "single",
    focusable = false,
  },
})
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local local_lazy = _G.local_lazy
if local_lazy == nil then
  local_lazy = {}
end

require('lazy').setup(
  {
    local_lazy,
    { import = 'plugins' },
  },
  {
    defaults = { lazy = true },
    performance = {
      rtp = {
        reset = false,
      },
    },
  }
)
