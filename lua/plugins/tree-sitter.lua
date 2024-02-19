local M = {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = true,
    config = function()
      require('nvim-treesitter.install').compilers = { 'clang' }
      require('nvim-treesitter.configs').setup({
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
      })
    end,
  },
  { 'nvim-treesitter/playground', event = 'VeryLazy' },
}

return M
