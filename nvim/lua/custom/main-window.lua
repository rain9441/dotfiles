local M = {
  _setup = function()
    vim.g.rain9441_mru_ix = 1

    local group = vim.api.nvim_create_augroup('rain9441.main-window', {})
    vim.api.nvim_create_autocmd({ 'BufEnter' }, {
      group = group,
      callback = function()
        vim.b.rain9441_mru = vim.g.rain9441_mru_ix
        vim.g.rain9441_mru_ix = vim.g.rain9441_mru_ix + 1
      end,
    })
    vim.api.nvim_create_autocmd({ 'WinEnter' }, {
      group = group,
      callback = function()
        vim.w.rain9441_mru = vim.g.rain9441_mru_ix
        vim.g.rain9441_mru_ix = vim.g.rain9441_mru_ix + 1
      end,
    })
  end,

  activate = function()
    local wins = vim.api.nvim_list_wins()
    table.sort(wins, function(a, b)
      return (vim.w[b].rain9441_mru or 0) < (vim.w[a].rain9441_mru or 0)
    end)
    local win = vim.iter(wins):find(function(win)
      local buf = vim.api.nvim_win_get_buf(win)
      return vim.bo[buf].buftype == ''
    end)

    vim.api.nvim_set_current_win(win)
  end,
}

M._setup()

return M

