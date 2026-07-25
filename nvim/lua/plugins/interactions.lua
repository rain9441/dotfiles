local M = {
  {
    'jremmen/vim-ripgrep',
    cmd = 'Rg',
    opts = {},
  },
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    opts = {
      padding = true,
      sticky = true,
      ignore = nil,
      toggler = {
        line = ',gc',
        block = ',gb',
      },
      opleader = {
        line = ',tc',
        block = ',tb',
      },
      mappings = {
        basic = true,
        extra = true,
      },
    },
  },
  {
    'Wansmer/treesj',
    cmd = 'TSJToggle',
    config = function()
      require('treesj').setup({
        use_default_keymaps = false,
        max_join_length = 150,
      })
      local langs = require('treesj.langs')
      langs.presets['javascript'].array.join.space_in_brackets = false
      langs.presets['typescript'].array.join.space_in_brackets = false
    end,
  },
  {
    'fedepujol/move.nvim',
    cmd = { 'MoveLine', 'MoveBlock' },
    opts = {},
  },
  {
    'gbprod/substitute.nvim',
    lazy = false,
    opts = {},
  },
}

return M
