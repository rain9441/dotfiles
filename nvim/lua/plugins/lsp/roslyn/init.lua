return {
  'seblyng/roslyn.nvim',
  commit = 'f2ec6ee6384c3b611ddc817b9e78b20cd0334bbb',
  lazy = false,
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  opts = {
    -- Multiple solutions are generated per repo here; the Local one is the dev target
    choose_target = function(targets)
      for _, target in ipairs(targets) do
        if target:match('%.Local%.sln$') then
          return target
        end
      end
      return targets[1]
    end,
  },
  config = function(_, opts)
    require('roslyn').setup(opts)
    vim.lsp.config('roslyn', {
      settings = {
        ['csharp|formatting'] = {
          dotnet_organize_imports_on_format = true,
        },
      },
    })
  end,
}
