#!/usr/bin/env zsh
run_node() {
  _header "🟢  NODE / NVM"

  if ! ( has nvm && nvm --version >/dev/null 2>&1 ); then
    _warn "NVM not installed"
    return
  fi

  local def_ver=$(nvm version default 2>/dev/null || echo N/A)
  [[ $def_ver == N/A ]] && def_ver=$(nvm version-remote --lts)

  local node_ver=$(node -v 2>/dev/null || echo none)

  [[ $def_ver != N/A ]] && _ok "alias default ⇒ $def_ver" \
                        || _warn "no NVM default alias"

  [[ $node_ver == "$def_ver" ]] \
      && _ok "Node version = default" \
      || _warn "Node $node_ver ≠ $def_ver"

  has npm && _ok "npm CLI present" || _warn "npm missing"
}