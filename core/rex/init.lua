-- Migrated from ~/.tmux.conf and ~/.wezterm.lua

-- tmux
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })

-- WezTerm
rex.bind("alt+1", "client.tab.goto", { index = 1 })
rex.bind("alt+2", "client.tab.goto", { index = 2 })
rex.bind("alt+3", "client.tab.goto", { index = 3 })
rex.bind("alt+4", "client.tab.goto", { index = 4 })
rex.bind("alt+5", "client.tab.goto", { index = 5 })
rex.bind("alt+6", "client.tab.goto", { index = 6 })
rex.bind("alt+7", "client.tab.goto", { index = 7 })
rex.bind("alt+8", "client.tab.goto", { index = 8 })
rex.bind("alt+9", "client.tab.goto", { index = 9 })
rex.bind("alt+h", "client.tab.previous")
rex.bind("alt+j", "client.tab.move", { direction = "backward" })
rex.bind("alt+k", "client.tab.move", { direction = "forward" })
rex.bind("alt+l", "client.tab.next")
rex.bind("ctrl+t", "client.tab.new")

-- Pane navigation (vim-style)
rex.bind("ctrl+h", "pane.focus.left")
rex.bind("ctrl+j", "pane.focus.down")
rex.bind("ctrl+k", "pane.focus.up")
rex.bind("ctrl+l", "pane.focus.right")

-- Pane resize (moves the divider in that direction)
rex.bind("ctrl+shift+h", "pane.resize", { direction = "left" })
rex.bind("ctrl+shift+j", "pane.resize", { direction = "down" })
rex.bind("ctrl+shift+k", "pane.resize", { direction = "up" })
rex.bind("ctrl+shift+l", "pane.resize", { direction = "right" })

-- Replacements for Rex's Cmd defaults (Cmd+letter is rewritten to Option by Karabiner)
rex.bind("alt+w", "client.close")
rex.bind("ctrl+p", "client.palette.toggle")
rex.bind("alt+s", "session.switch")
rex.bind("alt+0", "client.font.reset")

-- Split in a direction. On the Windows keyboards the physical Alt key reaches Rex as
-- Cmd when Ctrl is also held (Karabiner only rewrites plain Cmd+key), so bind both.
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+alt+" .. key, "pane.split", { direction = dir })
  rex.bind("ctrl+cmd+" .. key, "pane.split", { direction = dir })
end
