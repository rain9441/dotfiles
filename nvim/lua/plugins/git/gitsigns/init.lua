return {
  'lewis6991/gitsigns.nvim',
  event = 'VeryLazy',
  config = function()
    require('gitsigns').setup({
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '-' },
        topdelete = { text = '‾' },
        changedelete = { text = 'x' },
        untracked = { text = '?' },
      },
      signs_staged_enable = true,
      numhl = true,
      diff_opts = {
        algorithm = 'histogram',
      },
    })
  end,
}
