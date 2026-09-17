return {
  'seblyng/roslyn.nvim',
  lazy = false,
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  opts = {},
  config = function()
    vim.lsp.config('roslyn', {
      settings = {
        ['csharp|formatting'] = {
          dotnet_organize_imports_on_format = true,
        },
      },
    })
  end,
}
