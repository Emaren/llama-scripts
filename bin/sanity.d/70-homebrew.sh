#!/usr/bin/env zsh
run_homebrew() {
  _header "🍺  HOMEBREW"

  if ! has brew; then
    _warn "Homebrew not installed"
    return
  fi

  # brew doctor (24 h cache)
  if cache_ok "brew_doctor" 86400; then
    _ok "brew doctor clean (cached)"
  else
    if brew doctor -q &>/dev/null; then
      _ok "brew doctor clean"
      cache_set "brew_doctor"
    else
      _warn "brew doctor reports issues"
    fi
  fi

  # analytics
  brew analytics | grep -q disabled \
      && _ok "analytics off" \
      || { _warn "analytics on"; _apply_fix "disable analytics" "brew analytics off"; }
}
run_homebrew_SLOW=1