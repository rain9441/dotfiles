local M = {
  -- Basics
  { 'nvim-tree/nvim-web-devicons', event = 'VeryLazy' },
  { 'ryanoasis/vim-devicons', event = 'VeryLazy' },
  {
    'Mofiqul/dracula.nvim',
    lazy = false,
    config = function()
      local colors = {
        bg = '#101116',
        fg = '#F8F8F2',
        fgdark = '#D8D8D2',
        cursorline = '#303137',
        selection = '#44475A',
        comment = '#6272A4',
        red = '#FF5555',
        orange = '#FFB86C',
        yellow = '#F1FA8C',
        green = '#50fa7b',
        purple = '#BD93F9',
        cyan = '#8BE9FD',
        pink = '#FF79C6',
        bright_red = '#FF6E6E',
        bright_green = '#69FF94',
        bright_yellow = '#FFFFA5',
        bright_blue = '#D6ACFF',
        bright_magenta = '#FF92DF',
        bright_cyan = '#A4FFFF',
        bright_white = '#FFFFFF',
        dark_red = '#331111',
        dark_green = '#103218',
        darker_red = '#190808',
        darker_green = '#08190c',
        menu = '#21222C',
        visual = '#3E4452',
        gutter_fg = '#4B5263',
        nontext = '#3B4048',
      }

      require('dracula').setup({
        colors = colors,
        overrides = {
          CursorLine = { bg = colors.cursorline },
          VertSplit = { fg = '#808080' },

          ['@variable.builtin'] = { fg = colors.orange },
          ['@property'] = { fg = colors.fgdark },

          TabLine = { fg = colors.fg, bg = colors.bg },
          TabLineSel = { fg = colors.bg, bg = colors.cyan, bold = true },
          TabLineFill = { fg = colors.fg, bg = colors.nontext },

          NvimTreeRootFolder = { fg = colors.bg, bg = colors.yellow, bold = true },
          NvimTreeCursorLine = { bg = colors.cursorline },
          NvimTreeVertSplit = { fg = '#808080' },
          NvimTreeNormal = { bg = colors.bg },
          NvimTreeGitDirty = { fg = colors.orange },
          NvimTreeGitNew = { fg = colors.green },

          NeoTreeNormal = { bg = colors.bg },
          NeoTreeNormalNC = { bg = colors.bg },

          TelescopeSelection = { bg = colors.cursorline },
          TelescopeMultiSelection = { bg = colors.cursorline },

          IlluminatedWordRead = { bg = '#505176' },
          IlluminatedWordWrite = { bg = '#505176' },
          IlluminatedWordText = { bg = '#505176' },

          -- CmpItemAbbr = { bg = '#505176' },
          CmpItemAbbrDeprecated = { fg = colors.white, bg = '' },
          CmpItemAbbrMatch = { fg = colors.cyan, bg = '' },
          CmpItemAbbr = { fg = colors.white, bg = '' },
          CmpItemKind = { fg = colors.white, bg = '' },

          NeogitHunkHeader = { fg = colors.bg, bg = colors.selection, bold = colors.bold },
          NeogitHunkHeaderHighlight = { fg = colors.bg, bg = colors.purple, bold = colors.bold },
          NeogitDiffContext = { fg = colors.fg, bg = colors.bg },
          NeogitDiffContextHighlight = { fg = colors.fg, bg = colors.bg },
          NeogitDiffAdd = { bg = colors.darker_green, fg = colors.green },
          NeogitDiffAddHighlight = { bg = colors.dark_green, fg = colors.bright_green },
          NeogitDiffDelete = { bg = colors.darker_red, fg = colors.red },
          NeogitDiffDeleteHighlight = { bg = colors.dark_red, fg = colors.bright_red },

          DiffviewDiffText = { bg = colors.darker_green, fg = colors.green },
          DiffAdd = { bg = colors.darker_green, fg = colors.green },
          DiffDelete = { bg = colors.darker_red, fg = colors.red },
        },
      })
    end,
  },
  {
    'Bekaboo/deadcolumn.nvim',
    event = 'VeryLazy',
    config = function()
      require('deadcolumn').setup({
        scope = 'buffer',
        modes = function(mode) return mode:find('^[nictRss\x13]') ~= nil end,
        blending = {
          threshold = 0.33,
        },
      })
    end,
  },
  {
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
    config = function() require('dressing').setup({}) end,
  },
  {
    'kevinhwang91/nvim-bqf',
    event = 'VeryLazy',
    cmd = 'BufWinEnter quickfix',
  },
  {
    'petertriho/nvim-scrollbar',
    event = 'VeryLazy',
    config = function() require('scrollbar').setup() end,
  },
  {
    'gen740/SmoothCursor.nvim',
    event = 'VeryLazy',
    config = function()
      require('smoothcursor').setup({
        fancy = {
          enable = true,
          head = { cursor = '▷', texthl = 'SmoothCursorGreen', linehl = nil },
          body = {
            { cursor = '', texthl = 'SmoothCursorGreen' },
            { cursor = '●', texthl = 'SmoothCursorAqua' },
            { cursor = '•', texthl = 'SmoothCursorAqua' },
            { cursor = '.', texthl = 'SmoothCursorBlue' },
          },
        },
        speed = 20,
        intervals = 8,
        disable_float_win = true,
        disabled_filetypes = { 'OverseerList', 'OverseerForm', 'dapui_*' },
      })
    end,
  },
  {
    'rcarriga/nvim-notify',
    event = 'VeryLazy',
    init = function()
      -- vim.opt.termguicolors = true
    end,
    config = function() require('notify').setup() end,
  },
  {
    'm-demare/hlargs.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function() require('hlargs').setup({ performance = { slow_parse_delay = 5 } }) end,
  },
  {
    'sontungexpt/sttusline',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function(_, opts)
      require('sttusline').setup({
        statusline_color = 'StatusLine',
        laststatus = 3,
        components = {
          'mode',
          'filename',
          'git-branch',
          'git-diff',
          '%=',
          'diagnostics',
          'lsps-formatters',
          'copilot',
          'indent',
          'encoding',
          'pos-cursor',
          'pos-cursor-progress',
        },
      })
    end,
  },
  {
    'stevearc/oil.nvim',
    config = function() require('oil').setup() end,
  },
  {
    'RRethy/vim-illuminate',
    event = { 'BufReadPre', 'BufNewFile' },
  },
  {
    'crispgm/nvim-tabline',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function() require('tabline').setup({}) end,
  },
}

return M
