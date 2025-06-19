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
    'chrisgrieser/nvim-puppeteer',
    ft = { 'javascript', 'typescript', 'js', 'ts' },
    init = function() vim.g.puppeteer_js_quotation_mark = "'" end,
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
      require('aerial').setup({})
      require('telescope').extensions.aerial.aerial()
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'codecompanion' },
    opts = {},
  },
  {
    'esmuellert/nvim-eslint',
    lazy = false,
    opts = {},
  },
  {
    'axkirillov/hbac.nvim',
    lazy = false,
    opts = { threshold = 8 },
  },
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
}

return M
