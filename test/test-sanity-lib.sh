#!/usr/bin/env zsh
set -euo pipefail

source ./lib/sanity-lib.sh

_header "Checking project sanity..."
_ok "Everything looks good"
_warn "Just a test warning"
_fail "Just a test failure"
_summary_and_exit

