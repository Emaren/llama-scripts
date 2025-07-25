#!/usr/bin/env zsh
run_env() {
  _header "✨  ENV MANAGEMENT"

  if has direnv; then
    direnv status 2>&1 | grep -q "Loaded RC allowed" \
        && _ok ".envrc allowed"   \
        || _warn ".envrc not allowed"
  else
    _warn "direnv not installed"
  fi

  if has pyenv && [[ $(pyenv version-name) != system ]]; then
    _ok "direnv sees pyenv env"
  fi

  grep -q '\[git_status\]' ~/.config/starship.toml 2>/dev/null \
      && _ok "Starship git_status enabled" \
      || _warn "Starship git_status missing"
}