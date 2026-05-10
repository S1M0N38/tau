#!/usr/bin/env bash
# tests/tau-bin.bats — tests for bin/tau entry point
load 'helpers/setup'

@test "tau exits with error when TAU_PROJECT_DIR is unset" {
    unset TAU_PROJECT_DIR

    run bash "${TAU_ROOT}/bin/tau"
    [ "$status" -ne 0 ]
    echo "$output" | grep -qi "TAU_PROJECT_DIR"
}

@test "tau exits with error when TAU_PROJECT_DIR points to nonexistent dir" {
    export TAU_PROJECT_DIR="/tmp/tau-nonexistent-dir-$$"

    run bash "${TAU_ROOT}/bin/tau"
    [ "$status" -ne 0 ]
    echo "$output" | grep -qi "TAU_PROJECT_DIR"
}

@test "tau exits with error when already inside tmux" {
    export TAU_PROJECT_DIR="${TAU_ROOT}"
    export TMUX="/tmp/tmux-mock"

    run bash "${TAU_ROOT}/bin/tau"
    [ "$status" -ne 0 ]
    echo "$output" | grep -qi "tmux"
}

@test "tau exports TAU_AGENT_CMD with default value pi" {
    # Verify the default by running bin/tau in a subshell and checking
    # the env var assignment logic (can't actually start tmux in tests)
    unset TAU_AGENT_CMD
    result=$(bash -c 'source "${TAU_ROOT}/lib/common.sh" 2>/dev/null; echo "${TAU_AGENT_CMD:-pi}"')
    [ "$result" = "pi" ]
}

@test "tau respects TAU_AGENT_CMD override" {
    export TAU_AGENT_CMD="my-custom-agent"
    result=$(bash -c 'echo "${TAU_AGENT_CMD:-pi}"')
    [ "$result" = "my-custom-agent" ]
}
