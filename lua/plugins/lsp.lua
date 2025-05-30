local M = {
  {
    'mason-org/mason.nvim',
    cmd = 'Mason',
    config = function()
      require('mason').setup({
        PATH = 'prepend',
      })
    end,
  },
  {
    'mason-org/mason-lspconfig.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'mason-org/mason.nvim',
    },
    config = function()
      require('mason-lspconfig').setup({
        handlers = {
          function(server) require('lspconfig')[server].setup({}) end,
          ['angularls'] = function()
            require('lspconfig').angularls.setup({
              root_dir = require('lspconfig.util').root_pattern('angular.json', 'project.json', 'nx.json', '.git'),
            })
          end,
          ['apex_ls'] = function()
            require('lspconfig').apex_ls.setup({
              filetypes = { 'apexcode', 'apex' },
              apex_enable_semantic_errors = false, -- Whether to allow Apex Language Server to surface semantic errors
              apex_enable_completion_statistics = false, -- Whether to allow Apex Language Server to collect telemetry on code completion usage
            })
          end,
          ['vtsls'] = function()
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

            require('lspconfig').vtsls.setup({
              root_dir = require('lspconfig.util').root_pattern('angular.json', 'project.json', 'nx.json', '.git'),
              settings = {
                completions = { completeFunctionCalls = true },
                javascript = { format = format },
                typescript = { format = format },
              },
              init_options = {
                preferences = preferences,
              },
            })
          end,
          ['html'] = function()
            require('lspconfig').html.setup({
              settings = {
                html = {
                  format = {
                    wrapLineLength = 180,
                    wrapAttributes = 'auto',
                  },
                },
              },
            })
          end,
        },
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
    config = function()
      require('mason-null-ls').setup({
        ensure_installed = {
          -- 'angular-language-server',
          'css-lsp',
          'docker-compose-language-service',
          'dockerfile-language-server',
          'eslint_d',
          'html-lsp',
          'json-lsp',
          'lua-language-server',
          'marksman',
          'nxls',
          'omnisharp',
          'stylua',
          'terraform-ls',
          'tflint',
          'vim-language-server',
          'yaml-language-server',
        },
      })
    end,
  },
  {
    'nvimtools/none-ls.nvim',
    ft = { 'lua', 'typescript' },
    config = function()
      require('null-ls').setup({
        sources = {
          require('null-ls').builtins.formatting.stylua,
          -- require('typescript.extensions.null-ls.code-actions'),
        },
      })
    end,
    requires = { 'nvim-lua/plenary.nvim' },
  },
  {
    'neovim/nvim-lspconfig',
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
    config = function() require('lspconfig.configs').vtsls = require('vtsls').lspconfig end,
  },
  -- {
  --   'jose-elias-alvarez/typescript.nvim',
  --   ft = { 'javascript', 'typescript', 'js', 'ts' },
  --   dependencies = { 'neovim/nvim-lspconfig', 'mason-org/mason-lspconfig.nvim' },
  --   config = function()
  --     local format = {
  --       indentSwitchCase = true,
  --       insertSpaceAfterCommaDelimiter = true,
  --       insertSpaceAfterConstructor = false,
  --       insertSpaceAfterSemicolonInForStatements = true,
  --       insertSpaceBeforeAndAfterBinaryOperators = true,
  --       insertSpaceAfterKeywordsInControlFlowStatements = true,
  --       insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
  --       insertSpaceBeforeFunctionParenthesis = false,
  --       insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = false,
  --       insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
  --       insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true,
  --       insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = true,
  --       insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,
  --       insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = false,
  --       insertSpaceAfterTypeAssertion = false,
  --       placeOpenBraceOnNewLineForFunctions = false,
  --       placeOpenBraceOnNewLineForControlBlocks = false,
  --       semicolons = 'insert',
  --     }
  --     local preferences = {
  --       quotePreference = 'single',
  --       importModuleSpecifierPreference = "project-relative",
  --       jsxAttributeCompletionStyle = 'auto',
  --       allowTextChangesInNewFiles = true,
  --       providePrefixAndSuffixTextForRename = true,
  --       allowRenameOfImportPath = true,
  --       includeAutomaticOptionalChainCompletions = true,
  --       provideRefactorNotApplicableReason = true,
  --       generateReturnInDocTemplate = true,
  --       includeCompletionsForImportStatements = true,
  --       includeCompletionsWithSnippetText = true,
  --       includeCompletionsWithClassMemberSnippets = true,
  --       includeCompletionsWithObjectLiteralMethodSnippets = true,
  --       useLabelDetailsInCompletionEntries = true,
  --       allowIncompleteCompletions = true,
  --       displayPartsForJSDoc = true,
  --       disableLineTextInReferences = true,
  --       includeInlayParameterNameHints = 'none',
  --       includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  --       includeInlayFunctionParameterTypeHints = false,
  --       includeInlayVariableTypeHints = false,
  --       includeInlayVariableTypeHintsWhenTypeMatchesName = false,
  --       includeInlayPropertyDeclarationTypeHints = false,
  --       includeInlayFunctionLikeReturnTypeHints = false,
  --       includeInlayEnumMemberValueHints = false,
  --     }
  --     require('typescript').setup({
  --       disable_commands = false,
  --       go_to_source_definition = {
  --         fallback = true,
  --       },
  --       server = {
  --         settings = {
  --           completions = { completeFunctionCalls = true },
  --           javascript = { format = format },
  --           typescript = { format = format },
  --         },
  --         init_options = {
  --           preferences = preferences,
  --         },
  --       },
  --     })
  --     require('null-ls').register(require('typescript.extensions.null-ls.code-actions'))
  --   end,
  -- },
  {
    'Hoffs/omnisharp-extended-lsp.nvim',
  },
}

return M
