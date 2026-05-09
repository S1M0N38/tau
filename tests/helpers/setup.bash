#!/usr/bin/env bash
# tests/helpers/setup.bash — shared test setup
# Loaded via `load 'helpers/setup'` from test files.
# bats resolves helpers/setup.bash relative to the test file's directory.

# Resolve TAU_ROOT: BATS_TEST_DIRNAME points at tests/ → project root is one level up.
export TAU_ROOT
TAU_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"

# Source lib/common.sh first (defines functions, sets TAU_SOCKET to default "tau").
source "${TAU_ROOT}/lib/common.sh"

# NOW override to a dedicated test socket — never touches the user's real tau server.
# common.sh uses ${TAU_SOCKET:-tau} so this override is respected by the functions
# AND by child scripts (via the exported env var).
export TAU_SOCKET="tau-test"

# ── helpers ──────────────────────────────────────────────────────────

# Create a session with a long-running command so it stays alive in headless tests.
tau_test_new_session() {
    local name="${1:-test-session}"
    tmux -L "$TAU_SOCKET" new-session -d -s "$name" "sleep 999999" 2>/dev/null
}

tau_test_kill_server() {
    tmux -L "$TAU_SOCKET" kill-server 2>/dev/null || true
}

# Create N numbered sessions: s1, s2, s3 …
tau_test_create_sessions() {
    local n="$1"
    local i=1
    while [ "$i" -le "$n" ]; do
        tau_test_new_session "s$i"
        i=$((i + 1))
    done
}

# Set @sort-index on a session.
tau_test_set_sort_index() {
    local session="$1"
    local idx="$2"
    tmux -L "$TAU_SOCKET" set-option -t "$session" @sort-index "$idx"
}

# Attach a tmux client using script(1) as a PTY wrapper.
# Needed for switch-client (requires an attached client).
tau_test_attach() {
    local session="$1"
    script -q /dev/null tmux -L "$TAU_SOCKET" attach -t "$session" &
    _TAU_CLIENT_PID=$!
    sleep 0.5
}

# Kill the background client.
tau_test_detach() {
    kill "$_TAU_CLIENT_PID" 2>/dev/null || true
    wait "$_TAU_CLIENT_PID" 2>/dev/null || true
}
