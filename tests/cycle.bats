#!/usr/bin/env bash
# tests/cycle.bats — e2e tests for tau-cycle-session
load 'helpers/setup'

setup() {
    tau_test_kill_server
}

teardown() {
    tau_test_detach
    tau_test_kill_server
}

# bats test_tags=tmux:external
@test "cycle next wraps from last to first" {
    tau_test_create_sessions 3
    tau_test_attach s3

    run bash "${TAU_ROOT}/scripts/tau-cycle-session" next
    [ "$status" -eq 0 ]

    run tau_current_session
    [ "$output" = "s1" ]
}

# bats test_tags=tmux:external
@test "cycle prev wraps from first to last" {
    tau_test_create_sessions 3
    tau_test_attach s1

    run bash "${TAU_ROOT}/scripts/tau-cycle-session" prev
    [ "$status" -eq 0 ]

    run tau_current_session
    [ "$output" = "s3" ]
}

# bats test_tags=tmux:external
@test "cycle next goes forward in sort order" {
    tau_test_new_session "c"
    tau_test_new_session "a"
    tau_test_new_session "b"
    tau_test_set_sort_index "a" 1
    tau_test_set_sort_index "b" 2
    tau_test_set_sort_index "c" 3
    tau_test_attach a

    run bash "${TAU_ROOT}/scripts/tau-cycle-session" next
    [ "$status" -eq 0 ]

    run tau_current_session
    [ "$output" = "b" ]
}

# bats test_tags=tmux:external
@test "cycle prev goes backward in sort order" {
    tau_test_new_session "c"
    tau_test_new_session "a"
    tau_test_new_session "b"
    tau_test_set_sort_index "a" 1
    tau_test_set_sort_index "b" 2
    tau_test_set_sort_index "c" 3
    tau_test_attach c

    run bash "${TAU_ROOT}/scripts/tau-cycle-session" prev
    [ "$status" -eq 0 ]

    run tau_current_session
    [ "$output" = "b" ]
}

# bats test_tags=tmux:external
@test "cycle with single session stays on it" {
    tau_test_new_session "only"
    tau_test_attach only

    run bash "${TAU_ROOT}/scripts/tau-cycle-session" next
    [ "$status" -eq 0 ]

    run tau_current_session
    [ "$output" = "only" ]
}
