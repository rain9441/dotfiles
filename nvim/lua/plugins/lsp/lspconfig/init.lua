return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'mason-org/mason.nvim',
    'mason-org/mason-lspconfig.nvim',
    'saghen/blink.cmp',
  },
  config = function()
    vim.lsp.config('terraformls', {
      on_attach = function(_, bufnr)
        vim.lsp.codelens.enable(true, { bufnr = bufnr })
      end,
    })
  end,
}
