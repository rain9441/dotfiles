local M = {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      animate = { enabled = false },
      bigfile = { enabled = true },
      dashboard = { enabled = false },
      explorer = { enabled = false },
      indent = {
        enabled = true,
        only_scope = true,
        only_current = true,
        animate = {
          enabled = false,
        },
        scope = {
          underline = true,
        },
      },
      input = { enabled = true },
      picker = {
        enabled = true,
        win = {
          input = {
            keys = {
              ['<Tab>'] = { 'list_down', mode = { 'i', 'n' } },
              ['<C-Tab>'] = { 'list_down', mode = { 'i', 'n' } },
              ['<S-Tab>'] = { 'list_up', mode = { 'i', 'n' } },
              ['<C-S-Tab>'] = { 'list_up', mode = { 'i', 'n' } },
            },
          },
        },
        sources = {
          recent = {
            layout = 'vscode',
            formatters = { file = { filename_only = true } },
          },
          files = { layout = 'bottom' },
          grep = { layout = 'bottom' },
        },
      },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      words = {
        enabled = true,
        debounce = 0,
      },
    },
  },
}

return M
