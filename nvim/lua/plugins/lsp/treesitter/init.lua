-- nvim-treesitter's `main` branch is the one that supports Neovim 0.12; `master`
-- is frozen. `main` is an installer, not a runtime dependency: it drops parsers
-- and queries into `stdpath('data')/site`, which is on the default runtimepath,
-- and Neovim does the highlighting itself from there. So the plugin only has to
-- load when parsers are actually being installed or updated -- `init` below is
-- all that runs at startup, and indenting stays on Neovim's built-in ftplugins.
local ensure_installed = {
  'angular',
  'bash',
  'c_sharp',
  'css',
  'diff',
  'dockerfile',
  'editorconfig',
  'gitattributes',
  'gitcommit',
  'git_config',
  'gitignore',
  'graphql',
  'hcl',
  'html',
  'http',
  'hurl',
  'javascript',
  'jsdoc',
  'json',
  'lua',
  'markdown',
  'markdown_inline',
  'mermaid',
  'python',
  'query',
  'regex',
  'requirements',
  'sql',
  'terraform',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'xml',
  'yaml',
}

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  cmd = { 'TSInstall', 'TSInstallFromGrammar', 'TSLog', 'TSUninstall', 'TSUpdate' },
  build = ':TSUpdate',
  init = function()
    -- The one part of the plugin that genuinely has to run at startup: the
    -- filetype -> language aliases (cs -> c_sharp, sh -> bash, typescriptreact ->
    -- tsx, ...), without which `get_lang` misses and those filetypes silently
    -- lose highlighting. `plugin/filetypes.lua` is a table plus a loop of
    -- `vim.treesitter.language.register` calls and requires nothing, so run it
    -- directly instead of dragging the whole plugin in.
    local aliases = vim.fn.stdpath('data') .. '/lazy/nvim-treesitter/plugin/filetypes.lua'
    if vim.uv.fs_stat(aliases) then
      dofile(aliases)
    else
      vim.notify('treesitter: filetype aliases missing at ' .. aliases, vim.log.levels.WARN)
    end

    -- `main` dropped the standalone jsonc parser; json handles everything about
    -- jsonc except the comments. (Also in the aliases above; kept so the mapping
    -- we actually rely on does not depend on that file.)
    vim.treesitter.language.register('json', 'jsonc')

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if lang then
          -- Fails for any filetype whose parser isn't installed; `:TSInstall` it.
          pcall(vim.treesitter.start, args.buf, lang)
        end
      end,
    })
  end,
  config = function()
    -- Only reached when one of the commands above runs (or on `build`), which is
    -- also when reconciling `ensure_installed` is worth the round trip.
    require('nvim-treesitter').install(ensure_installed)
  end,
}
