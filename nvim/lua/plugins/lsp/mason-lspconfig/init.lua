return {
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
}
