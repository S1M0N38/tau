<div align="center">
  <h1>τ</h1>
  <p><em>double your π</em></p>
  <hr>
</div>

## Philosophy

One agent is never enough. A single pi session is powerful — but real work means juggling projects, switching contexts, keeping multiple conversations alive. tau gives each project its own session, each agent its own pane, and lets you move between them without friction.

tau doesn't touch your config. No dotfile surgery, no backup rituals, no "let me restore my tmux after this." It runs an isolated tmux server with its own socket and its own config — completely independent from anything else on your system. Start it, use it, kill it. Your setup stays pristine.

## How It Works

```
User's WezTerm (user's config, untouched)
└── $ tau                          ← one command
    └── tmux -L tau -f <config>   ← isolated server, own socket, own config
        ├── session: project-a
        │   ├── pane: nvim
        │   └── pane: pi agent
        └── session: project-b
            └── pane: pi agent
```

tau lives entirely in its own directory. The tmux config is loaded via `-f`, terminal settings are reference snippets you copy into your own config. Nothing is symlinked into `$HOME`. Fork-and-modify is the only workflow.

## Quick Start

```bash
# 1. Install dependencies
npm install -g @mariozechner/pi-coding-agent

# 2. Install tau
git clone https://github.com/S1M0N38/tau.git ~/Developer/tau
ln -s ~/Developer/tau/bin/tau ~/.local/bin/tau

# 3. Start
tau
```

That's it. Run `tau` from a plain terminal — it attaches to an existing server or starts a new one.

## Requirements

| Component | Minimum Version |
|-----------|----------------|
| WezTerm | latest stable |
| tmux | 3.6+ |
| pi | latest |
| fzf | latest |

Your terminal needs kitty keyboard protocol, true color support, and zero padding. See [terminals/](terminals/) for setup instructions.

## Key Bindings

### Window Management

| Key | Action |
|-----|--------|
| `Cmd+H` / `Cmd+L` | Previous / next window |
| `Cmd+1` – `Cmd+9` | Jump to window by number |
| `Cmd+T` | New window (inherits cwd) |
| `Super+←` / `Super+→` | Move window left / right |

### Session Management

| Key | Action |
|-----|--------|
| `Cmd+Shift+H` / `Cmd+Shift+L` | Previous / next session |
| `Super+Shift+←` / `Super+Shift+→` | Reorder session left / right |
| `Prefix+f` | Sessionizer — fzf popup to pick/create a project from `~/Developer` |

### Pane Management

| Key | Action |
|-----|--------|
| `Ctrl+H` / `Ctrl+J` / `Ctrl+K` / `Ctrl+L` | Navigate panes (Neovim-aware) |
| `Prefix+|` | Horizontal split — inherits cwd |
| `Prefix+-` | Vertical split — inherits cwd |
| `Cmd+A` | Spawn pi pane in grid layout |
| `Cmd+G` | Open lazygit in floating popup |
| `Cmd+E` | Open LazyVim in floating popup |

### Miscellaneous

| Key | Action |
|-----|--------|
| `Prefix+r` | Reload tau config |
| `Prefix+[` | Enter copy mode (vi keys: `v` select, `V` line, `y` yank) |

## Customization

Edit `config/tmux.conf` in the repo directly. No symlinks, no overlays, no backup/restore. Terminal emulator settings are in `terminals/` as reference snippets — copy what you need into your own config.

## Theme

Everything uses **Tokyo Night Moon** with matching true-color hex codes across WezTerm, tmux, and Neovim.
