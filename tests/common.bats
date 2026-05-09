#!/usr/bin/env bash
# tests/common.bats — e2e tests for lib/common.sh
load 'helpers/setup'

setup() {
    tau_test_kill_server
}

teardown() {
    tau_test_kill_server
}

# ── tau_list_sessions ────────────────────────────────────────────────

@test "list_sessions returns nothing when no sessions exist" {
    run tau_list_sessions
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "list_sessions returns single session" {
    tau_test_new_session "alpha"
    run tau_list_sessions
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "1|alpha" ]
}

@test "list_sessions falls back to creation order when no @sort-index set" {
    tau_test_new_session "first"
    tau_test_new_session "second"
    tau_test_new_session "third"

    run tau_list_sessions
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 3 ]
    echo "$output" | head -1 | grep -q '|first$'
    echo "$output" | tail -1 | grep -q '|third$'
}

@test "list_sessions respects @sort-index" {
    tau_test_new_session "alpha"
    tau_test_new_session "beta"
    tau_test_new_session "gamma"
    tau_test_set_sort_index "alpha" 30
    tau_test_set_sort_index "beta"  10
    tau_test_set_sort_index "gamma" 20

    run tau_list_sessions
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "10|beta" ]
    [ "${lines[1]}" = "20|gamma" ]
    [ "${lines[2]}" = "30|alpha" ]
}

@test "list_sessions handles mixed set/unset @sort-index" {
    tau_test_new_session "no-index"
    tau_test_new_session "indexed"
    tau_test_set_sort_index "indexed" 5

    run tau_list_sessions
    [ "$status" -eq 0 ]
    echo "$output" | head -1 | grep -q '|no-index$'
    echo "$output" | tail -1 | grep -q '|indexed$'
}

# ── tau_current_session ──────────────────────────────────────────────

@test "current_session returns the attached session name" {
    tau_test_new_session "my-session"

    run tau_current_session
    [ "$status" -eq 0 ]
    [ "$output" = "my-session" ]
}
