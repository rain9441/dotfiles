return {
  'nvimtools/none-ls.nvim',
  ft = { 'lua', 'typescript' },
  opts = function()
    return {
      sources = {
        require('null-ls').builtins.formatting.stylua,
        -- require('typescript.extensions.null-ls.code-actions'),
      },
    }
  end,
  requires = { 'nvim-lua/plenary.nvim' },
}
