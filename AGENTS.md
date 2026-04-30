# Agent Cheat Sheet

**tau** (τ) is a terminal development environment for working with multiple [pi](https://github.com/badlogic/pi-mono) coding agent instances. It layers WezTerm → tmux into a coherent workflow where tmux is the persistent orchestration layer and pi runs directly in tmux panes.

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
│  │  │ ┌────┐┌────┐ │  │ ┌───────┐ │  │         │ │ │
│  │  │ │nvim││ pi │ │  │ │ pi    │ │  │         │ │ │
│  │  │ └────┘└────┘ │  │ │ TUI   │ │  │         │ │ │
│  │  └──────────────┘  │ └───────┘ │  └─────────┘ │ │
│  └───────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────┘
```

- **WezTerm** — renders everything, handles kitty keyboard protocol for reliable modifier keys
- **tmux** — persistent sessions, one per project; status bar; sessionizer
- **pi** — runs as a standalone TUI in a tmux pane

## Project Structure

```
tau/
├── config/
│   ├── wezterm.lua        # WezTerm config → symlink to ~/.config/wezterm/wezterm.lua
│   └── tmux.conf          # tmux config    → symlink to ~/.config/tmux/tmux.conf
├── scripts/
│   ├── tau-sessionizer    # fzf popup to pick ~/Developer repos → symlink to ~/.local/bin/tau-sessionizer
│   ├── tau-status-sessions  # status bar session list → symlink to ~/.local/bin/tau-status-sessions
│   ├── tau-cycle-session  # cycle project sessions → symlink to ~/.local/bin/tau-cycle-session
│   ├── tau-swap-session   # reorder project sessions → symlink to ~/.local/bin/tau-swap-session
│   ├── tau-spawn-pi       # spawn pi pane in grid layout → symlink to ~/.local/bin/tau-spawn-pi
│   └── tau-select-session # select session by position → symlink to ~/.local/bin/tau-select-session
├── .editorconfig          # Lua formatting rules
└── AGENTS.md              # this file
```

All config files are standalone — the user symlinks or copies them to the correct location.

## Config Files

### wezterm.lua — WezTerm Configuration

Key settings:
- **`config.term = "wezterm"`** — sets `$TERM` environment variable
- **Kitty keyboard protocol** (`enable_kitty_keyboard = true`) — required for pi to detect modifier keys (Shift+Enter, Ctrl+Enter, Alt+Enter)
- **Tokyo Night Moon** color scheme, **Maple Mono NF** font at 13pt
- **No tab bar** — tmux handles window/tab management
- **Zero window padding** — tmux fills the entire terminal with no gaps
- **macOS window decorations** — `RESIZE | MACOS_FORCE_DISABLE_SHADOW`

Key bindings:
- **Cmd+H / Cmd+L** → `\x1b[1;9P` / `\x1b[1;9Q` (tmux User0/User1) — cycle windows
- **Cmd+1-9** → `\x1b[23;9~` through `\x1b[33;9~` (tmux User10-18) — select window by number
- **Cmd+Shift+H / Cmd+Shift+L** → `\x1b[1;9R` / `\x1b[1;9S` (tmux User2/User3) — cycle project sessions
- **Cmd+Alt+Shift+1-9** → `\x1b[34;9~` through `\x1b[42;9~` (tmux User19-27) — select project session by position in @sort-index order
- **Cmd+T** → `\x1b[15;9~` (tmux User4) — new window
- **Cmd+A** → `\x1b[17;9~` (tmux User5) — spawn pi pane in grid layout
- **Cmd+G** → `\x1b[43;9~` (tmux User28) — open lazygit in floating popup
- **Cmd+E** → `\x1b[44;9~` (tmux User29) — open editor in floating popup
- **Super+Left / Super+Right** → `\x1b[18;9~` / `\x1b[19;9~` (tmux User6/User7) — reorder windows
- **Super+Shift+Left / Super+Shift+Right** → `\x1b[20;9~` / `\x1b[21;9~` (tmux User8/User9) — reorder sessions
- **Alt+Enter** CSI-u passthrough — sends `\x1b[13;3u` so tmux forwards the key correctly to pi
- **Ctrl+=/-/Shift variants** disabled (`action.Nop`) to prevent terminal zoom, letting tmux handle those

Note: Cmd+1-9 and Cmd+Alt+Shift+1-9 use escape sequences \x1b[23;9~ through \x1b[42;9~ mapped to tmux User10-27, since User0-9 are already assigned. Cmd+Alt+Shift is used because Cmd+Shift+number is intercepted by macOS.

Target: `~/.config/wezterm/wezterm.lua`

### tmux.conf — tmux Configuration

Optimized for Neovim + pi coexistence:

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

**Tokyo Night Moon colorscheme** — applied to mode, messages, pane borders, and status bar using true-color hex codes matching WezTerm and Neovim.

**Status bar:**
- Left: current session name
- Center: window list with current window highlighted on a blue badge
- Right: clickable list of project sessions via `tau-status-sessions` (current session gets a blue badge)
- Active elements use dark text (#1b1d2b) on blue background (#82aaff) with powerline transitions

**Prefix-less key bindings:**
- **Cmd+H / Cmd+L** (User0/User1) — cycle windows
- **Cmd+1-9** (User10-18) — select window by number
- **Cmd+Shift+H / Cmd+Shift+L** (User2/User3) — cycle project sessions via `tau-cycle-session`
- **Cmd+Alt+Shift+1-9** (User19-27) — select project session by position via `tau-select-session`
- **Cmd+T** (User4) — new window in current directory
- **Cmd+A** (User5) — spawn pi pane in grid layout via `tau-spawn-pi`
- **Cmd+G** (User28) — open lazygit in a floating popup (90%×90%) in the current pane's working directory
- **Cmd+E** (User29) — open editor in a floating popup (90%×90%) in the current pane's working directory
- **Super+Left / Super+Right** (User6/User7) — reorder windows with `swap-window`
- **Super+Shift+Left / Super+Shift+Right** (User8/User9) — reorder project sessions via `tau-swap-session`

**Other key bindings:**
- **Ctrl+h/j/k/l** — seamless Neovim ↔ tmux pane navigation (Navigator.nvim style). When Neovim is focused, the key passes through so Navigator handles it; otherwise tmux selects the pane directly
- **prefix | / prefix -** — intuitive splits (horizontal/vertical), new pane inherits cwd
- **prefix r** — reload config
- **prefix f** — sessionizer popup (fzf to pick ~/Developer repos)

**Hooks:**
- `client-session-changed` — forces immediate status bar refresh via `refresh-client -S` when switching sessions

Target: `~/.config/tmux/tmux.conf`

## Key Dependencies

| Component | Minimum Version |
|-----------|----------------|
| WezTerm | latest stable |
| tmux | 3.6+ |
| pi | latest |

## Setup

```bash
# 1. Install dependencies
npm install -g @mariozechner/pi-coding-agent

# 2. Symlink configs
ln -s ~/Developer/tau/config/wezterm.lua ~/.config/wezterm/wezterm.lua
ln -s ~/Developer/tau/config/tmux.conf ~/.config/tmux/tmux.conf

# 3. Symlink scripts
ln -s ~/Developer/tau/scripts/tau-sessionizer ~/.local/bin/tau-sessionizer
ln -s ~/Developer/tau/scripts/tau-status-sessions ~/.local/bin/tau-status-sessions
ln -s ~/Developer/tau/scripts/tau-cycle-session ~/.local/bin/tau-cycle-session
ln -s ~/Developer/tau/scripts/tau-swap-session ~/.local/bin/tau-swap-session
ln -s ~/Developer/tau/scripts/tau-spawn-pi ~/.local/bin/tau-spawn-pi
ln -s ~/Developer/tau/scripts/tau-select-session ~/.local/bin/tau-select-session

# 4. Restart everything (tmux must be fully restarted for extkeys)
tmux kill-server
```

## How the Key Chain Works

Modified keys must pass through two layers to reach pi. Each layer must be configured:

```
WezTerm → (kitty keyboard protocol) → tmux → (CSI-u extkeys) → pi
```

- **WezTerm**: `enable_kitty_keyboard = true` encodes Shift+Enter as `\x1b[13;2u`
- **tmux**: `extended-keys always` + `extended-keys-format csi-u` forwards the sequence unchanged

For prefix-less WezTerm→tmux key bindings, the chain is simpler:

```
WezTerm → (custom escape sequence) → tmux → (user-key binding) → action
```

Each WezTerm key binding sends a unique escape sequence that tmux maps to a user-key, which is then bound to an action (window cycling, session cycling, pane spawning, etc.).

## Editing Conventions

- All Lua files use **2-space indentation**, double quotes, 120 char max line length (see `.editorconfig`)
- tmux.conf uses **comment blocks** explaining each setting — maintain that style when adding config
- When adding tmux keybindings, prefer `prefix + single key` over chords

## Session Tagging

Sessions carry tmux user options for identity, grouping, and ordering:

```
tmux set-option -t <session> @type "<type>"          # project | agent | scratch | ...
tmux set-option -t <session> @project "<name>"       # display name, groups sessions for same project
tmux set-option -t <session> @sort-index "<number>"  # sort order in status bar and session cycling
```

- **`@type`** — what kind of session this is. Currently used values:
  - `project` — set by `tau-sessionizer` when creating a project session
  - `agent` — for AI agent sessions
  - `scratch` — for ad-hoc sessions
- **`@project`** — display name for the project. Groups sessions belonging to the same project (e.g. a `project` session and its `agent` sessions share the same `@project` value)
- **`@sort-index`** — numeric sort order used by the status bar (`tau-status-sessions`), session cycling (`tau-cycle-session`), and session reordering (`tau-swap-session`). Falls back to creation order when unset. Swapped by `tau-swap-session` when reordering sessions via Super+Shift+Left/Right.
- The status bar (`tau-status-sessions`) only shows `@type=project` sessions, sorted by `@sort-index`
- `Cmd+Shift+H/L` (`tau-cycle-session`) only cycles through `@type=project` sessions in sort order
- **Important**: use session-scoped options (`set-option -t <session>`) not server-scoped (`set-option -s`) — server scope is global across all sessions

## Scripts

### tau-sessionizer

fzf popup to pick a repo in `~/Developer`. Creates a new tmux session if one doesn't exist, switches to it otherwise. Sets `@type=project` and `@project=<display-name>` on new sessions.

### tau-status-sessions

Generates the status-right content: a clickable list of project sessions. Only shows sessions with `@type=project`, displays `@project` as the label, sorted by `@sort-index` (creation-order fallback). Current session gets a blue highlight badge.

### tau-cycle-session

Cycles through project sessions only (next/prev direction). Only considers sessions with `@type=project`, sorted by `@sort-index`. If the current session is not a project session, jumps to the first one.

### tau-swap-session

Swaps the current project session's `@sort-index` with the previous/next project session. Clamps at boundaries (first/last). Only affects sessions with `@type=project`. Used by Super+Shift+Left/Right to reorder sessions in the status bar.

### tau-select-session

Selects a project session by its 1-based position in the sorted list. Only considers sessions with `@type=project`, sorted by `@sort-index` (creation-order fallback). Silently exits if the index exceeds the number of project sessions. Used by Cmd+Alt+Shift+1-9 to jump directly to a specific project session.

### tau-spawn-pi

Spawns a new pane running `pi` and rearranges all panes into a grid:

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
- Leaf cells: `WxH,X,Y,PID`
- A 4-hex-digit checksum prefixes the string

Panes are assigned in creation order (oldest → top-left, newest → bottom-right).

## Things to Watch

- **tmux must be fully restarted** (`tmux kill-server`) after changing `extended-keys` settings — reload (`prefix r`) is not enough
- **WezTerm's Ctrl+=/- bindings** are intentionally disabled (`action.Nop`) to prevent the terminal from intercepting zoom shortcuts that tmux or Neovim may use

