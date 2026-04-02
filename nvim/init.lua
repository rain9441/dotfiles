local configPath = '~/.config/nvim'
if vim.fn.has('win') > 0 or vim.fn.has('win32') > 0 then
  configPath = '~/AppData/Local/nvim'
end

vim.g.configpath = configPath

if vim.g.neovide then
  vim.g.neovide_input_macos_option_key_is_meta = "both"
  local keys = 'abcdefghijklnoprstuvwxyz'
  for i = 1, #keys do
    local k = keys:sub(i, i)
    for _, mode in ipairs({'n', 'i', 'v', 't', 'c'}) do
      vim.keymap.set(mode, '<D-' .. k .. '>', '<A-' .. k .. '>', { remap = true })
      vim.keymap.set(mode, '<D-' .. k:upper() .. '>', '<A-' .. k:upper() .. '>', { remap = true })
    end
  end
  for _, k in ipairs({'1','2','3','4','5','6','7','8','9','0','-','=','[',']','\\',';','\'',',','.','/','`'}) do
    for _, mode in ipairs({'n', 'i', 'v', 't', 'c'}) do
      vim.keymap.set(mode, '<D-' .. k .. '>', '<A-' .. k .. '>', { remap = true })
    end
  end
end

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
