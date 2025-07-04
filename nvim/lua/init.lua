vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.diagnostic.config({
  virtual_text = false,
  float = {
    header = "",
    source = 'if_many',
    border = 'single',
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

local function flatten(t1)
  local res = {}
  for _, x in ipairs(t1) do
    if type(x) ~= 'table' then
      for _, y in ipairs(x) do
        table.insert(res, y)
      end
    else
      table.insert(res, x)
    end
  end
  return res
end

local local_lazy = _G.local_lazy;
if local_lazy == nil then
  local_lazy = {}
end

require('lazy').setup(
  flatten({
    local_lazy,
    require('plugins/ai'),
    require('plugins/cmp'),
    require('plugins/core'),
    require('plugins/dadbod'),
    require('plugins/debugger'),
    require('plugins/git'),
    require('plugins/hydra'),
    require('plugins/ide'),
    require('plugins/interactions'),
    require('plugins/lsp'),
    require('plugins/misc'),
    -- require('plugins/neo-tree'),
    require('plugins/overseer'),
    require('plugins/snacks'),
    require('plugins/telescope'),
    require('plugins/tree-sitter'),
    require('plugins/ui'),
  }),
  {
    defaults = { lazy = true },
    performance = {
      rtp = {
        reset = false,
      },
    },
  }
)
