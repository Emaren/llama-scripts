#!/usr/bin/env zsh
run_git() {
  _header "🔧  GIT BASICS"

  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    _ok "not in a git repo – skipped"
    return
  fi

  has git && _ok "git CLI" || { _fail "git missing"; return; }

  git config --global user.name  &>/dev/null && _ok "user.name set"  \
                                    || _warn "git user.name unset"
  git config --global user.email &>/dev/null && _ok "user.email set" \
                                    || _warn "git user.email unset"

  local ahead_behind
  ahead_behind=$(git rev-list --left-right --count @{u}...HEAD 2>/dev/null || echo "0 0")
  [[ $ahead_behind == "0 0" ]] && _ok "repo in sync" \
                               || _warn "branch ahead/behind"
}