return {
  'OXY2DEV/markview.nvim',
  ft = { 'markdown' },
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
    'gunasekar/markview-smart-tables.nvim',
  },
  config = function()
    -- Fit + word-wrap wide tables so `wrap` doesn't shatter columns.
    require('markview-smart-tables').setup({
      wrap_width = 0.9,
      wrap_minwidth = 5,
    })
    require('markview').setup({
      preview = {
        filetypes = { 'markdown' },
        ignore_buftypes = {},
        -- Reveal real source under the cursor instead of a half-broken
        -- fitted table; pretty render returns when the cursor leaves.
        hybrid_modes = { 'n', 'i', 'v', 'V' },
      },
      markdown = {
        -- Don't add virtual indentation to previewed lists. Otherwise the
        -- rendered list sits `shift_width` spaces right of the real source,
        -- and hybrid mode "unindents" it back the moment the cursor enters.
        list_items = {
          shift_width = 0,
        },
      },
      renderers = {
        markdown_table = function(buffer, item)
          require('markview-smart-tables').render(buffer, item)
        end,
      },
    })
  end,
}
