local configPath = '~/.config/nvim'
if vim.fn.has('win') then
  configPath = '~/AppData/Local/nvim'
end

vim.g.configpath = configPath

-- If there are local lua files (gitignored), require those
local localLua = vim.fn.expand(configPath .. '/local.lua')
if vim.fn.filereadable(localLua) > 0 then
  local m = dofile(localLua)
  if m ~= nil and m.lazy ~= nil then
    _G.local_lazy = m.lazy
  end
end

-- core lua initialization
require('init')

vim.api.nvim_exec2('source ' .. configPath .. '/vim/mruclose.vim', {})
vim.api.nvim_exec2('source ' .. configPath .. '/vim/keys.vim', {})

-- If there are local vim files, source those
local localVim = vim.fn.expand(configPath .. '/local.vim')
if vim.fn.filereadable(localVim) > 0 then
  vim.api.nvim_exec2('source ' .. localVim, {})
end

