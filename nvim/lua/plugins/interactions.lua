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
    'danymat/neogen',
    opts = {
      enabled = true,
      languages = {
        javascript = {
          template = {
            annotation_convention = 'custom',
            custom = {
              { nil, '/** $1 */', { no_results = true, type = { 'func', 'class' } } },
              { nil, '/** @type $1 */', { no_results = true, type = { 'type' } } },
              { nil, '/** $1 */', { type = { 'class', 'func', 'type' } } },
            },
          },
        },
        typescript = {
          template = {
            annotation_convention = 'custom',
            custom = {
              { nil, '/** $1 */', { no_results = true, type = { 'func', 'class' } } },
              { nil, '/** @type $1 */', { no_results = true, type = { 'type' } } },
              { nil, '/** $1 */', { type = { 'class', 'func', 'type' } } },
            },
          },
        },
      },
    },
  },
  {
    'fedepujol/move.nvim',
    cmd = { 'MoveLine', 'MoveBlock' },
    opts = {},
  },
  {
    'Redoxahmii/json-to-types.nvim',
    build = 'npm i', -- Replace `npm` with your preferred package manager (e.g., yarn, pnpm).
    ft = 'json',
    opts = {},
  },
  {
    'hat0uma/csvview.nvim',
    cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle' },
    opts = {},
  },
  {
    'chrisgrieser/nvim-chainsaw',
    event = 'VeryLazy',
    opts = {
      marker = '[Log]',
    },
  },
  {
    'gbprod/substitute.nvim',
    lazy = false,
    opts = {},
  },
  {
    'Wansmer/sibling-swap.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      use_default_keymaps = false,
    },
  },
  {
    'cbochs/grapple.nvim',
    lazy = false,
  },
  {
    'tpope/vim-abolish',
    lazy = false,
  },
  {
    'LudoPinelli/comment-box.nvim',
    event = 'VeryLazy',
    opts = {
      comment_style = 'line',
      doc_width = 120, -- width of the document
      box_width = 100, -- width of the boxes
      line_width = 96, -- width of the lines
    },
  },
}

return M
