#!/usr/bin/env bash
# tests/swap.bats — e2e tests for tau-swap-session
load 'helpers/setup'

setup() {
    tau_test_kill_server
}

teardown() {
    tau_test_detach
    tau_test_kill_server
}

@test "swap next exchanges current with next session" {
    tau_test_new_session "a"
    tau_test_new_session "b"
    tau_test_new_session "c"
    tau_test_set_sort_index "a" 1
    tau_test_set_sort_index "b" 2
    tau_test_set_sort_index "c" 3
    tau_test_attach a

    run bash "${TAU_ROOT}/scripts/tau-swap-session" next
    [ "$status" -eq 0 ]

    # a (pos 1) swaps with b (pos 2), renumbered sequentially
    idx_b=$(tmux -L "$TAU_SOCKET" show-options -t b @sort-index | awk '{print $2}')
    idx_a=$(tmux -L "$TAU_SOCKET" show-options -t a @sort-index | awk '{print $2}')
    idx_c=$(tmux -L "$TAU_SOCKET" show-options -t c @sort-index | awk '{print $2}')
    [ "$idx_b" = "1" ]
    [ "$idx_a" = "2" ]
    [ "$idx_c" = "3" ]
}

@test "swap prev exchanges current with previous session" {
    tau_test_new_session "x"
    tau_test_new_session "y"
    tau_test_new_session "z"
    tau_test_set_sort_index "x" 1
    tau_test_set_sort_index "y" 2
    tau_test_set_sort_index "z" 3
    tau_test_attach z

    run bash "${TAU_ROOT}/scripts/tau-swap-session" prev
    [ "$status" -eq 0 ]

    idx_z=$(tmux -L "$TAU_SOCKET" show-options -t z @sort-index | awk '{print $2}')
    idx_y=$(tmux -L "$TAU_SOCKET" show-options -t y @sort-index | awk '{print $2}')
    [ "$idx_z" = "2" ]
    [ "$idx_y" = "3" ]
}

@test "swap next at boundary does nothing" {
    tau_test_new_session "first"
    tau_test_new_session "second"
    tau_test_set_sort_index "first" 1
    tau_test_set_sort_index "second" 2
    tau_test_attach second

    run bash "${TAU_ROOT}/scripts/tau-swap-session" next
    [ "$status" -eq 0 ]

    idx_first=$(tmux -L "$TAU_SOCKET" show-options -t first @sort-index | awk '{print $2}')
    idx_second=$(tmux -L "$TAU_SOCKET" show-options -t second @sort-index | awk '{print $2}')
    [ "$idx_first" = "1" ]
    [ "$idx_second" = "2" ]
}

@test "swap prev at boundary does nothing" {
    tau_test_new_session "first"
    tau_test_new_session "second"
    tau_test_set_sort_index "first" 1
    tau_test_set_sort_index "second" 2
    tau_test_attach first

    run bash "${TAU_ROOT}/scripts/tau-swap-session" prev
    [ "$status" -eq 0 ]

    idx_first=$(tmux -L "$TAU_SOCKET" show-options -t first @sort-index | awk '{print $2}')
    idx_second=$(tmux -L "$TAU_SOCKET" show-options -t second @sort-index | awk '{print $2}')
    [ "$idx_first" = "1" ]
    [ "$idx_second" = "2" ]
}

@test "swap with single session does nothing" {
    tau_test_new_session "solo"
    tau_test_attach solo

    run bash "${TAU_ROOT}/scripts/tau-swap-session" next
    [ "$status" -eq 0 ]
}
