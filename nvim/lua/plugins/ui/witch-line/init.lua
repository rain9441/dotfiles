return {
  'sontungexpt/witch-line',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    statusline = {
      global = {
        'mode',
        'file.icon',
        'file.name',
        'git.branch',
        'git.diff.added',
        'git.diff.removed',
        'git.diff.modified',
        '%=',
        'diagnostic.error',
        'diagnostic.warn',
        'diagnostic.info',
        'diagnostic.hint',
        'lsp.clients',
      },
    },
  },
}
