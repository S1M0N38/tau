#!/usr/bin/env bash
# tests/popup-editor.bats — tests for tau-popup-editor (TAU_EDITOR_CMD)
load 'helpers/setup'

setup() {
    tau_test_kill_server
}

teardown() {
    tau_test_kill_server
}

@test "popup-editor exits cleanly when TAU_EDITOR_CMD is unset" {
    tau_test_new_session "editor-test"
    unset TAU_EDITOR_CMD

    run bash "${TAU_ROOT}/scripts/tau-popup-editor"
    [ "$status" -eq 0 ]
}

@test "popup-editor attempts to launch when TAU_EDITOR_CMD is set" {
    tau_test_new_session "editor-test"
    export TAU_EDITOR_CMD="echo hello-editor"

    run bash "${TAU_ROOT}/scripts/tau-popup-editor"
}
