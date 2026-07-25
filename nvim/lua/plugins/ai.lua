local M = {
  {
    'polacekpavel/prompt-yank.nvim',
    event = { 'VeryLazy' },
    cmd = { 'PromptYank' },
    opts = {
      register = { '*', '+' },
      format = 'claude',
    },
  },
}

return M
