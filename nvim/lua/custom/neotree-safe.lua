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

--- session_manager's save path force-deletes every non-restorable buffer
--- (Neo-tree's included -- see the "Remove all non-file and utility buffers
--- because they cannot be saved" comment in session_manager/utils.lua)
--- before :mksession runs. Deleting the buffer never closes the window
--- though -- Neovim just swaps in a blank buffer -- so which window happens
--- to be "the one" that survives is arbitrary buffer-iteration-order luck.
--- If it's the former Neo-tree window, its window-scoped settings
--- (winhighlight, winfixwidth, winbar, ...) ride along into the saved
--- session even though the buffer inside it is now blank, and that's what
--- corrupts the reload.
---
--- Rather than reset those options defensively after the fact, remove Neo-
--- tree's window AND buffer ourselves, synchronously, before control ever
--- reaches session_manager's cleanup loop. Once Neo-tree doesn't exist at
--- all, there's no window left to possibly be confused with the real one --
--- whichever window session_manager's loop leaves standing afterward is
--- unambiguously a plain window.
---
--- We do this directly via the API rather than `:Neotree close` because
--- that command has two bugs of its own: close_all() only closes state for
--- the CURRENT tabpage (sources/manager.lua), silently skipping Neo-tree
--- windows in other tabs; and renderer.close() does
--- `pcall(nvim_win_close, ...)` and then unconditionally clears state /
--- force-deletes the buffer regardless of whether the close succeeded, so
--- if Neo-tree is the last window in its tab the pcall swallows nvim's
--- E444 and you get a zombie window anyway.
function M.close_before_session_save()
  local original_tab = vim.api.nvim_get_current_tabpage()
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == 'neo-tree' then
        vim.api.nvim_set_current_tabpage(tab)
        -- Guarantee a second window exists so closing this one always
        -- actually succeeds instead of hitting nvim's "last window" refusal.
        if #vim.api.nvim_tabpage_list_wins(tab) == 1 then
          vim.cmd('new')
        end
        pcall(vim.api.nvim_win_close, win, true)
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
        break
      end
    end
  end
  if vim.api.nvim_tabpage_is_valid(original_tab) then
    vim.api.nvim_set_current_tabpage(original_tab)
  end
end

return M
