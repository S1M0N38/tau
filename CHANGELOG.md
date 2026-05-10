# Changelog

## 1.0.0 (2026-05-10)


### Features

* add isolated entry point, shared lib, and terminal reference ([163efcb](https://github.com/S1M0N38/tau/commit/163efcb005c0e50c873c2a643da55c95789b72fc))
* add TAU_PROJECT_DIR, TAU_EDITOR_CMD, TAU_GIT_CMD env vars ([ef35098](https://github.com/S1M0N38/tau/commit/ef35098d291f170abdbae388cbbe5930dfc6a96c))
* **scripts:** add tau-cycle-session for project session cycling ([0c38e93](https://github.com/S1M0N38/tau/commit/0c38e931f8ff0a0a10b33c1c1b7ef947685f4262))
* **scripts:** add tau-select-session for positional session selection ([df986fd](https://github.com/S1M0N38/tau/commit/df986fd9c90f7383aa77ea5a60e92a65967feed7))
* **scripts:** add tau-spawn-pi for grid pane layout ([5195490](https://github.com/S1M0N38/tau/commit/51954909f46ce3ef9ca5b7b20f424e11556608a3))
* **scripts:** add tau-swap-session for reordering project sessions ([a625022](https://github.com/S1M0N38/tau/commit/a625022e6aceea3af8c31834b7df1d9f9378dc3d))
* **scripts:** replace status-sessions with [@type-aware](https://github.com/type-aware) tau-status-sessions ([b90b112](https://github.com/S1M0N38/tau/commit/b90b112d429914a13995b3ab130ddf45280c6d58))
* **sessionizer:** tag sessions with [@type](https://github.com/type) and [@project](https://github.com/project) options ([68d8d2b](https://github.com/S1M0N38/tau/commit/68d8d2b99cf4fff35b80a9c7dcb5a1b4f1e13825))
* **sidekick:** add Ctrl+P CSI-u passthrough keybinding ([6241980](https://github.com/S1M0N38/tau/commit/624198099185f0aaeb3c29492c87a64ca621b60c))
* **sidekick:** add sidekick.nvim plugin spec with tmux mux backend ([0d2edb5](https://github.com/S1M0N38/tau/commit/0d2edb56d24f4be665dd0cc763ca73dcfd727e64))
* **terminals:** add kitty and ghostty config files ([91b568f](https://github.com/S1M0N38/tau/commit/91b568f64a6eeae32037d7f0347e232c7b022c26))
* **tmux:** add clickable session switcher to status bar ([8557edf](https://github.com/S1M0N38/tau/commit/8557edfbced9a4d4a252263e5f9bc19e85880a5e))
* **tmux:** add prefix-less bindings, Tokyo Night colors, and session management ([1f7591e](https://github.com/S1M0N38/tau/commit/1f7591e09bdb83c5f91491343bdb4db7b0d9100a))
* **tmux:** add tmux config with CSI-u extkeys and Tokyo Night theme ([70bcb41](https://github.com/S1M0N38/tau/commit/70bcb41a0a299c9f4b8f97e3cd208127bf11ceac))
* **tmux:** add window selection, session selection, and floating popup bindings ([d6b8721](https://github.com/S1M0N38/tau/commit/d6b8721c73d12c423f8c668c09306a587a983c4c))
* **wezterm:** add Cmd+1-9, Cmd+G, and Cmd+E keybindings ([26ecb04](https://github.com/S1M0N38/tau/commit/26ecb04b6bdb92b4e879c8891c15ff7633ada73d))
* **wezterm:** add prefix-less key bindings for window and session control ([19a3ddc](https://github.com/S1M0N38/tau/commit/19a3ddcc357fb8859236f8eb11415668eac36538))
* **wezterm:** add WezTerm config with kitty keyboard protocol ([b75bd3a](https://github.com/S1M0N38/tau/commit/b75bd3a82df3cfd569a4c3562b45922a383fb22f))


### Bug Fixes

* **bin:** resolve TAU_ROOT when launched via symlink ([42771b3](https://github.com/S1M0N38/tau/commit/42771b3f0be8561bdfc8634cabe60a118d951298))
* **ci:** add bootstrap-sha so release-please detects initial commits ([da3ace1](https://github.com/S1M0N38/tau/commit/da3ace1a870d9124569c00056072db358033f826))
* **ci:** add required packages key to release-please config ([97e09d1](https://github.com/S1M0N38/tau/commit/97e09d1fe99230001bd9fa0c2c8db80f596397cd))
* **ci:** set manifest to 0.0.0 to trigger initial v0.1.0 release ([f0b322f](https://github.com/S1M0N38/tau/commit/f0b322f31fc9fc42a17ca72ae4df1a30473ca5a3))
* **ci:** setup tmux 3.6a, pi stub, and Linux script compat ([c29908a](https://github.com/S1M0N38/tau/commit/c29908a9be1d13bbcb3d7bcbc7d5146eeb97ebbf))
* **common:** allow TAU_SOCKET override via environment ([a830e4d](https://github.com/S1M0N38/tau/commit/a830e4db18948d6cc55edc90166f7ac60945db85))
* **terminals:** correct Ghostty theme name to TokyoNight Moon ([5604fb5](https://github.com/S1M0N38/tau/commit/5604fb5d33af91b7c7fd1fb022d584aa0c0da62a))
