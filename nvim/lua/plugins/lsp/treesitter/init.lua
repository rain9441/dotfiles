-- nvim-treesitter's `main` branch is the one that supports Neovim 0.12; `master`
-- is frozen. `main` is purely a parser/query installer -- highlighting, folds and
-- injections come from Neovim itself -- so there are no `configs.setup` modules
-- any more and features get switched on per buffer below.
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
  -- The `main` branch explicitly does not support lazy-loading.
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local ts = require('nvim-treesitter')
    ts.setup()

    -- `main` dropped the standalone jsonc parser; json handles everything about
    -- jsonc except the comments.
    vim.treesitter.language.register('json', 'jsonc')

    ts.install(ensure_installed)

    local function parser_installed(lang)
      return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) > 0
    end

    local available
    local function installable(lang)
      if available == nil then
        available = {}
        for _, l in ipairs(ts.get_available()) do
          available[l] = true
        end
      end
      return available[lang] == true
    end

    local function enable(buf, lang)
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      if not pcall(vim.treesitter.start, buf, lang) then
        return
      end
      -- Only hand indenting over to treesitter where there are indent queries to
      -- drive it; `get_indent` gives up and returns -1 otherwise, which would
      -- leave languages like c_sharp unable to indent at all.
      local ok, query = pcall(vim.treesitter.query.get, lang, 'indents')
      if ok and query then
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end

    local pending = {}

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter-enable', { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if not lang then
          return
        end

        if parser_installed(lang) then
          enable(args.buf, lang)
          return
        end

        -- Stand-in for the `auto_install` option `master` used to provide: fetch
        -- the parser the first time we meet a filetype, then light the buffer up
        -- once the (asynchronous) install lands.
        if pending[lang] or not installable(lang) then
          return
        end
        pending[lang] = true

        local buf = args.buf
        ts.install(lang):await(function(err)
          vim.schedule(function()
            pending[lang] = nil
            if not err then
              enable(buf, lang)
            end
          end)
        end)
      end,
    })
  end,
}
