#!/usr/bin/env bash
# lib/common.sh — shared functions for tau scripts

TAU_SOCKET="${TAU_SOCKET:-tau}"
TAU_POPUP_SOCKET="${TAU_POPUP_SOCKET:-tau-popup}"

tau_list_sessions() {
    local idx=0
    tmux -L "$TAU_SOCKET" list-sessions -F '#{session_name}|#{@sort-index}|#{@hidden}' 2>/dev/null |
        while IFS='|' read -r name sort_idx hidden; do
            [ "$hidden" = "on" ] && continue
            idx=$((idx + 1))
            echo "${sort_idx:-$idx}|$name"
        done | sort -t'|' -k1 -n -s
}

tau_current_session() {
    tmux -L "$TAU_SOCKET" display-message -p '#{session_name}'
}

# Generate popup session name: _popup_<type>_<session>
# Replaces . and : with _ (tmux session name restrictions)
tau_popup_session_name() {
    local type="$1" session="$2"
    local safe="${session//[:.]/_}"
    printf '_popup_%s_%s' "$type" "$safe"
}

# Ensure popup server is running with toggle key bindings.
# Idempotent — checks for @tau-initialized marker.
# User-keys are registered via source-file because shell escaping
# mangles escape sequences in multi-command chains.
tau_ensure_popup_server() {
    if tmux -L "$TAU_POPUP_SOCKET" show-option -g @tau-initialized 2>/dev/null | grep -q on; then
        return 0
    fi

    tmux -L "$TAU_POPUP_SOCKET" new-session -d -s __tau_init -x 1 -y 1 2>/dev/null || true

    local conf
    conf="$(mktemp)"
    cat > "$conf" << 'TMUXCONF'
set-option -g exit-empty off
set-option -g status off
set-option -g extended-keys on
set-option -g extended-keys-format csi-u
set-option -s user-keys[28] "\033[43;9~"
set-option -s user-keys[29] "\033[44;9~"
set-option -s user-keys[30] "\033[45;9~"
TMUXCONF

    tmux -L "$TAU_POPUP_SOCKET" \
        source-file "$conf" \; \
        set-environment -g TAU_ROOT "$TAU_ROOT" \; \
        set-environment -g TAU_SOCKET "$TAU_SOCKET" \; \
        set-environment -g TAU_POPUP_SOCKET "$TAU_POPUP_SOCKET" \; \
        set-environment -g TAU_GIT_CMD "${TAU_GIT_CMD:-}" \; \
        set-environment -g TAU_EDITOR_CMD "${TAU_EDITOR_CMD:-}" \; \
        set-environment -g TAU_PROJECT_DIR "${TAU_PROJECT_DIR:-}" \; \
        set-environment -g SHELL "${SHELL:-/bin/bash}" \; \
        bind-key -n User28 run-shell -b "$TAU_ROOT/scripts/tau-popup-git" \; \
        bind-key -n User29 run-shell -b "$TAU_ROOT/scripts/tau-popup-editor" \; \
        bind-key -n User30 run-shell -b "$TAU_ROOT/scripts/tau-popup-scratch" \; \
        set-option -g @tau-initialized on

    rm -f "$conf"
    tmux -L "$TAU_POPUP_SOCKET" kill-session -t __tau_init 2>/dev/null || true
}
