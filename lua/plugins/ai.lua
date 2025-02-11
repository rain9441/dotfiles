local M = {
  {
    'olimorris/codecompanion.nvim',
    event = { 'VeryLazy' },
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
          adapter = 'anthropic',
        },
        inline = {
          adapter = 'anthropic',
        },
      },
    },
  },
}

return M
