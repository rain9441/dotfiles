local M = {
  {
    'jremmen/vim-ripgrep',
    cmd = 'Rg',
    opts = {},
  },
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    config = function()
      require('telescope').setup({
        file_ignore_patterns = { 'node_modules' },
        defaults = vim.tbl_extend('force', require('telescope.themes').get_ivy(), {
          sorting_strategy = 'ascending',
          layout_config = {
            prompt_position = 'top',
          },
          mappings = {
            i = {
              ['<C-k>'] = require('telescope.actions').move_selection_previous,
              ['<C-j>'] = require('telescope.actions').move_selection_next,
              ['<C-u>'] = require('telescope.actions').results_scrolling_up,
              ['<C-d>'] = require('telescope.actions').results_scrolling_down,
              ['<C-]>'] = require('telescope.actions').cycle_history_prev,
              ['<C-\\>'] = require('telescope.actions').cycle_history_next,
              ['<C-Tab>'] = require('telescope.actions').toggle_selection,
              ['<C-S-Tab>'] = require('telescope.actions').toggle_selection,
            },
          },
        }),
        pickers = {
          buffers = {
            path_display = { 'smart', 'shorten' },
            ignore_current_buffer = true,
            sort_mru = true,
            sorting_strategy = 'ascending',
            layout_config = {
              prompt_position = 'top',
            },
            mappings = {
              i = {
                ['<C-S-Tab>'] = require('telescope.actions').move_selection_previous,
                ['<C-Tab>'] = require('telescope.actions').move_selection_next,
              },
            },
          },
        },
      })
    end,
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
}

return M
