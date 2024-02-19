local M = {
  code_action_apply_first = function()
    local diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
    if not next(diagnostics) then
      diagnostics = vim.diagnostic.get(0)
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

    isFirst = { first = true }
    vim.lsp.buf.code_action({
      context = {
        diagnostics = { diagnostics[1] },
      },
      range = range,
      filter = function(ix)
        local wasFirst = isFirst.first
        isFirst.first = false
        return wasFirst
      end,
      apply = true,
    })
  end,
}

return M
