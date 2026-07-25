return {
  'Bekaboo/deadcolumn.nvim',
  event = 'VeryLazy',
  opts = {
    scope = 'buffer',
    modes = function(mode) return mode:find('^[nictRss\x13]') ~= nil end,
    blending = {
      threshold = 0.33,
    },
  },
}
