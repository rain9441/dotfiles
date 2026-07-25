local M = {
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    opts = {},
  },
  {
    'Shatur/neovim-session-manager',
    dependencies = { 'nvim-lua/plenary.nvim' },
    lazy = false,
    config = function()
      require('session_manager').setup({
        autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
        -- autosave_last_session = false,
        autosave_only_in_session = true,
        autosave_ignore_buftypes = { 'nofile' },
      })

      -- session_manager.utils.save_session force-deletes every non-file
      -- buffer (Neo-tree included) *before* it fires the `SessionSavePre`
      -- User autocmd, so hooking that event is too late to catch Neo-tree's
      -- window while its buffer still carries the tell-tale filetype. Wrap
      -- the save function itself so Neo-tree gets closed first, covering
      -- both manual saves and the VimLeavePre autosave.
      local session_utils = require('session_manager.utils')
      local save_session = session_utils.save_session
      session_utils.save_session = function(filename)
        require('custom/neotree-safe').close_before_session_save()
        save_session(filename)
      end
    end,
  },
  {
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
  },
  -- {
  --   'esmuellert/nvim-eslint',
  --   lazy = false,
  --   opts = {},
  -- },
  {
    'lukas-reineke/indent-blankline.nvim',
    lazy = false,
    main = 'ibl',
    opts = {},
  },
  {
    'kevinhwang91/nvim-bqf',
    event = 'VeryLazy',
    cmd = 'BufWinEnter quickfix',
    opts = {},
  },
  {
    'zeioth/garbage-day.nvim',
    event = 'VeryLazy',
    opts = {},
  },
}

return M
