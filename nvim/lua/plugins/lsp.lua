local M = {
  {
    'mason-org/mason.nvim',
    cmd = 'Mason',
    opts = {
      PATH = 'prepend',
      registries = {
        'github:mason-org/mason-registry',
        'github:Crashdummyy/mason-registry',
      },
    },
  },
  {
    'mason-org/mason-lspconfig.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'mason-org/mason.nvim',
    },
    config = function()
      -- Enable apex_ls manually at this time until Mason config is setup to handle APEX
      vim.lsp.config('apex_ls', {
        cmd = {
          vim.env.JAVA_HOME and (vim.env.JAVA_HOME .. '/bin/java') or 'java',
          '-cp',
          vim.fn.expand('$MASON/share/apex-language-server/apex-jorje-lsp.jar'),
          '-Ddebug.internal.errors=true',
          '-Ddebug.semantic.errors=false',
          '-Ddebug.completion.statistics=false',
          '-Dlwc.typegeneration.disabled=true',
          'apex.jorje.lsp.ApexLanguageServerLauncher',
        },
        root_markers = { 'sfdx-project.json' },
        filetypes = { 'apexcode', 'apex' },
      })
      vim.lsp.enable('apex_ls')
      vim.lsp.config('html', {
        settings = {
          html = {
            format = {
              wrapLineLength = 180,
              wrapAttributes = 'auto',
            },
          },
        },
      })

      local format = {
        indentSwitchCase = true,
        insertSpaceAfterCommaDelimiter = true,
        insertSpaceAfterConstructor = false,
        insertSpaceAfterSemicolonInForStatements = true,
        insertSpaceBeforeAndAfterBinaryOperators = true,
        insertSpaceAfterKeywordsInControlFlowStatements = true,
        insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
        insertSpaceBeforeFunctionParenthesis = false,
        insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = false,
        insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
        insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true,
        insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = true,
        insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,
        insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = false,
        insertSpaceAfterTypeAssertion = false,
        placeOpenBraceOnNewLineForFunctions = false,
        placeOpenBraceOnNewLineForControlBlocks = false,
        semicolons = 'insert',
      }
      local preferences = {
        quoteStyle = 'single',
        importModuleSpecifier = 'project-relative',
        jsxAttributeCompletionStyle = 'auto',
        allowTextChangesInNewFiles = true,
        providePrefixAndSuffixTextForRename = true,
        allowRenameOfImportPath = true,
        includeAutomaticOptionalChainCompletions = true,
        provideRefactorNotApplicableReason = true,
        generateReturnInDocTemplate = true,
        includeCompletionsForImportStatements = true,
        includeCompletionsWithSnippetText = true,
        includeCompletionsWithClassMemberSnippets = true,
        includeCompletionsWithObjectLiteralMethodSnippets = true,
        useLabelDetailsInCompletionEntries = true,
        allowIncompleteCompletions = true,
        displayPartsForJSDoc = true,
        disableLineTextInReferences = true,
        includeInlayParameterNameHints = 'none',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = false,
        includeInlayVariableTypeHints = false,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = false,
        includeInlayFunctionLikeReturnTypeHints = false,
        includeInlayEnumMemberValueHints = false,
      }

      vim.lsp.config(
        'vtsls',
        vim.tbl_extend('force', require('vtsls').lspconfig, {
          settings = {
            complete_function_calls = true,
            typescript = {
              updateImportsOnFileMove = 'always',
              preferences = preferences,
              format = format,
              tsserver = {
                experimental = {
                  -- enableProjectDiagnostics = true
                },
              },
            },
            javascript = {
              updateImportsOnFileMove = 'always',
              preferences = preferences,
              format = format,
            },
          },
        })
      )

      require('mason-lspconfig').setup({
        ensure_installed = {},
        automatic_enable = { exclude = { 'stylua' } },
      })
    end,
  },
  {
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
  },
  {
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
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',
      'saghen/blink.cmp',
    },
  },
  {
    'yioneko/nvim-vtsls',
    ft = { 'javascript', 'typescript', 'js', 'ts' },
    dependencies = { 'neovim/nvim-lspconfig', 'mason-org/mason-lspconfig.nvim' },
  },
  {
    'MonsieurTib/neonuget',
    lazy = false,
    config = function() require('neonuget').setup({}) end,
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {},
  },
  {
    'seblyng/roslyn.nvim',
    commit = 'f2ec6ee6384c3b611ddc817b9e78b20cd0334bbb',
    lazy = false,
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {
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
  },
}

return M
