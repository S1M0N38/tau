# tau (τ)

A terminal multiplexer and configuration layer providing **WezTerm + tmux** setup for working with multiple [pi](https://github.com/badlogic/pi-mono) coding agent instances.

The name is a wordplay on pi (π → τ): tau is 2π, because one pi agent is never enough.

## Quick Start

```bash
# Symlink configs
ln -s ~/Developer/tau/config/wezterm.lua ~/.config/wezterm/wezterm.lua
ln -s ~/Developer/tau/config/tmux.conf ~/.config/tmux/tmux.conf

# Symlink scripts
ln -s ~/Developer/tau/scripts/tau-sessionizer ~/.local/bin/tau-sessionizer
ln -s ~/Developer/tau/scripts/tau-status-sessions ~/.local/bin/tau-status-sessions
ln -s ~/Developer/tau/scripts/tau-cycle-session ~/.local/bin/tau-cycle-session
ln -s ~/Developer/tau/scripts/tau-swap-session ~/.local/bin/tau-swap-session
ln -s ~/Developer/tau/scripts/tau-spawn-pi ~/.local/bin/tau-spawn-pi
ln -s ~/Developer/tau/scripts/tau-select-session ~/.local/bin/tau-select-session

# Drop sidekick.lua into your LazyVim config
ln -s ~/Developer/tau/sidekick.lua ~/.config/nvim/lua/plugins/sidekick.lua

# Restart tmux (required for extended-keys to take effect)
tmux kill-server
```

## Requirements

| Component | Minimum Version |
|-----------|----------------|
| WezTerm | latest stable |
| tmux | 3.6+ |
| pi | latest |

---

## Keymaps

### Window Management

Navigate and manage tmux windows within the current session.

| Keymap | Action |
|--------|--------|
| `Cmd + H` | Previous window |
| `Cmd + L` | Next window |
| `Cmd + 1` – `Cmd + 9` | Jump to window by number |
| `Cmd + T` | New window (inherits cwd) |
| `Super + ←` | Move window left (swap with previous) |
| `Super + →` | Move window right (swap with next) |

### Session Management

Switch and manage project sessions. Only sessions tagged `@type=project` are considered — agent, scratch, and other session types are skipped.

| Keymap | Action |
|--------|--------|
| `Cmd + Shift + H` | Previous project session |
| `Cmd + Shift + L` | Next project session |
| `Cmd + Alt + Shift + 1` – `Cmd + Alt + Shift + 9` | Jump to project session by position (matches status bar numbering) |
| `Super + Shift + ←` | Reorder current project session left (swap sort index with previous) |
| `Super + Shift + →` | Reorder current project session right (swap sort index with next) |
| `Prefix + F` | Sessionizer — fzf popup to pick/create a project from `~/Developer` |

### Pane Management

Split, navigate, and arrange panes.

| Keymap | Action |
|--------|--------|
| `Ctrl + H` | Move to left pane (Neovim-aware: passes through to splits first) |
| `Ctrl + J` | Move to bottom pane (Neovim-aware) |
| `Ctrl + K` | Move to top pane (Neovim-aware) |
| `Ctrl + L` | Move to right pane (Neovim-aware) |
| `Prefix + \|` | Horizontal split (side by side) — inherits cwd |
| `Prefix + -` | Vertical split (top/bottom) — inherits cwd |
| `Cmd + A` | Spawn pi pane and arrange all panes in a grid layout |
| `Cmd + G` | Open lazygit in a floating popup (90%×90%) |

### Pi / sidekick (inside Neovim terminal)

Keys that reach pi through the WezTerm → tmux → Neovim → pi chain.

| Keymap | Action |
|--------|--------|
| `Shift + Enter` | New line in pi (CSI-u passthrough) |
| `Alt + Enter` | Alternative enter in pi (CSI-u passthrough) |
| `Ctrl + P` | Ctrl+P in pi (CSI-u passthrough) |
| `Esc` | Send Esc to pi (single tap) / exit terminal mode (double tap within 200ms) |

### Neovim / sidekick Leader Bindings

Access pi through sidekick.nvim inside Neovim (`<leader>a` prefix).

| Keymap | Action |
|--------|--------|
| `<leader>ac` | Spawn pi |
| `<leader>aC` | Select tool |
| `<leader>as` | Sessions |
| `<leader>at` | Toggle terminal |
| `<leader>ap` | Send prompt |
| `<leader>ah` | Hide terminal |
| `<leader>aq` | Close session |

### Copy Mode

Vi-style keybindings for tmux's scrollback/selection buffer.

| Keymap | Action |
|--------|--------|
| `Prefix + [` | Enter copy mode |
| `v` | Begin character-wise selection |
| `V` | Begin line-wise selection |
| `y` | Yank selection to system clipboard |
| `Esc` | Cancel selection |

### Miscellaneous

| Keymap | Action |
|--------|--------|
| `Prefix + R` | Reload tmux config |
| `Ctrl + =` / `Ctrl + -` | Disabled (Nop) — prevents WezTerm zoom so tmux/Neovim can handle them |

---

## How It Works

All prefix-less key bindings follow the same pattern:

```
WezTerm → (escape sequence) → tmux → (user-key binding) → action
```

WezTerm intercepts the native keypress and sends a custom escape sequence. tmux maps each sequence to a numbered user-key (User0–28), which is then bound to an action. This bypasses tmux's prefix entirely for a seamless experience.

For keys that need to reach pi inside Neovim's terminal, the chain is longer:

```
WezTerm → (kitty keyboard protocol) → tmux → (CSI-u extkeys) → Neovim/sidekick → pi
```

## Status Bar

The status bar shows three sections:

- **Left** — current session name
- **Center** — window list (current window highlighted in blue)
- **Right** — clickable list of project sessions with position numbers matching `Cmd+Alt+Shift+1-9`

## Session Tagging

Sessions use tmux user options for identity and ordering:

```bash
tmux set-option -t <session> @type "project"       # session type: project | agent | scratch
tmux set-option -t <session> @project "my-app"      # display name (groups related sessions)
tmux set-option -t <session> @sort-index "2"        # sort order in status bar and cycling
```

## Theme

Everything uses **Tokyo Night Moon** with matching true-color hex codes across WezTerm, tmux, and Neovim.
