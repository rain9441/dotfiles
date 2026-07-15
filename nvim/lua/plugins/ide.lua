local M = {
  {
    'L3MON4D3/LuaSnip',
    config = function()
      require('luasnip').setup({
        update_events = { 'TextChanged', 'TextChangedI' },
        enable_autosnippets = true,
      })

      require('luasnip.loaders.from_vscode').load()
      require('luasnip.loaders.from_snipmate').load()
    end,
  },
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
    end,
  },
  {
    'folke/todo-comments.nvim',
    cmd = { 'TodoQuickFix', 'TodoTelescope', 'TodoTrouble', 'TodoLocList' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },
  {
    'stevearc/aerial.nvim',
    cmd = 'AerialToggle',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('aerial').setup({
        layout = {
          default_direction = 'left',
          attach_mode = 'global',
        },
      })
    end,
  },
  {
    'OXY2DEV/markview.nvim',
    ft = { 'markdown', 'codecompanion' },
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
          filetypes = { 'markdown', 'codecompanion' },
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
    'stevearc/oil.nvim',
    opts = {},
  },
  {
    'duqcyxwd/stringbreaker.nvim',
    cmd = { 'BreakString', 'PreviewString', 'SaveString', 'SyncString', 'BreakStringCancel' },
    opts = {},
  },
  {
    'barrett-ruth/live-server.nvim',
    cmd = { 'LiveServerStart', 'LiveServerStop', 'LiveServerToggle' },
    opts = {},
  },
  {
    'selimacerbas/mermaid-playground.nvim',
    dependencies = { 'barrett-ruth/live-server.nvim' },
    cmd = { 'MermaidPreviewStart', 'MermaidPreviewStop', 'MermaidPreviewRefresh' },
    opts = {
      overwrite_index_on_start = false,
    },
  },
  {
    'Piotr1215/presenterm.nvim',
    lazy = false,
    build = false,
    opts = {
      picker = {
        provider = 'snacks',
      },
      preview = {
        command = 'presenterm -xX',
        presentation_preview_sync = true,
      },
    },
  },
  {
    'jellydn/hurl.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    ft = 'hurl',
    opts = {
      show_notification = true,
      env_file = {
        'vars.env',
        'local.vars.env',
      },
    },
  },
  {
    'zeioth/garbage-day.nvim',
    event = 'VeryLazy',
    opts = {},
  },
}

return M
