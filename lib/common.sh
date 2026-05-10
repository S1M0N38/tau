#!/usr/bin/env bash
# lib/common.sh — shared functions for tau scripts

TAU_SOCKET="${TAU_SOCKET:-tau}"

# Output: <sort-index>|<session-name> (creation-order fallback when @sort-index unset)
# Sessions with @hidden on are excluded.
tau_list_sessions() {
    local idx=0
    tmux -L "$TAU_SOCKET" list-sessions -F '#{session_name}|#{@sort-index}|#{@hidden}' 2>/dev/null | {
        while IFS='|' read -r name sort_idx hidden; do
            [ "$hidden" = "on" ] && continue
            idx=$((idx + 1))
            echo "${sort_idx:-$idx}|$name"
        done
    } | sort -t'|' -k1 -n -s
}

tau_current_session() {
    tmux -L "$TAU_SOCKET" display-message -p '#{session_name}'
}
