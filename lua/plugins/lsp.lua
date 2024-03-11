local M = {
  {
    'williamboman/mason.nvim',
    event = 'VeryLazy',
    config = function()
      require('mason').setup({
        PATH = 'prepend',
      })
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    event = 'VeryLazy',
    config = function()
      require('mason-lspconfig').setup({
        handlers = {
          function(server) require('lspconfig')[server].setup({}) end,
          ['angularls'] = function()
            require('lspconfig').angularls.setup({
              root_dir = require('lspconfig.util').root_pattern('angular.json', 'project.json'),
            })
          end,
          ['tsserver'] = function()
            local format = {
              indentSwitchCase = true,
              insertSpaceAfterCommaDelimiter = true,
              insertSpaceAfterConstructor = false,
              insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
              insertSpaceAfterKeywordsInControlFlowStatements = true,
              insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = true,
              insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = false,
              insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true,
              insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
              insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = false,
              insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,
              insertSpaceAfterSemicolonInForStatements = true,
              insertSpaceAfterTypeAssertion = false,
              insertSpaceBeforeAndAfterBinaryOperators = true,
              insertSpaceBeforeFunctionParenthesis = false,
              placeOpenBraceOnNewLineForControlBlocks = false,
              placeOpenBraceOnNewLineForFunctions = false,
              semicolons = 'insert',
            }
            local preferences = {
              allowIncompleteCompletions = true,
              allowTextChangesInNewFiles = true,
              allowRenameOfImportPath = true,
              disableLineTextInReferences = true,
              displayPartsForJSDoc = true,
              generateReturnInDocTemplate = true,
              importModuleSpecifierEnding = 'project-relative',
              includeAutomaticOptionalChainCompletions = true,
              includeCompletionsForImportStatements = true,
              includeCompletionsWithClassMemberSnippets = true,
              includeCompletionsWithObjectLiteralMethodSnippets = true,
              includeCompletionsWithSnippetText = true,
              includeInlayEnumMemberValueHints = false,
              includeInlayFunctionLikeReturnTypeHints = false,
              includeInlayFunctionParameterTypeHints = false,
              includeInlayParameterNameHints = 'none',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayPropertyDeclarationTypeHints = false,
              includeInlayVariableTypeHints = false,
              includeInlayVariableTypeHintsWhenTypeMatchesName = false,
              jsxAttributeCompletionStyle = 'auto',
              provideRefactorNotApplicableReason = true,
              providePrefixAndSuffixTextForRename = true,
              quotePreference = 'single',
              useLabelDetailsInCompletionEntries = true,
            }

            require('lspconfig').tsserver.setup({
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
        },
      })
    end,
  },
  {
    'jay-babu/mason-null-ls.nvim',
    event = 'VeryLazy',
    dependencies = {
      'williamboman/mason.nvim',
      'nvimtools/none-ls.nvim',
    },
    config = function()
      require('mason-null-ls').setup({
        ensure_installed = {
          'angular-language-server',
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
    event = 'VeryLazy',
    config = function()
      require('null-ls').setup({
        sources = {
          -- require('null-ls').builtins.code_actions.eslint_d,
          require('null-ls').builtins.formatting.stylua,
          -- require('null-ls').builtins.diagnostics.eslint_d,
          require('null-ls').builtins.completion.spell,
        },
      })
    end,
    requires = { 'nvim-lua/plenary.nvim' },
  },
  {
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    config = function()
      -- Setup language servers.
      -- local lspconfig = require('lspconfig')
    end,
  },
  {
    'onsails/lspkind.nvim',
    event = 'VeryLazy',
  },
  -- {
  --   'pmizio/typescript-tools.nvim',
  --   event = 'VeryLazy',
  --   dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  --   config = function()
  --     require('typescript-tools').setup({
  --       settings = {
  --         tsserver_format_options = {
  --           insertSpaceAfterCommaDelimiter = true,
  --           insertSpaceAfterConstructor = false,
  --           insertSpaceAfterSemicolonInForStatements = true,
  --           insertSpaceBeforeAndAfterBinaryOperators = true,
  --           insertSpaceAfterKeywordsInControlFlowStatements = true,
  --           insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
  --           insertSpaceBeforeFunctionParenthesis = false,
  --           insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = false,
  --           insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
  --           insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true,
  --           insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = true,
  --           insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,
  --           insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = false,
  --           insertSpaceAfterTypeAssertion = false,
  --           placeOpenBraceOnNewLineForFunctions = false,
  --           placeOpenBraceOnNewLineForControlBlocks = false,
  --           semicolons = 'insert',
  --           indentSwitchCase = true,
  --         },
  --         tsserver_file_preferences = {
  --           quotePreference = 'single',
  --           importModuleSpecifierEnding = 'project-relative',
  --           jsxAttributeCompletionStyle = 'auto',
  --           allowTextChangesInNewFiles = true,
  --           providePrefixAndSuffixTextForRename = true,
  --           allowRenameOfImportPath = true,
  --           includeAutomaticOptionalChainCompletions = true,
  --           provideRefactorNotApplicableReason = true,
  --           generateReturnInDocTemplate = true,
  --           includeCompletionsForImportStatements = true,
  --           includeCompletionsWithSnippetText = true,
  --           includeCompletionsWithClassMemberSnippets = true,
  --           includeCompletionsWithObjectLiteralMethodSnippets = true,
  --           useLabelDetailsInCompletionEntries = true,
  --           allowIncompleteCompletions = true,
  --           displayPartsForJSDoc = true,
  --           disableLineTextInReferences = true,
  --           includeInlayParameterNameHints = 'none',
  --           includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  --           includeInlayFunctionParameterTypeHints = false,
  --           includeInlayVariableTypeHints = false,
  --           includeInlayVariableTypeHintsWhenTypeMatchesName = false,
  --           includeInlayPropertyDeclarationTypeHints = false,
  --           includeInlayFunctionLikeReturnTypeHints = false,
  --           includeInlayEnumMemberValueHints = false,
  --         },
  --       },
  --     })
  --   end,
  -- },
}

return M
