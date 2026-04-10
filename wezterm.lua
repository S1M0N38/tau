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
  { key = "Enter", mods = "ALT", action = wezterm.action({ SendString = "\x1b[13;3u" }) },
  { key = "=", mods = "CTRL", action = wezterm.action.Nop },
  { key = "-", mods = "CTRL", action = wezterm.action.Nop },
  { key = "-", mods = "CTRL|SHIFT", action = wezterm.action.Nop },
  { key = "=", mods = "CTRL|SHIFT", action = wezterm.action.Nop },
}
config.enable_kitty_keyboard = true

return config
