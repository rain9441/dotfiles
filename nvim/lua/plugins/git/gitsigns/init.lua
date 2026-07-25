return {
  'lewis6991/gitsigns.nvim',
  commit = 'ce5e1b5ae3455316364ac1c96c2787d7925a2914',
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
