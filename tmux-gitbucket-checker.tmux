#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tmux bind-key T run-shell "$CURRENT_DIR/scripts/tmux_list_plugins.sh"

place_holder="\#{gbchk}"

interpolate() {
    local -r status="$1"
    local -r GITBUCKET_RELEASE=$(wget -q --max-redirect=1 -S -O - https://github.com/takezoe/gitbucket/releases/latest 2>&1 | grep -e 'Location: ' | grep -o "http.*" | grep "tag")
    local -r GITBUCKET_VERSION=$(echo ${GITBUCKET_RELEASE} | sed -e "s/^http.*\/tag\///")

    if [ ! -f $CURRENT_DIR/CURRENT_VERSION ]; then
        echo ${GITBUCKET_VERSION} > $CURRENT_DIR/CURRENT_VERSION
    fi
    grep -q "${GITBUCKET_VERSION}" $CURRENT_DIR/CURRENT_VERSION
    local result=$?
    local check=''
    if [ $result -ne 0 ]; then
        check="#[fg=red]gitbucket UPDATED"
        echo ${GITBUCKET_VERSION} > $CURRENT_DIR/CURRENT_VERSION
    fi
    local -r status_value=$(tmux show-option -gqv "$status")
    tmux set-option -gq "$status" "${status_value/$place_holder/$check}"
}

main() {
    interpolate "status-right"
}

main
