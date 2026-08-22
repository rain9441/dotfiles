return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'mason-org/mason.nvim',
    'mason-org/mason-lspconfig.nvim',
    'saghen/blink.cmp',
  },
  config = function()
    -- nvim-lspconfig's master branch calls vim.lsp.codelens.enable(),
    -- which doesn't exist until Neovim nightly (post-0.11); guard it.
    vim.lsp.config('terraformls', {
      on_attach = function(_, bufnr)
        if vim.lsp.codelens.enable then
          vim.lsp.codelens.enable(true, { bufnr = bufnr })
        end
      end,
    })
  end,
}
