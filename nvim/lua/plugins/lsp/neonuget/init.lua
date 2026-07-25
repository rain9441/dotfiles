return {
  'MonsieurTib/neonuget',
  lazy = false,
  config = function() require('neonuget').setup({}) end,
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
}
