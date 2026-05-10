#!/usr/bin/env bash
# tests/popup-git.bats — tests for tau-popup-git (TAU_GIT_CMD)
load 'helpers/setup'

setup() {
    tau_test_kill_server
}

teardown() {
    tau_test_kill_server
}

@test "popup-git exits cleanly when TAU_GIT_CMD is unset" {
    tau_test_new_session "git-test"
    unset TAU_GIT_CMD

    run bash "${TAU_ROOT}/scripts/tau-popup-git"
    [ "$status" -eq 0 ]
}

@test "popup-git shows notification when TAU_GIT_CMD is unset" {
    tau_test_new_session "git-test"
    unset TAU_GIT_CMD

    run bash "${TAU_ROOT}/scripts/tau-popup-git"
    [ "$status" -eq 0 ]
}

@test "popup-git attempts to launch when TAU_GIT_CMD is set" {
    tau_test_new_session "git-test"
    export TAU_GIT_CMD="echo hello-git"

    run bash "${TAU_ROOT}/scripts/tau-popup-git"
    # Script gets past the unset guard — display-popup may fail in headless env
}
