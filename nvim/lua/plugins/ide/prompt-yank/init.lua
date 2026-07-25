return {
  'polacekpavel/prompt-yank.nvim',
  event = { 'VeryLazy' },
  cmd = { 'PromptYank' },
  opts = {
    register = { '*', '+' },
    format = 'claude',
  },
}
