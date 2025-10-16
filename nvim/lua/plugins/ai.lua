local M = {
  {
    'milanglacier/minuet-ai.nvim',
    opts = {
      -- Your configuration options here
      blink = { enable_auto_complete = false, },
      notify = 'error',
      lsp = {
        enabled_ft = { },
        enabled_auto_trigger_ft = {  },
      },
      provider = 'claude',
      provider_options = {
        claude = {
          max_tokens = 256,
          model = 'claude-haiku-4-5-20251001',
          stream = true,
          api_key = 'MINUET_ANTHROPIC_API_KEY', -- Add environment variable to `local.lua` manually
          end_point = 'https://api.anthropic.com/v1/messages',
        },
      },
    },
  },
  {
    'olimorris/codecompanion.nvim',
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
          },
        },
        inline = {
          adapter = {
            type = 'acp',
            name = 'claude_code',
          },
        },
        cmd = {
          adapter = {
            type = 'acp',
            name = 'claude_code',
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
