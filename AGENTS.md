# Agent Cheat Sheet

**tau** (τ) is a self-contained terminal workspace for [pi](https://github.com/earendil-works/pi) coding agents. It runs an isolated tmux server with its own config — no user config files are touched, ever.

The name is a wordplay on pi (π → τ): tau is 2π, because one pi agent is never enough.

## Architecture

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

- **`bin/tau`** — single entry point; attaches to existing server or starts a new one
- **tmux isolation** — `tmux -L tau -f <tau-config>` creates a dedicated server on socket `tau`, independent from any user tmux sessions
- **WezTerm or Ghostty** — renders everything, handles kitty keyboard protocol for reliable modifier keys
- **pi** — runs as a standalone TUI in a tmux pane
- **`$TAU_ROOT`** — env var exported by `bin/tau`, inherited by tmux and all child processes; used for path resolution in scripts and config
- **`$TAU_PROJECT_DIR`** — required env var; directory containing your projects. tau refuses to start if unset or missing
- **`$TAU_EDITOR_CMD`** — optional env var; command launched by Cmd+E popup. Shows tmux notification if unset
- **`$TAU_GIT_CMD`** — optional env var; command launched by Cmd+G popup. Shows tmux notification if unset
- **`$TAU_AGENT_CMD`** — optional env var; command spawned by Cmd+A in grid layout (defaults to `pi`)

## Project Structure

```
tau/
├── bin/                    # Executables
│   └── tau                 # The command: launch/attach isolated tmux server
├── lib/                    # Shared shell functions (sourced, not executed)
│   └── common.sh           # Session listing, sorting, tmux helpers
├── config/                 # tau's own tmux config (loaded via -f)
│   └── tmux.conf           # Full tmux config for tau's isolated server
├── scripts/                # Internal scripts (invoked by tmux keybindings)
│   ├── tau-sessionizer     # fzf project picker
│   ├── tau-status-sessions # Status bar session list
│   ├── tau-cycle-session   # Cycle sessions (Cmd+Shift+H/L)
│   ├── tau-swap-session    # Reorder sessions (Super+Shift+Left/Right)
│   ├── tau-spawn-pi        # Spawn pi pane in grid layout
│   ├── tau-popup-git       # Cmd+G popup (checks TAU_GIT_CMD)
│   └── tau-popup-editor    # Cmd+E popup (checks TAU_EDITOR_CMD)
├── terminals/              # Reference configs for terminal emulators
│   ├── README.md           # "Copy these settings into your terminal config"
│   ├── wezterm.lua         # Required WezTerm settings for tau
│   └── ghostty             # Required Ghostty settings for tau
├── .editorconfig
├── .shellcheckrc
├── Makefile                # install, uninstall, lint, check targets
├── AGENTS.md               # this file
├── CHANGELOG.md
├── README.md
```

### Directory purposes

| Directory | What goes here | Who runs it |
|-----------|---------------|-------------|
| `bin/` | The `tau` command | User (or PATH) |
| `lib/` | Shared functions sourced by scripts | Internal |
| `config/` | tau's tmux config | tmux (via `-f`) |
| `scripts/` | tmux keybinding targets | tmux (`run-shell`) |
| `terminals/` | Reference snippets, never executed | User (reads & copies) |

## Installation

Two options — no config files touched, no backups needed:

```bash
# Option A: Single symlink
ln -s ~/Developer/tau/bin/tau ~/.local/bin/tau

# Option B: Add to PATH
echo 'export PATH="$HOME/Developer/tau/bin:$PATH"' >> ~/.bashrc
```

Or use `make install` / `make uninstall`.

## The `tau` Command

`bin/tau` is a single script that:

1. Exports `TAU_ROOT` (resolved from its own location)
2. Validates `TAU_PROJECT_DIR` is set and the directory exists (exits with error if not)
3. Exports `TAU_EDITOR_CMD`, `TAU_GIT_CMD`, and `TAU_AGENT_CMD` (optional, defaults to empty/pi)
4. Checks if a tau tmux server exists (`tmux -L tau has-session`)
5. If yes → `exec tmux -L tau attach`
6. If no → `exec tmux -L tau -f "$TAU_ROOT/config/tmux.conf" new-session -s scratch` with `-e` flags to pass env vars into the server

Guards: exits if already inside tmux (no nested sessions), exits if `TAU_PROJECT_DIR` is unset or missing.

## Path Resolution

`bin/tau` resolves and exports `TAU_ROOT`, then `exec`s tmux. tmux inherits the env var and passes it to all `run-shell` scripts and `#(...)` status bar commands.

```bash
# bin/tau
export TAU_ROOT
TAU_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Validate TAU_PROJECT_DIR (required)
if [ -z "${TAU_PROJECT_DIR:-}" ]; then
    echo "tau: TAU_PROJECT_DIR is not set." >&2; exit 1
fi
TAU_PROJECT_DIR="$(cd "$TAU_PROJECT_DIR" 2>/dev/null && pwd)" || {
    echo "tau: TAU_PROJECT_DIR does not exist." >&2; exit 1
}
export TAU_PROJECT_DIR TAU_EDITOR_CMD TAU_GIT_CMD TAU_AGENT_CMD

exec tmux -L tau -f "$TAU_ROOT/config/tmux.conf" new-session -s scratch \
    -e TAU_ROOT -e TAU_PROJECT_DIR -e TAU_EDITOR_CMD -e TAU_GIT_CMD -e TAU_AGENT_CMD
```

```tmux
# config/tmux.conf — uses $TAU_ROOT directly
bind-key -n User5 run-shell "$TAU_ROOT/scripts/tau-spawn-pi"
set -g status-right "#($TAU_ROOT/scripts/tau-status-sessions '#{session_name}')"
bind r source-file "$TAU_ROOT/config/tmux.conf" \; display-message "Tau config reloaded!"
```

```bash
# scripts — $TAU_ROOT is already in the environment
source "$TAU_ROOT/lib/common.sh"
```

## Config Files

### config/tmux.conf — tmux Configuration

Loaded via `tmux -L tau -f $TAU_ROOT/config/tmux.conf`. Not symlinked to a system path — users edit it in the repo (fork-and-modify workflow).

**Core settings:**
- **Mouse on**, **base-index 1**, **renumber-windows** — ergonomic defaults
- **Vi copy mode** — consistent hjkl muscle memory with Neovim
- **escape-time 10ms** — eliminates lag when pressing Esc in Neovim normal mode
- **Focus events** — Neovim can detect when you switch back to a pane
- **Cursor shape passthrough** — block/line/beam cursor follows Neovim mode
- **CSI-u extended keys** (`extended-keys always`, `extended-keys-format csi-u`) — critical for pi's Shift+Enter and Ctrl+Enter keybindings to work through tmux
- **Terminal features** for xterm* and wezterm* advertise extkey support
- **`default-terminal "tmux-256color"`** — accurate color rendering inside tmux
- **`allow-passthrough on`** — lets programs send escape sequences directly to the outer terminal

**Tokyo Night Moon colorscheme** — applied to mode, messages, pane borders, and status bar using true-color hex codes matching WezTerm/Ghostty and Neovim.

**Status bar:**
- Left: tmux window list — shows window number and name (`#I #W`), current window highlighted on a blue badge
- Right: clickable list of all tau sessions via `tau-status-sessions` — shows position number and session name, sorted by `@sort-index`. Current session gets a blue badge. Click to switch.
- Active elements use dark text (#1b1d2b) on blue background (#82aaff) with powerline transitions

**Prefix-less key bindings:**
- **Cmd+H / Cmd+L** (User0/User1) — cycle windows
- **Cmd+1-9** (User10-18) — select window by number
- **Cmd+Shift+H / Cmd+Shift+L** (User2/User3) — cycle sessions via `tau-cycle-session`
- **Cmd+T** (User4) — new window in current directory
- **Cmd+A** (User5) — spawn pi pane in grid layout via `tau-spawn-pi`
- **Cmd+G** (User28) — open `$TAU_GIT_CMD` in a floating popup (90%×90%) via `tau-popup-git`. Shows tmux notification if `TAU_GIT_CMD` is unset
- **Cmd+E** (User29) — open `$TAU_EDITOR_CMD` in a floating popup (90%×90%) via `tau-popup-editor`. Shows tmux notification if `TAU_EDITOR_CMD` is unset
- **Cmd+S** (User30) — open a floating scratch shell (90%×90%) via `tau-popup-scratch`
- **Super+Left / Super+Right** (User6/User7) — reorder windows with `swap-window`
- **Super+Shift+Left / Super+Shift+Right** (User8/User9) — reorder sessions via `tau-swap-session`

**Other key bindings:**
- **Ctrl+h/j/k/l** — seamless Neovim ↔ tmux pane navigation (Navigator.nvim style). When Neovim is focused, the key passes through so Navigator handles it; otherwise tmux selects the pane directly
- **prefix | / prefix -** — intuitive splits (horizontal/vertical), new pane inherits cwd
- **prefix r** — reload config from `$TAU_ROOT/config/tmux.conf`
- **prefix f** — sessionizer popup (fzf to pick repos from `$TAU_PROJECT_DIR`)

**Hooks:**
- `client-session-changed` — forces immediate status bar refresh via `refresh-client -S` when switching sessions

### terminals/ — Terminal Reference Configs

tau does NOT touch the user's terminal emulator config. `terminals/` contains reference snippets users manually copy into their own config. See `terminals/README.md` for required settings.

## Key Dependencies

| Component | Minimum Version |
|-----------|----------------|
| WezTerm or Ghostty | latest stable |
| tmux | 3.6+ |
| pi | latest |

## How the Key Chain Works

Modified keys must pass through two layers to reach pi. Each layer must be configured:

```
Terminal (WezTerm/Ghostty) → (kitty keyboard protocol) → tmux → (CSI-u extkeys) → pi
```

- **WezTerm**: `enable_kitty_keyboard = true` encodes Shift+Enter as `\x1b[13;2u`
- **Ghostty**: kitty keyboard protocol enabled by default
- **tmux**: `extended-keys always` + `extended-keys-format csi-u` forwards the sequence unchanged

For prefix-less terminal→tmux key bindings, the chain is simpler:

```
Terminal (WezTerm/Ghostty) → (custom escape sequence) → tmux → (user-key binding) → action
```

Each terminal key binding sends a unique escape sequence that tmux maps to a user-key, which is then bound to an action (window cycling, session cycling, pane spawning, etc.).

## Editing Conventions

- All Lua files use **2-space indentation**, double quotes, 120 char max line length (see `.editorconfig`)
- Shell scripts use **2-space indentation** (see `.editorconfig`)
- tmux.conf uses one-line comments per setting with `# === Section ===` headers — maintain that style
- When adding tmux keybindings, prefer `prefix + single key` over chords
- All shell scripts source `lib/common.sh` and use `TAU_SOCKET` constant for tmux calls

## Session Model

### Simplified — flat list with one metadata field

Since `-L tau` isolation means every session on the server IS a tau session, no filtering is needed. Sessions have a single metadata field:

| Option | Purpose | Set by | Used by |
|--------|---------|--------|----------|
| `@sort-index` | Sort order | `tau-swap-session` (initially unset → creation order) | `tau-status-sessions`, `tau-cycle-session`, `tau-swap-session` |

**Important**: use session-scoped options (`set-option -t <session>`) not server-scoped (`set-option -s`) — server scope is global across all sessions.

### Session lifecycle

```
tau-sessionizer (prefix+f)
  │
  ├── fzf picks directory in $TAU_PROJECT_DIR
  │
  ├── session doesn't exist?
  │   └── tmux -L tau new-session -d -s <name> -c $TAU_PROJECT_DIR/<dir>
  │       (no metadata — @sort-index unset, falls back to creation order)
  │
  └── tmux -L tau switch-client -t <name>
```

### Session ordering

- **Default**: creation order (no `@sort-index` set → fallback to list-sessions order)
- **User reorder**: `Super+Shift+Left/Right` → `tau-swap-session` swaps `@sort-index` of adjacent sessions and renumbers all sequentially
- **Status bar**: `tau-status-sessions` lists all sessions sorted by `@sort-index`
- **Cycling**: `Cmd+Shift+H/L` → `tau-cycle-session` goes prev/next in sort order

## Shared Library (lib/common.sh)

Sourced by all scripts in `scripts/`. Provides:

```bash
TAU_SOCKET="tau"                  # Socket name for all tmux -L calls

tau_list_sessions()               # Lists all sessions sorted by @sort-index
                                   # Output: <sort-index>|<session-name>
                                   # Falls back to creation order when unset

tau_current_session()             # Returns current session name
```

## Scripts

All scripts live in `scripts/` and are invoked by tmux keybindings via `run-shell "$TAU_ROOT/scripts/..."`. All follow the same pattern:

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$TAU_ROOT/lib/common.sh"
```

### tau-sessionizer

fzf popup to pick a repo in `$TAU_PROJECT_DIR`. Creates a new tmux session on the tau server if one doesn't exist, switches to it otherwise. No metadata set on creation — `@sort-index` stays unset (creation order) until the user reorders.

### tau-status-sessions

Generates the status-right content: a clickable list of all tau sessions. Displays session name as the label, sorted by `@sort-index` (creation-order fallback). Current session gets a blue highlight badge.

### tau-cycle-session

Cycles through all tau sessions (next/prev direction) in `@sort-index` order. If the current session is not found in the sorted list, jumps to the first one.

### tau-swap-session

Swaps the current session's `@sort-index` with the previous/next session. Clamps at boundaries (first/last). Renumber all sessions sequentially after swap to prevent index collisions. Used by `Super+Shift+Left/Right`.

### tau-spawn-pi

Spawns a new pane running `pi` and rearranges all panes into a grid (pure bash — no Python dependency):

1. If the current pane is an idle shell, launches `pi` directly in it (no new pane)
2. Calculate `max_cols = window_width / 80` (minimum 80 columns per pane)
3. Panes fill left-to-right in a row with equal width
4. When the row is full, the next pane starts a new row below
5. The grid is applied as a custom tmux layout string via `select-layout`

Example for a 240-column window (`max_cols = 3`):
- 1 pane: `[    full width    ]`
- 2 panes: `[  pane 1 | pane 2 ]`
- 3 panes: `[ p1 | p2 | p3 ]`
- 4 panes: `[ p1 | p2 | p3 ]` + `[ p4 | ...     ]` below
- 6 panes: `[ p1 | p2 | p3 ]` + `[ p4 | p5 | p6 ]`

The layout string format uses tmux's internal representation:
- `{...}` = horizontal group (side-by-side panes)
- `[...]` = vertical group (stacked rows)
- Leaf cells: `WxH,X,Y,0`
- A 4-hex-digit checksum prefixes the string

The checksum algorithm (from tmux source `layout-custom.c`):
```
For each character in the layout tree string:
  csum = rotate-right-1-bit(csum) + byte_value(char)
Result is the lower 16 bits, formatted as 4 hex digits.
```

Panes are assigned in creation order (oldest → top-left, newest → bottom-right).

### tau-popup-git

Wrapper for Cmd+G. Checks `TAU_GIT_CMD` — if unset, shows a tmux notification and exits. Otherwise launches the command in a 90%×90% floating popup in the current pane's working directory.

### tau-popup-editor

Wrapper for Cmd+E. Same pattern as `tau-popup-git` but checks `TAU_EDITOR_CMD`.

### tau-popup-scratch

Floating shell popup (Cmd+S). Opens a 90%×90% popup running `$SHELL` in the current pane's working directory. Same pattern as `tau-popup-git` and `tau-popup-editor` but always available (no env var needed).

## Things to Watch

- **tmux must be fully restarted** (`tmux -L tau kill-server`) after changing `extended-keys` settings — reload (`prefix r`) is not enough
- **Terminal Ctrl+=/- bindings** are intentionally disabled (WezTerm: `action.Nop`) to prevent the terminal from intercepting zoom shortcuts that tmux or Neovim may use
- **`$TAU_ROOT` must be set** — all scripts depend on it. Always start tau via `bin/tau`, not by manually running `tmux -L tau`
