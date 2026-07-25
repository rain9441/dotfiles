return {
  'Wansmer/treesj',
  cmd = 'TSJToggle',
  config = function()
    require('treesj').setup({
      use_default_keymaps = false,
      max_join_length = 150,
    })
    local langs = require('treesj.langs')
    langs.presets['javascript'].array.join.space_in_brackets = false
    langs.presets['typescript'].array.join.space_in_brackets = false
  end,
}
