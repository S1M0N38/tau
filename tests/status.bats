#!/usr/bin/env bash
# tests/status.bats — e2e tests for tau-status-sessions
load 'helpers/setup'

setup() {
    tau_test_kill_server
}

teardown() {
    tau_test_kill_server
}

@test "status outputs session names in order" {
    tau_test_new_session "alpha"
    tau_test_new_session "beta"

    run bash "${TAU_ROOT}/scripts/tau-status-sessions" "alpha"
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "alpha"
    echo "$output" | grep -q "beta"
}

@test "status highlights current session with blue badge" {
    tau_test_new_session "active"
    tau_test_new_session "inactive"

    run bash "${TAU_ROOT}/scripts/tau-status-sessions" "active"
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "bg=#82aaff.*active"
}

@test "status respects @sort-index ordering" {
    tau_test_new_session "z-last"
    tau_test_new_session "a-first"
    tau_test_set_sort_index "a-first" 1
    tau_test_set_sort_index "z-last"  2

    run bash "${TAU_ROOT}/scripts/tau-status-sessions" "a-first"
    [ "$status" -eq 0 ]
    pos_a=$(echo "$output" | grep -bo 'a-first' | head -1 | cut -d: -f1)
    pos_z=$(echo "$output" | grep -bo 'z-last'  | head -1 | cut -d: -f1)
    [ "$pos_a" -lt "$pos_z" ]
}

@test "status shows position numbers" {
    tau_test_new_session "one"
    tau_test_new_session "two"
    tau_test_new_session "three"
    tau_test_set_sort_index "one" 1
    tau_test_set_sort_index "two" 2
    tau_test_set_sort_index "three" 3

    run bash "${TAU_ROOT}/scripts/tau-status-sessions" "one"
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "1 one"
    echo "$output" | grep -q "2 two"
    echo "$output" | grep -q "3 three"
}
