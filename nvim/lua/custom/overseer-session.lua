local function get_cwd_as_name()
  local dir = vim.fn.getcwd(0)
  return dir:gsub('[^A-Za-z0-9]', '_')
end

local M = {
  reset_tasks = function()
    for _, task in ipairs(require('overseer').list_tasks({})) do
      task:dispose(true)
    end
  end,
  save_session = function() require('overseer').save_task_bundle(get_cwd_as_name(), nil, { on_conflict = 'overwrite' }) end,
  load_session = function()
    require('overseer').load_task_bundle(get_cwd_as_name(), { ignore_missing = true, autostart = false })
  end,
}

return M
