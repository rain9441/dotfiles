local M = {
  {
    'jremmen/vim-ripgrep',
    cmd = 'Rg',
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
              ['<C-[>'] = require('telescope.actions').cycle_history_prev,
              ['<C-]>'] = require('telescope.actions').cycle_history_next,
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
    config = function() require('nvim-surround').setup({}) end,
  },
  {
    'gennaro-tedesco/nvim-peekup',
    event = 'VeryLazy',
  },
  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    config = function()
      require('Comment').setup({
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
      })
    end,
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
    config = function()
      require('neogen').setup({
        enabled = true,
        languages = {
          javascript = {
            template = {
              annotation_convention = 'custom',
              custom = {
                { nil, '/** $1 */',       { no_results = true, type = { 'func', 'class' } } },
                { nil, '/** @type $1 */', { no_results = true, type = { 'type' } } },
                { nil, '/** $1 */',       { type = { 'class', 'func', 'type' } } },
              },
            },
          },
          typescript = {
            template = {
              annotation_convention = 'custom',
              custom = {
                { nil, '/** $1 */',       { no_results = true, type = { 'func', 'class' } } },
                { nil, '/** @type $1 */', { no_results = true, type = { 'type' } } },
                { nil, '/** $1 */',       { type = { 'class', 'func', 'type' } } },
              },
            },
          },
        },
      })
    end,
  },
  {
    'tamton-aquib/duck.nvim',
    config = function() require('duck').setup({ speed = 2 }) end,
  },
  {
    'fedepujol/move.nvim',
    cmd = { 'MoveLine', 'MoveBlock' },
    config = function() require('move').setup({}) end,
  },
  {
    'ThePrimeagen/harpoon',
    event = 'VeryLazy',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function() require('harpoon').setup({}) end,
  },
  -- {
  --   'uga-rosa/ccc.nvim',
  --   config = function()
  --     require('ccc').setup({
  --       -- Your preferred settings
  --       -- Example: enable highlighter
  --       highlighter = {
  --         auto_enable = true,
  --         lsp = true,
  --       },
  --     })
  --   end
  -- },
}

return M
