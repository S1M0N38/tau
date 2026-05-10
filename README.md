
<div align="center">
  <h1>τ</h1>
  <img width="640" height="396" alt="tau" src="https://github.com/user-attachments/assets/73d6f22a-4bab-4bc7-82fe-9d2cb8436a4b" />
  <p><em>double your π</em></p>
  <hr>
</div>

tau is a preconfigured terminal workspace built on an isolated tmux server. One command gives you sane defaults — vi copy mode, true color, prefix-less key bindings, project sessions, popup overlays — without touching a single dotfile.

It pairs particularly well with [pi](https://github.com/earendil-works/pi) coding agents: `Cmd+A` spawns an agent pane and arranges all panes into a clean grid. But pi is just a feature, not the point. tau works great with any terminal workflow.

```
User's terminal (WezTerm or Ghostty — user's config, untouched)
└── $ tau                          ← one command
    └── tmux -L tau -f <config>   ← isolated server, own socket, own config
        ├── session: project-a
        │   ├── pane: nvim
        │   └── pane: pi agent
        └── session: project-b
            └── pane: pi agent
```

tau lives entirely in its own directory. The tmux config is loaded via `-f`, terminal settings are reference snippets you copy into your own config. No config files are modified — fork-and-modify is the only workflow.

## 📦 Requirements

| Component | Minimum Version |
|-----------|----------------|
| WezTerm or Ghostty | latest stable |
| tmux | 3.6+ |
| fzf | latest |
| pi *(optional)* | latest |

Your terminal needs kitty keyboard protocol, true color support, and zero padding. See [terminals/](terminals/) for setup instructions.

## ⚡ Quick Start

```bash
# 1. Install tau
git clone https://github.com/S1M0N38/tau.git ~/Developer/tau
ln -s ~/Developer/tau/bin/tau ~/.local/bin/tau

# 2. Configure environment variables
export TAU_PROJECT_DIR=~/Developer          # required — tau won't start without it
export TAU_EDITOR_CMD="env NVIM_APPNAME=lazyvim nvim"  # optional — for Cmd+E popup
export TAU_GIT_CMD=lazygit                 # optional — for Cmd+G popup

# 3. Start
tau
```

That's it. Run `tau` from a plain terminal — it attaches to an existing server or starts a new one.

Want coding agent integration? Install [pi](https://github.com/earendil-works/pi) (`npm install -g @earendil-works/pi-coding-agent`) and `Cmd+A` will spawn agent panes in a grid layout.

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `TAU_PROJECT_DIR` | **yes** | — | Directory containing your projects. tau refuses to start if unset or missing. Used by the sessionizer (`Prefix+f`). |
| `TAU_EDITOR_CMD` | no | — | Command launched by `Cmd+E` in a floating popup. Shows a tmux notification if unset. |
| `TAU_GIT_CMD` | no | — | Command launched by `Cmd+G` in a floating popup. Shows a tmux notification if unset. |
| `TAU_AGENT_CMD` | no | `pi` | Command spawned by `Cmd+A` in grid layout. Defaults to `pi`. |


## ⌨️ Key Bindings

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
| `Prefix+f` | Sessionizer — fzf popup to pick/create a project from `$TAU_PROJECT_DIR` |

### Pane Management

| Key | Action |
|-----|--------|
| `Ctrl+H` / `Ctrl+J` / `Ctrl+K` / `Ctrl+L` | Navigate panes (Neovim-aware) |
| `Prefix+\|` | Horizontal split — inherits cwd |
| `Prefix+-` | Vertical split — inherits cwd |
| `Cmd+A` | Spawn pi pane in grid layout |
| `Cmd+G` | Open `$TAU_GIT_CMD` in floating popup |
| `Cmd+E` | Open `$TAU_EDITOR_CMD` in floating popup |

### Miscellaneous

| Key | Action |
|-----|--------|
| `Prefix+r` | Reload tau config |
| `Prefix+[` | Enter copy mode (vi keys: `v` select, `V` line, `y` yank) |

<details>
<summary><strong>Navigator.nvim</strong> — seamless Ctrl+H/J/K/L pane navigation</summary>

tau's <code>Ctrl+H/J/K/L</code> key bindings are Neovim-aware: when Neovim is focused, the key passes through so a navigator plugin can handle it; otherwise tmux selects the pane directly. To enable this in Neovim, install [Navigator.nvim](https://github.com/numToStr/Navigator.nvim).

With [lazy.nvim](https://lazy.folke.io), save this as <code>~/.config/nvim/lua/plugins/navigator.lua</code>:

```lua
return {
  "numToStr/Navigator.nvim",
  opts = {},
  keys = {
    {
      "<c-h>",
      "<CMD>NavigatorLeft<CR>",
      mode = { "n", "t" },
      desc = "Move to the left",
    },
    {
      "<c-j>",
      "<CMD>NavigatorDown<CR>",
      mode = { "n", "t" },
      desc = "Move to the down",
    },
    {
      "<c-k>",
      "<CMD>NavigatorUp<CR>",
      mode = { "n", "t" },
      desc = "Move to the up",
    },
    {
      "<c-l>",
      "<CMD>NavigatorRight<CR>",
      mode = { "n", "t" },
      desc = "Move to the right",
    },
  },
}
```

This gives you seamless <code>Ctrl+H/J/K/L</code> movement across Neovim splits <em>and</em> tmux panes with zero friction.

</details>

## 🎨 Customization

Edit `config/tmux.conf` in the repo directly. No symlinks, no overlays, no backup/restore. Terminal emulator settings are in `terminals/` as reference snippets — copy what you need into your own config. The default theme is **Tokyo Night Moon** with matching true-color hex codes across WezTerm/Ghostty, tmux, and Neovim.
