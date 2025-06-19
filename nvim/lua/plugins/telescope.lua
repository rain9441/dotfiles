local M = {
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
}

return M
