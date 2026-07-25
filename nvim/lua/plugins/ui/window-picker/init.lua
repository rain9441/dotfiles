return {
  's1n7ax/nvim-window-picker',
  version = '2.*',
  config = function()
    require('window-picker').setup({
      filter_rules = {
        bo = {
          buftype = { 'terminal', 'nofile', 'quickfix', 'prompt', 'help' },
        },
      },
    })
  end,
}
