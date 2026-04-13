local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Set $TERM environment variable
config.term = "wezterm"

-- MacOS specific settings
config.window_decorations = "RESIZE | MACOS_FORCE_DISABLE_SHADOW"

-- Disable the tab bar
config.enable_tab_bar = false

-- Font
config.font_size = 13
config.font = wezterm.font("Maple Mono NF")

-- Colors
config.color_scheme = "Tokyo Night Moon"

---Keys
config.keys = {
  -- Cmd+H / Cmd+L → tmux user-keys (User0 / User1) for prefix-less pane navigation
  { key = "h", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[1;9P" }) },
  { key = "l", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[1;9Q" }) },
  -- Cmd+Shift+H / Cmd+Shift+L → tmux user-keys (User2 / User3) for session cycling
  { key = "H", mods = "SUPER|SHIFT", action = wezterm.action({ SendString = "\x1b[1;9R" }) },
  { key = "L", mods = "SUPER|SHIFT", action = wezterm.action({ SendString = "\x1b[1;9S" }) },
  -- Super+Left / Super+Right → tmux user-keys (User6 / User7) for window reordering
  { key = "LeftArrow", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[18;9~" }) },
  { key = "RightArrow", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[19;9~" }) },
  -- Super+Shift+Left / Super+Shift+Right → tmux user-keys (User8 / User9) for session reordering
  { key = "LeftArrow", mods = "SUPER|SHIFT", action = wezterm.action({ SendString = "\x1b[20;9~" }) },
  { key = "RightArrow", mods = "SUPER|SHIFT", action = wezterm.action({ SendString = "\x1b[21;9~" }) },
  -- Cmd+T → tmux user-key (User4) for new window
  { key = "t", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[15;9~" }) },
  -- Cmd+A → tmux user-key (User5) for spawning a new pi pane in a grid layout
  { key = "a", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[17;9~" }) },
  { key = "Enter", mods = "ALT", action = wezterm.action({ SendString = "\x1b[13;3u" }) },
  { key = "=", mods = "CTRL", action = wezterm.action.Nop },
  { key = "-", mods = "CTRL", action = wezterm.action.Nop },
  { key = "-", mods = "CTRL|SHIFT", action = wezterm.action.Nop },
  { key = "=", mods = "CTRL|SHIFT", action = wezterm.action.Nop },
}
config.enable_kitty_keyboard = true

-- Remove all window padding so tmux fills the entire terminal
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

return config
