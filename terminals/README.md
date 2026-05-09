# Terminal Emulator Settings for tau

tau runs inside your terminal emulator as an isolated tmux server.
For the best experience, your terminal needs:

## Required

| Setting | Why |
|---------|-----|
| Kitty keyboard protocol | pi uses Shift+Enter, Ctrl+Enter, Alt+Enter — only works with kitty keyboard protocol |
| True color (24-bit) | Tokyo Night Moon colorscheme requires true color support |
| Zero padding | tau's tmux fills the full terminal — any padding creates visible gaps |

## Recommended

| Setting | Why |
|---------|-----|
| No tab bar | tmux handles window/tab management |
| Maple Mono NF font | Nerd Font icons in status bar and pi |
| Dark theme matching Tokyo Night Moon | Consistent look when tau's tmux fills the screen |

## Configuration Files

Pick your terminal:

- [WezTerm](wezterm.lua) — copy into your `wezterm.lua`
