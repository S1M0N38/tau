-- tau terminal settings for WezTerm
-- Copy this into your wezterm.lua (~/.config/wezterm/wezterm.lua)

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Required for tau
config.enable_kitty_keyboard = true -- pi needs Shift+Enter, Ctrl+Enter, Alt+Enter
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 } -- tmux fills full terminal

-- Recommended for tau
config.color_scheme = "Tokyo Night Moon"
config.enable_tab_bar = false -- tmux handles tabs
config.font = wezterm.font("Maple Mono NF")
config.font_size = 13
config.term = "wezterm"

-- macOS specific
config.window_decorations = "RESIZE | MACOS_FORCE_DISABLE_SHADOW"

-- ═══════════════════════════════════════════════════════════════════════
-- Key bindings: WezTerm → tmux escape sequences
--
-- Each binding sends a unique escape sequence that tmux maps to a
-- user-key, which is then bound to an action. This is how prefix-less
-- keybindings work through the WezTerm → tmux → pi chain.
-- ═══════════════════════════════════════════════════════════════════════

config.keys = {
  -- ── Window navigation ──────────────────────────────────────────────
  -- Cmd+H / Cmd+L → tmux user-keys (User0 / User1) — cycle windows
  { key = "h", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[1;9P" }) },
  { key = "l", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[1;9Q" }) },
  -- Cmd+1-9 → tmux user-keys (User10-18) — select window by number
  { key = "1", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[23;9~" }) },
  { key = "2", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[24;9~" }) },
  { key = "3", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[25;9~" }) },
  { key = "4", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[26;9~" }) },
  { key = "5", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[28;9~" }) },
  { key = "6", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[29;9~" }) },
  { key = "7", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[31;9~" }) },
  { key = "8", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[32;9~" }) },
  { key = "9", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[33;9~" }) },

  -- ── Session navigation ─────────────────────────────────────────────
  -- Cmd+Shift+H / Cmd+Shift+L → tmux user-keys (User2 / User3) — cycle sessions
  { key = "H", mods = "SUPER|SHIFT", action = wezterm.action({ SendString = "\x1b[1;9R" }) },
  { key = "L", mods = "SUPER|SHIFT", action = wezterm.action({ SendString = "\x1b[1;9S" }) },

  -- ── Window/session reordering ───────────────────────────────────────
  -- Super+Left / Super+Right → tmux user-keys (User6 / User7) — reorder windows
  { key = "LeftArrow", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[18;9~" }) },
  { key = "RightArrow", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[19;9~" }) },
  -- Super+Shift+Left / Super+Shift+Right → tmux user-keys (User8 / User9) — reorder sessions
  { key = "LeftArrow", mods = "SUPER|SHIFT", action = wezterm.action({ SendString = "\x1b[20;9~" }) },
  { key = "RightArrow", mods = "SUPER|SHIFT", action = wezterm.action({ SendString = "\x1b[21;9~" }) },

  -- ── Actions ─────────────────────────────────────────────────────────
  -- Cmd+T → tmux user-key (User4) — new window in current directory
  { key = "t", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[15;9~" }) },
  -- Cmd+A → tmux user-key (User5) — spawn pi pane in grid layout
  { key = "a", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[17;9~" }) },
  -- Cmd+G → tmux user-key (User28) — lazygit floating popup
  { key = "g", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[43;9~" }) },
  -- Cmd+E → tmux user-key (User29) — editor floating popup (LazyVim)
  { key = "e", mods = "SUPER", action = wezterm.action({ SendString = "\x1b[44;9~" }) },

  -- ── Pass-through & overrides ────────────────────────────────────────
  -- Alt+Enter passthrough (for pi and other TUI tools)
  { key = "Enter", mods = "ALT", action = wezterm.action({ SendString = "\x1b[13;3u" }) },
  -- Disable Ctrl+=/- so they don't intercept zoom shortcuts
  { key = "=", mods = "CTRL", action = wezterm.action.Nop },
  { key = "-", mods = "CTRL", action = wezterm.action.Nop },
  { key = "-", mods = "CTRL|SHIFT", action = wezterm.action.Nop },
  { key = "=", mods = "CTRL|SHIFT", action = wezterm.action.Nop },
}

return config
