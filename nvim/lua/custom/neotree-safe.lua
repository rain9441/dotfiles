local M = {}

local function is_codediff_tab(tabpage)
  local ok, lifecycle = pcall(require, 'codediff.ui.lifecycle')
  if not ok then return false end
  return lifecycle.get_session(tabpage) ~= nil
end

local function find_non_codediff_tab()
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if not is_codediff_tab(tab) then
      return tab
    end
  end
  return nil
end

--- Run a Neotree command, but if currently in a codediff tab, first switch to
--- the first non-codediff tab. If no such tab exists, suppress.
function M.run(cmd)
  local current = vim.api.nvim_get_current_tabpage()
  if is_codediff_tab(current) then
    local target = find_non_codediff_tab()
    if not target then
      return
    end
    vim.api.nvim_set_current_tabpage(target)
  end
  vim.cmd(cmd)
end

return M
