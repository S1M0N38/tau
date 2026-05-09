# tau (τ)

A self-contained terminal workspace for [pi](https://github.com/badlogic/pi-mono) coding agents. One command, zero config files touched.

The name is a wordplay on pi (π → τ): tau is 2π, because one pi agent is never enough.

## How It Works

tau runs an isolated tmux server with its own socket and config — completely independent from any user tmux sessions or terminal emulator settings.

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

**What tau does NOT touch:** your `~/.config/tmux/`, your `~/.config/wezterm/`, or anything else in `$HOME`. tau's tmux config lives in the repo and is loaded via the `-f` flag. Terminal emulator settings are documented as reference snippets in `terminals/`.

## Quick Start

```bash
# 1. Install dependencies
npm install -g @mariozechner/pi-coding-agent

# 2. Install tau (pick one)
ln -s ~/Developer/tau/bin/tau ~/.local/bin/tau   # symlink
# or
make install                                      # same thing

# 3. Start tau
tau
```

That's it. Run `tau` from a plain terminal — it attaches to an existing server or starts a new one.

## Requirements

| Component | Minimum Version |
|-----------|----------------|
| WezTerm | latest stable |
| tmux | 3.6+ |
| pi | latest |

Your terminal emulator needs kitty keyboard protocol, true color support, and zero padding. See [terminals/](terminals/) for setup instructions.

## Installation

### Option A: Single symlink

```bash
git clone https://github.com/user/tau.git ~/Developer/tau
ln -s ~/Developer/tau/bin/tau ~/.local/bin/tau
```

### Option B: Add to PATH

```bash
git clone https://github.com/user/tau.git ~/Developer/tau
echo 'export PATH="$HOME/Developer/tau/bin:$PATH"' >> ~/.bashrc
```

### Uninstall

```bash
rm ~/.local/bin/tau   # if symlinked
tmux -L tau kill-server  # stop the server
```

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

tau's config lives at `config/tmux.conf` in the repo. Edit it directly — fork-and-modify workflow. No symlinks, no overlays, no backup/restore.

Terminal emulator settings are in `terminals/` as reference snippets. Copy what you need into your own config.

## Theme

Everything uses **Tokyo Night Moon** with matching true-color hex codes across WezTerm, tmux, and Neovim.
