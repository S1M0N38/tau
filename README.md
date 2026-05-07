# tau (τ)

A terminal multiplexer and configuration layer providing **WezTerm + tmux** setup for working with multiple [pi](https://github.com/badlogic/pi-mono) coding agent instances.

The name is a wordplay on pi (π → τ): tau is 2π, because one pi agent is never enough.

## Quick Start

```bash
# Install dependencies
npm install -g @mariozechner/pi-coding-agent

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
ln -s ~/Developer/tau/scripts/tau-toggle-editor ~/.local/bin/tau-toggle-editor

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
| `Cmd + E` | Open editor popup (90%×90%) — LazyVim, close with `:q` |

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

WezTerm intercepts the native keypress and sends a custom escape sequence. tmux maps each sequence to a numbered user-key (User0–29), which is then bound to an action. This bypasses tmux's prefix entirely for a seamless experience.

For modified keys that need to reach pi (e.g. Shift+Enter, Alt+Enter), the CSI-u chain is:

```
WezTerm → (kitty keyboard protocol) → tmux → (CSI-u extkeys) → pi
```

## Status Bar

The status bar shows two sections:

- **Left** — window list (current window highlighted on a blue badge)
- **Right** — clickable list of project sessions with position numbers and `@project` names, sorted by `@sort-index`

## Session Tagging

Sessions use tmux user options for identity and ordering:

```bash
tmux set-option -t <session> @type "project"       # session type: project | agent | scratch
tmux set-option -t <session> @project "my-app"      # display name (groups related sessions)
tmux set-option -t <session> @sort-index "2"        # sort order in status bar and cycling
```

## Theme

Everything uses **Tokyo Night Moon** with matching true-color hex codes across WezTerm, tmux, and Neovim.
