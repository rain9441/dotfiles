local configPath = '~/.config/nvim'
if vim.fn.has('win') then
  configPath = '~/AppData/Local/nvim'
end

require('config/init')

vim.api.nvim_exec('source ' .. configPath .. '/lua/config/mruclose.vim', {})
vim.api.nvim_exec('source ' .. configPath .. '/lua/config/nvim.vim', {})
vim.api.nvim_exec('source ' .. configPath .. '/lua/config/mswin.vim', {})

local localVim = vim.fn.expand(configPath .. '/local.vim')
if vim.fn.filereadable(localVim) > 0 then
  vim.api.nvim_exec('source ' .. localVim, {})
end

local localLua = vim.fn.expand(configPath .. '/local.lua')
if vim.fn.filereadable(localLua) > 0 then
  dofile(localLua)
end
