return {
  'jay-babu/mason-null-ls.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'mason-org/mason.nvim',
    'nvimtools/none-ls.nvim',
  },
  opts = {
    ensure_installed = {
      -- 'angular-language-server',
      'css-lsp',
      'docker-compose-language-service',
      'dockerfile-language-server',
      -- 'eslint_d',
      'html-lsp',
      'json-lsp',
      'lua-language-server',
      'marksman',
      'nxls',
      -- 'omnisharp',
      'stylua',
      'terraform-ls',
      'tflint',
      'vim-language-server',
      'yaml-language-server',
    },
  },
}
