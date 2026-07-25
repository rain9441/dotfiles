return {
  'paul-gross/codediff.nvim',
  dependencies = { 'MunifTanjim/nui.nvim' },
  cmd = 'CodeDiff',
  opts = {
    diff = {
      layout = "inline", -- default to inline view instead of side-by-side
    },
    explorer = {
      position = "bottom",
    }
  },
}
