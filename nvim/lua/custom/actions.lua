local M = {

  reveal_explorer = function()
    local explorer_pickers = require('snacks').picker.get({ source = 'explorer' })
    for _, v in pairs(explorer_pickers) do
      if v:is_focused() then
        v:close()
      else
        require('snacks').explorer.reveal()
        v:focus()
      end
    end
    if #explorer_pickers == 0 then
      require('snacks').explorer.reveal()
    end
  end,

  focus_explorer = function()
    local explorer_pickers = require('snacks').picker.get({ source = 'explorer' })
    for _, v in pairs(explorer_pickers) do
      if v:is_focused() then
        v:close()
      else
        v:focus()
      end
    end
    if #explorer_pickers == 0 then
      require('snacks').picker.explorer()
    end
  end,

  code_action_apply_first = function()
    local diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
    if not next(diagnostics) then
      diagnostics = vim.lsp.diagnostic.get(0)
    end

    if not next(diagnostics) then
      print('No code actions available')
      return
    end

    local range
    if diagnostics[1].range then
      range = {
        start = { diagnostics[1].range.start.line + 1, diagnostics[1].range.start.character + 1 },
        ['end'] = { diagnostics[1].range['end'].line + 1, diagnostics[1].range['end'].character + 1 },
      }
    else
      range = {
        start = { diagnostics[1].lnum + 1, diagnostics[1].col + 1 },
        ['end'] = { diagnostics[1].lnum + 1, diagnostics[1].end_col + 1 },
      }
    end

    local isFirst = { first = true }
    vim.lsp.buf.code_action({
      context = {
        diagnostics = { diagnostics[1] },
      },
      range = range,
      filter = function()
        local wasFirst = isFirst.first
        isFirst.first = false
        return wasFirst
      end,
      apply = true,
    })
  end,
}

return M
