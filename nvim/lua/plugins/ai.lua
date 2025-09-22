local M = {
  {
    'milanglacier/minuet-ai.nvim',
    -- event = { 'VeryLazy' },
    opts = {
      -- Your configuration options here
      cmp = {
          enable_auto_complete = false,
      },
      lsp = {
        enabled_ft = { },
        enabled_auto_trigger_ft = {  },
        -- enabled_ft = { 'toml', 'lua', 'cpp' },
        -- Enables automatic completion triggering using `vim.lsp.completion.enable`
        -- enabled_auto_trigger_ft = { 'cpp', 'lua' },
      },
      provider = 'claude',
      provider_options = {
        claude = {
          max_tokens = 512,
          model = 'claude-sonnet-4-20250514',
          stream = true,
          api_key = 'ANTHROPIC_API_KEY',
          end_point = 'https://api.anthropic.com/v1/messages',
          optional = {
            -- pass any additional parameters you want to send to claude request,
            -- e.g.
            -- stop_sequences = nil,
          },
        },
      },
    },
  },
  {
    'olimorris/codecompanion.nvim',
    -- event = { 'VeryLazy' },
    cmd = { 'CodeCompanion', 'CodeCompanionCmd', 'CodeCompanionAction', 'CodeCompanionChat' },
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
    init = function()
      -- Always enable auto-tool-mode
      vim.g.codecompanion_auto_tool_mode = true
    end,
    opts = {
      display = {
        diff = { enabled = false },
      },
      strategies = {
        chat = {
          adapter = {
            type = 'acp',
            name = 'claude_code',
            -- model = 'claude-sonnet-4-20250514',
            model = 'claude-opus-4-1-20250805',
          },
        },
        inline = {
          adapter = {
            name = 'anthropic',
            model = 'claude-sonnet-4-20250514',
          },
        },
        cmd = {
          adapter = {
            name = 'anthropic',
            model = 'claude-sonnet-4-20250514',
          },
        },
      },
      adapters = {
        acp = {
          claude_code = function()
            return require("codecompanion.adapters").extend("claude_code", {
              env = {
                CLAUDE_CODE_OAUTH_TOKEN = "cmd:cat %USERPROFILE%/.claude/.token",
              },
            })
          end,
        },
      },
    },
  },
  {
    'coder/claudecode.nvim',
    event = { 'VeryLazy' },
    dependencies = { "folke/snacks.nvim" },
    opts = {
      -- terminal_cmd = "~/.claude/local/claude", -- Point to local installation
      terminal = {
        split_side = "left",
        split_width_percentage = 0.5,
      }
    },
  }
}

return M
