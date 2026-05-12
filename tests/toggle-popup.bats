#!/usr/bin/env bash
# tests/toggle-popup.bats — popup toggle system
load 'helpers/setup'

setup() { tau_test_kill_server; }
teardown() { tau_test_kill_server; }

# ── tau_popup_session_name ──────────────────────────────────────────

@test "popup session name: simple session" {
    run tau_popup_session_name git myapp
    [ "$output" = "_popup_git_myapp" ]
}

@test "popup session name: dots and colons replaced" {
    run tau_popup_session_name git "my.project"
    [ "$output" = "_popup_git_my_project" ]
    run tau_popup_session_name git "my:project"
    [ "$output" = "_popup_git_my_project" ]
}

@test "popup session name: types are distinct" {
    run tau_popup_session_name git myapp; [ "$output" = "_popup_git_myapp" ]
    run tau_popup_session_name editor myapp; [ "$output" = "_popup_editor_myapp" ]
    run tau_popup_session_name scratch myapp; [ "$output" = "_popup_scratch_myapp" ]
}

@test "popup session name: sessions are distinct" {
    run tau_popup_session_name git alpha; [ "$output" = "_popup_git_alpha" ]
    run tau_popup_session_name git beta; [ "$output" = "_popup_git_beta" ]
}

# ── tau_ensure_popup_server ────────────────────────────────────────

@test "popup server starts" {
    tau_test_new_session "s"
    tau_ensure_popup_server
    tmux -L "$TAU_POPUP_SOCKET" list-sessions 2>/dev/null
}

@test "popup server: exit-empty off, status off" {
    tau_test_new_session "s"; tau_ensure_popup_server
    tmux -L "$TAU_POPUP_SOCKET" show-option -g exit-empty | grep -q "off"
    tmux -L "$TAU_POPUP_SOCKET" show-option -g status | grep -q "off"
}

@test "popup server: @tau-initialized marker" {
    tau_test_new_session "s"; tau_ensure_popup_server
    tmux -L "$TAU_POPUP_SOCKET" show-option -g @tau-initialized | grep -q "on"
}

@test "popup server: TAU_ROOT in environment" {
    tau_test_new_session "s"; tau_ensure_popup_server
    tmux -L "$TAU_POPUP_SOCKET" show-environment -g TAU_ROOT | grep -q "$TAU_ROOT"
}

@test "popup server: user-keys properly registered" {
    tau_test_new_session "s"; tau_ensure_popup_server
    tmux -L "$TAU_POPUP_SOCKET" show-options -s user-keys[28] | grep -q '\\033'
    tmux -L "$TAU_POPUP_SOCKET" show-options -s user-keys[29] | grep -q '\\033'
    tmux -L "$TAU_POPUP_SOCKET" show-options -s user-keys[30] | grep -q '\\033'
}

@test "popup server: toggle key bindings" {
    tau_test_new_session "s"; tau_ensure_popup_server
    tmux -L "$TAU_POPUP_SOCKET" list-keys -T root User28 | grep -q "tau-popup-git"
    tmux -L "$TAU_POPUP_SOCKET" list-keys -T root User29 | grep -q "tau-popup-editor"
    tmux -L "$TAU_POPUP_SOCKET" list-keys -T root User30 | grep -q "tau-popup-scratch"
}

@test "popup server: ensure is idempotent" {
    tau_test_new_session "s"
    tau_ensure_popup_server
    run tau_ensure_popup_server
    [ "$status" -eq 0 ]
}

# ── close path: type matching ──────────────────────────────────────

@test "close path: matching type matches" {
    [[ "_popup_git_work" == _popup_git_* ]]
    [[ "_popup_editor_work" == _popup_editor_* ]]
    [[ "_popup_scratch_work" == _popup_scratch_* ]]
}

@test "close path: wrong type does not match" {
    [[ "_popup_scratch_work" != _popup_git_* ]]
    [[ "_popup_editor_work" != _popup_scratch_* ]]
    [[ "_popup_git_work" != _popup_editor_* ]]
}

@test "close path: non-popup session does not match" {
    [[ "myproject" != _popup_* ]]
}

# ── per-type outer key config ──────────────────────────────────────

@test "outer key config: each type writes its own user-key index" {
    local git_conf scratch_conf
    git_conf="$(mktemp)"
    scratch_conf="$(mktemp)"

    cat > "$git_conf" << TMUXCONF
set-option -s user-keys[28] "\033[43;9~"
bind-key -n User28 run-shell -b "$TAU_ROOT/scripts/tau-popup-git"
TMUXCONF
    grep -q 'user-keys\[28\]' "$git_conf"

    cat > "$scratch_conf" << TMUXCONF
set-option -s user-keys[30] "\033[45;9~"
bind-key -n User30 run-shell -b "$TAU_ROOT/scripts/tau-popup-scratch"
TMUXCONF
    grep -q 'user-keys\[30\]' "$scratch_conf"

    rm -f "$git_conf" "$scratch_conf"
}

@test "outer key restore: source-file restores removed user-key and binding" {
    tau_test_new_session "s"
    tmux -L "$TAU_SOCKET" set-option -s "user-keys[30]" $'\033[45;9~' 2>/dev/null || true
    tmux -L "$TAU_SOCKET" bind-key -n User30 run-shell -b "echo test"
    tmux -L "$TAU_SOCKET" list-keys -T root User30 | grep -q "echo test"

    # Remove
    tmux -L "$TAU_SOCKET" set-option -u "user-keys[30]" 2>/dev/null || true
    tmux -L "$TAU_SOCKET" unbind-key -n User30 2>/dev/null || true
    run tmux -L "$TAU_SOCKET" list-keys -T root User30 2>/dev/null
    ! echo "$output" | grep -q "echo test"

    # Restore
    local conf; conf="$(mktemp)"
    cat > "$conf" << 'TMUXCONF'
set-option -s user-keys[30] "\033[45;9~"
TMUXCONF
    tmux -L "$TAU_SOCKET" source-file "$conf"
    rm -f "$conf"
    tmux -L "$TAU_SOCKET" bind-key -n User30 run-shell -b "echo test"
    tmux -L "$TAU_SOCKET" list-keys -T root User30 | grep -q "echo test"
}

# ── session lifecycle ───────────────────────────────────────────────

@test "popup session created on popup server" {
    tau_test_new_session "s"; tau_ensure_popup_server
    local sn; sn=$(tau_popup_session_name git s)
    tmux -L "$TAU_POPUP_SOCKET" new-session -d -s "$sn" -c /tmp -- sleep 999999
    tmux -L "$TAU_POPUP_SOCKET" has-session -t "=$sn"
}

@test "popup session cleaned up when program exits" {
    tau_test_new_session "s"; tau_ensure_popup_server
    local sn; sn=$(tau_popup_session_name git s)
    tmux -L "$TAU_POPUP_SOCKET" new-session -d -s "$sn" -c /tmp -- echo bye
    sleep 0.2
    ! tmux -L "$TAU_POPUP_SOCKET" has-session -t "=$sn" 2>/dev/null
}

@test "popup sessions are per-project isolated" {
    tau_test_new_session "a"; tau_test_new_session "b"; tau_ensure_popup_server
    local sa sb
    sa=$(tau_popup_session_name git a)
    sb=$(tau_popup_session_name git b)
    tmux -L "$TAU_POPUP_SOCKET" new-session -d -s "$sa" -c /tmp -- sleep 999999
    tmux -L "$TAU_POPUP_SOCKET" has-session -t "=$sa"
    ! tmux -L "$TAU_POPUP_SOCKET" has-session -t "=$sb" 2>/dev/null
}

@test "popup session with no clients means popup is closed" {
    tau_test_new_session "s"; tau_ensure_popup_server
    local sn; sn=$(tau_popup_session_name scratch s)
    tmux -L "$TAU_POPUP_SOCKET" new-session -d -s "$sn" -c /tmp -- sleep 999999
    local cl; cl=$(tmux -L "$TAU_POPUP_SOCKET" list-clients -t "$sn" 2>/dev/null | wc -l | tr -d ' ')
    [ "$cl" -eq 0 ]
}
