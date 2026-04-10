# Agent Cheat Sheet

**tau** (τ) is a terminal development environment for working with multiple [pi](https://github.com/badlogic/pi-mono) coding agent instances. It layers WezTerm → tmux → Neovim (LazyVim) → [sidekick.nvim](https://github.com/folke/sidekick.nvim) into a coherent workflow where tmux is the persistent orchestration layer.

The name is a wordplay on pi (π → τ): tau is 2π, because one pi agent is never enough.

## Architecture

```
┌────────────────────────────────────────────────────┐
│  WezTerm (terminal emulator)                       │
│  ┌───────────────────────────────────────────────┐ │
│  │  tmux (session multiplexer)                   │ │
│  │  ┌──────────────┐  ┌───────────┐  ┌─────────┐ │ │
│  │  │ session 1    │  │ session 2 │  │ ...     │ │ │
│  │  │ project-a    │  │ project-b │  │         │ │ │
│  │  │ ┌──────────┐ │  │ ┌───────┐ │  │         │ │ │
│  │  │ │ nvim     │ │  │ │ pi    │ │  │         │ │ │
│  │  │ │ sidekick │ │  │ │ TUI   │ │  │         │ │ │
│  │  │ └──────────┘ │  │ └───────┘ │  │         │ │ │
│  │  └──────────────┘  └───────────┘  └─────────┘ │ │
│  └───────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────┘
```

- **WezTerm** — renders everything, handles kitty keyboard protocol for reliable modifier keys
- **tmux** — persistent sessions, one per project; status bar; sessionizer
- **Neovim + LazyVim** — editor, with sidekick.nvim as the AI integration point
- **pi** — runs either as a standalone TUI in a tmux pane, or embedded inside Neovim via sidekick's terminal

## Project Structure

```
tau/
├── wezterm.lua      # WezTerm config → symlink to ~/.wezterm.lua
├── tmux.conf        # tmux config    → symlink to ~/.config/tmux/tmux.conf
├── sidekick.lua     # sidekick.nvim plugin spec → drop into LazyVim config
├── .editorconfig    # Lua formatting rules for this repo
├── AGENTS.md        # this file
└── ROADMAP.md       # future plans (separate file)
```

All config files are standalone — the user symlinks or copies them to the correct location.

## Config Files

### wezterm.lua — WezTerm Configuration

Key settings:
- **Kitty keyboard protocol** (`enable_kitty_keyboard = true`) — required for pi to detect modifier keys (Shift+Enter, Ctrl+Enter, Alt+Enter)
- **Tokyo Night Moon** color scheme, **Maple Mono NF** font at 13pt
- **No tab bar** — tmux handles window/tab management
- **Alt+Enter** CSI-u passthrough — sends `\x1b[13;3u` so tmux forwards the key correctly to pi/sidekick
- **Ctrl+=/-/Shift variants** disabled to prevent terminal zoom, letting tmux handle those

Target: `~/.wezterm.lua`

### tmux.conf — tmux Configuration

Optimized for Neovim + pi coexistence:
- **Mouse on**, **base-index 1**, **renumber-windows** — ergonomic defaults
- **Vi copy mode** — consistent hjkl muscle memory with Neovim
- **escape-time 10ms** — eliminates lag when pressing Esc in Neovim normal mode
- **Focus events** — Neovim can detect when you switch back to a pane
- **Cursor shape passthrough** — block/line/beam cursor follows Neovim mode
- **CSI-u extended keys** (`extended-keys always`, `extended-keys-format csi-u`) — critical for pi's Shift+Enter and Ctrl+Enter keybindings to work through tmux
- **Terminal features** for xterm* and wezterm* advertise extkey support
- **Intuitive splits**: `prefix |` (horizontal), `prefix -` (vertical), new pane inherits cwd

Target: `~/.config/tmux/tmux.conf`

### sidekick.lua — sidekick.nvim Plugin Spec

A LazyVim plugin spec for [sidekick.nvim](https://github.com/folke/sidekick.nvim) configured to work with tau's tmux setup:
- **tmux mux backend** (`mux.backend = "tmux"`, `mux.enabled = true`) — pi sessions persist in tmux, surviving Neovim restarts
- **Shift+Enter** CSI-u passthrough — sends `\x1b[13;2u` so pi receives the key correctly when running inside sidekick's terminal
- **Alt+Enter** CSI-u passthrough — same for `\x1b[13;3u`
- **Double-tap Esc to exit terminal mode** — single Esc passes through to pi (for normal mode), double-tap exits to Neovim normal mode

Target: drop into LazyVim's plugin specs directory (e.g., `~/.config/nvim/lua/plugins/sidekick.lua`)

## Key Dependencies

| Component | Minimum Version |
|-----------|----------------|
| WezTerm | latest stable |
| tmux | 3.6+ |
| Neovim | 0.12+ |
| LazyVim | latest |
| sidekick.nvim | latest |
| pi | latest |

## Setup

```bash
# 1. Install dependencies
npm install -g @mariozechner/pi-coding-agent

# 2. Symlink configs
ln -s ~/Developer/tau/wezterm.lua ~/.wezterm.lua
ln -s ~/Developer/tau/tmux.conf ~/.config/tmux/tmux.conf

# 3. Drop sidekick.lua into your LazyVim config
ln -s ~/Developer/tau/sidekick.lua ~/.config/nvim/lua/plugins/sidekick.lua

# 4. Restart everything (tmux must be fully restarted for extkeys)
tmux kill-server
```

## How the Key Chain Works

Modified keys must pass through three layers to reach pi. Each layer must be configured:

```
WezTerm → (kitty keyboard protocol) → tmux → (CSI-u extkeys) → Neovim/sidekick → pi
```

- **WezTerm**: `enable_kitty_keyboard = true` encodes Shift+Enter as `\x1b[13;2u`
- **tmux**: `extended-keys always` + `extended-keys-format csi-u` forwards the sequence unchanged
- **sidekick.lua**: explicitly sends `\x1b[13;2u` via `nvim_chan_send` since Neovim's terminal may not pass through CSI-u sequences from `<S-CR>` mapping

## Editing Conventions

- All Lua files use **2-space indentation**, double quotes, 120 char max line length (see `.editorconfig`)
- tmux.conf uses **comment blocks** explaining each setting — maintain that style when adding config
- When adding tmux keybindings, prefer `prefix + single key` over chords

## Things to Watch

- **tmux must be fully restarted** (`tmux kill-server`) after changing `extended-keys` settings — reload (`prefix r`) is not enough
- **WezTerm's Ctrl+=/- bindings** are intentionally disabled (`action.Nop`) to prevent the terminal from intercepting zoom shortcuts that tmux or Neovim may use
- **sidekick.lua Esc behavior**: the 200ms double-tap timer means a single Esc always goes to pi. If pi responsiveness feels slow, the timer value in `stopinsert_esc` may need tuning
- **No custom pi CLI for sidekick**: sidekick does not ship a `sk/cli/pi.lua` definition. Pi is launched as a generic terminal inside sidekick — do not add one without checking upstream first
