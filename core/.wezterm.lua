local wezterm = require('wezterm')
local config = wezterm.config_builder()

config.initial_cols = 150
config.initial_rows = 30

wezterm.on("gui-startup", function()
  local tab, pane, window = wezterm.mux.spawn_window{}
  window:gui_window():maximize()
end)


-- or, changing the font size and color scheme.
config.font_size = 10
config.color_scheme = 'Dracula+'
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.default_cwd = 'c:/projects'
config.use_dead_keys = false
config.font = wezterm.font('RobotoMono Nerd Font')

wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm").apply_to_config(config)

local function notNvim(keys)
  local copy = {}
  for ix, key_info in pairs(keys) do
    copy[ix] = {
      mods = key_info.mods,
      key = key_info.key,
      action = wezterm.action_callback(function(window, pane)
        local process_name = pane:get_foreground_process_name()
        wezterm.log_error('process: ' .. process_name)
        if process_name:match('nvim.exe$') or process_name:match('nvim$') or process_name:match('wslhost.exe$') then
          window:perform_action(wezterm.action({ SendKey = { mods = key_info.mods, key = key_info.key } }), pane)
        else
          window:perform_action(key_info.action, pane)
        end
      end)
    }
  end
  return copy
end


local function merge(result, toBeMerged)
  for _, v in pairs(toBeMerged) do
    table.insert(result, v)
  end
  return result
end

config.keys = merge(
  {
    { mods = 'CTRL', key = '1', action = wezterm.action.ActivateTab(0) },
    { mods = 'CTRL', key = '2', action = wezterm.action.ActivateTab(1) },
    { mods = 'CTRL', key = '3', action = wezterm.action.ActivateTab(2) },
    { mods = 'CTRL', key = '4', action = wezterm.action.ActivateTab(3) },
    { mods = 'CTRL', key = '5', action = wezterm.action.ActivateTab(4) },
    { mods = 'CTRL', key = 't', action = wezterm.action.SpawnTab('CurrentPaneDomain') },
  },
  notNvim({
    { mods = 'CTRL',       key = 'p', action = wezterm.action.ActivateCommandPalette },
    { mods = 'CTRL',       key = 'u', action = wezterm.action.ScrollByPage(-0.7) },
    { mods = 'CTRL',       key = 'd', action = wezterm.action.ScrollByPage(0.7) },
    { mods = 'CTRL',       key = 'y', action = wezterm.action.ScrollByLine(-1) },
    { mods = 'CTRL',       key = 'e', action = wezterm.action.ScrollByLine(1) },

    { mods = 'CTRL',       key = 'h', action = wezterm.action.ActivatePaneDirection('Left') },
    { mods = 'CTRL',       key = 'j', action = wezterm.action.ActivatePaneDirection('Down') },
    { mods = 'CTRL',       key = 'k', action = wezterm.action.ActivatePaneDirection('Up') },
    { mods = 'CTRL',       key = 'l', action = wezterm.action.ActivatePaneDirection('Right') },
    { mods = 'CTRL|SHIFT', key = 'h', action = wezterm.action.AdjustPaneSize({ 'Left', 1 }) },
    { mods = 'CTRL|SHIFT', key = 'j', action = wezterm.action.AdjustPaneSize({ 'Down', 1 }) },
    { mods = 'CTRL|SHIFT', key = 'k', action = wezterm.action.AdjustPaneSize({ 'Up', 1 }) },
    { mods = 'CTRL|SHIFT', key = 'l', action = wezterm.action.AdjustPaneSize({ 'Right', 1 }) },
    { mods = 'ALT',        key = 'h', action = wezterm.action.ActivateTabRelative(-1) },
    { mods = 'ALT',        key = 'j', action = wezterm.action.MoveTabRelative(-1) },
    { mods = 'ALT',        key = 'k', action = wezterm.action.MoveTabRelative(1) },
    { mods = 'ALT',        key = 'l', action = wezterm.action.ActivateTabRelative(1) },
  })
)

config.set_environment_variables = {}
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.set_environment_variables['prompt'] = '$E[35m$P$E[36m$_$G$E[0m '
end

return config
