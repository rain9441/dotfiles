local wezterm = require('wezterm')
local config = wezterm.config_builder()

config.initial_cols = 150
config.initial_rows = 30
config.use_ime = true
config.macos_forward_to_ime_modifier_mask = ""

wezterm.on("gui-startup", function()
  local tab, pane, window = wezterm.mux.spawn_window{}
  window:gui_window():maximize()
end)


-- or, changing the font size and color scheme.
config.font_size = 12
config.color_scheme = 'Dracula+'
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.default_cwd = wezterm.target_triple:match('windows') and 'c:/projects' or wezterm.home_dir .. '/projects'
config.use_dead_keys = false
config.font = wezterm.font('RobotoMono Nerd Font')

-- Use Option as Alt/Meta
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm").apply_to_config(config)

local function whenNotInProcess(keys, patterns)
  local copy = {}
  for ix, key_info in pairs(keys) do
    copy[ix] = {
      mods = key_info.mods,
      key = key_info.key,
      action = wezterm.action_callback(function(window, pane)
        local process_name = pane:get_foreground_process_name()
        for _, pattern in ipairs(patterns) do
          if process_name:match(pattern) then
            window:perform_action(wezterm.action({ SendKey = { mods = key_info.mods, key = key_info.key } }), pane)
            return
          end
        end
        window:perform_action(key_info.action, pane)
      end)
    }
  end
  return copy
end

local function merge(tables)
  local result = {}
  for _, tbl in ipairs(tables) do
    for _, v in pairs(tbl) do
      table.insert(result, v)
    end
  end
  return result
end

local nvim_patterns = { 'nvim.exe$', 'nvim$', 'wslhost.exe$' }
local nvim_tmux_patterns = merge({ nvim_patterns, { 'tmux$' } })

local function whenNotNvim(keys) return whenNotInProcess(keys, nvim_patterns) end
local function whenNotNvimNorTmux(keys) return whenNotInProcess(keys, nvim_tmux_patterns) end

config.keys = merge({
  {
    { mods = 'ALT', key = '1', action = wezterm.action.ActivateTab(0) },
    { mods = 'ALT', key = '2', action = wezterm.action.ActivateTab(1) },
    { mods = 'ALT', key = '3', action = wezterm.action.ActivateTab(2) },
    { mods = 'ALT', key = '4', action = wezterm.action.ActivateTab(3) },
    { mods = 'ALT', key = '5', action = wezterm.action.ActivateTab(4) },
    { mods = 'ALT', key = '6', action = wezterm.action.ActivateTab(5) },
    { mods = 'ALT', key = '7', action = wezterm.action.ActivateTab(6) },
    { mods = 'ALT', key = '8', action = wezterm.action.ActivateTab(7) },
    { mods = 'ALT', key = '9', action = wezterm.action.ActivateTab(8) },
    { mods = 'ALT', key = 'h', action = wezterm.action.ActivateTabRelative(-1) },
    { mods = 'ALT', key = 'j', action = wezterm.action.MoveTabRelative(-1) },
    { mods = 'ALT', key = 'k', action = wezterm.action.MoveTabRelative(1) },
    { mods = 'ALT', key = 'l', action = wezterm.action.ActivateTabRelative(1) },
    { mods = 'CTRL', key = 't', action = wezterm.action.SpawnTab('CurrentPaneDomain') },
  },
  whenNotNvim({
    { mods = 'CTRL',       key = 'Tab', action = wezterm.action.ActivateTabRelative(1) },
    { mods = 'CTRL|SHIFT', key = 'Tab', action = wezterm.action.ActivateTabRelative(-1) },
    { mods = 'CTRL', key = '1', action = wezterm.action.ActivateTab(0) },
    { mods = 'CTRL', key = '2', action = wezterm.action.ActivateTab(1) },
    { mods = 'CTRL', key = '3', action = wezterm.action.ActivateTab(2) },
    { mods = 'CTRL', key = '4', action = wezterm.action.ActivateTab(3) },
    { mods = 'CTRL', key = '5', action = wezterm.action.ActivateTab(4) },
    { mods = 'CTRL', key = '6', action = wezterm.action.ActivateTab(5) },
    { mods = 'CTRL', key = '7', action = wezterm.action.ActivateTab(6) },
    { mods = 'CTRL', key = '8', action = wezterm.action.ActivateTab(7) },
    { mods = 'CTRL', key = '9', action = wezterm.action.ActivateTab(8) },
    { mods = 'CTRL',       key = 'p', action = wezterm.action.ActivateCommandPalette },
  }),
  whenNotNvimNorTmux({
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
  }),
})

config.set_environment_variables = {}
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.set_environment_variables['prompt'] = '$E[35m$P$E[36m$_$G$E[0m '
end

return config
