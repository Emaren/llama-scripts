#!/usr/bin/env zsh
run_precommit() {
  _header "🧶  PRE-COMMIT"

  [[ -f .pre-commit-config.yaml ]] || { _ok "no config – skipped"; return; }

  pre-commit validate-config -q && _ok "config valid" \
                                 || _fail "config invalid"
}