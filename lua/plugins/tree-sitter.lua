local M = {
  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = { 'TSUpdate' },
    build = ':TSUpdate',
    dependencies = {
      -- Fix TS/JS comment indentation issues
      { 'yioneko/nvim-yati' },
    },
    config = function()
      require('nvim-treesitter.install').compilers = { 'clang' }
      require('nvim-treesitter.configs').setup({
        yati = { enable = true },
        highlight = { enable = true },
        ensure_installed = {
          'html',
          'typescript',
          'javascript',
          'json',
          'http',
          'vim',
          'vimdoc',
          'query',
          'bash',
          'dockerfile',
          'git_config',
          'graphql',
          'jsdoc',
          'lua',
          'regex',
          'sql',
          'terraform',
          'yaml',
          'c_sharp',
        },
        indent = { enable = false },
      })
    end,
  },
  { 'nvim-treesitter/playground' },
}

return M
