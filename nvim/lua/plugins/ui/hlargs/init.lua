return {
  'm-demare/hlargs.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = { performance = { slow_parse_delay = 5 } },
}
