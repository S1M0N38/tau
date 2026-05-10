#!/usr/bin/env bash
# tests/spawn-pi.bats — e2e tests for tau-spawn-pi grid layout
load 'helpers/setup'

setup() {
    tau_test_kill_server
}

teardown() {
    tau_test_kill_server
}

@test "spawn-pi on idle shell sends pi to current pane instead of splitting" {
    # Sessions with a shell — spawn-pi detects idle shell and sends "pi" inline
    tmux -L "$TAU_SOCKET" new-session -d -s shell-test -x 240 -y 60 "bash"

    run bash "${TAU_ROOT}/scripts/tau-spawn-pi"
    [ "$status" -eq 0 ]

    pane_count=$(tmux -L "$TAU_SOCKET" list-panes -t shell-test -F '#{pane_id}' | wc -l | tr -d ' ')
    [ "$pane_count" -eq 1 ]
}

@test "spawn-pi creates a new pane when current pane is busy" {
    tmux -L "$TAU_SOCKET" new-session -d -s busy-test -x 240 -y 60 "sleep 300"

    run bash "${TAU_ROOT}/scripts/tau-spawn-pi"
    [ "$status" -eq 0 ]

    pane_count=$(tmux -L "$TAU_SOCKET" list-panes -t busy-test -F '#{pane_id}' | wc -l | tr -d ' ')
    [ "$pane_count" -eq 2 ]
}

@test "spawn-pi applies equal-width grid for 2 panes in 240-col window" {
    tmux -L "$TAU_SOCKET" new-session -d -s grid-test -x 240 -y 60 "sleep 300"

    run bash "${TAU_ROOT}/scripts/tau-spawn-pi"
    [ "$status" -eq 0 ]

    widths=$(tmux -L "$TAU_SOCKET" list-panes -t grid-test -F '#{pane_width}')
    w1=$(echo "$widths" | sed -n '1p')
    w2=$(echo "$widths" | sed -n '2p')
    diff=$(( w1 - w2 ))
    [ "${diff#-}" -le 2 ]
}
