return {
  'seblyng/roslyn.nvim',
  commit = 'f2ec6ee6384c3b611ddc817b9e78b20cd0334bbb',
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
