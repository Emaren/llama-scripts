#!/usr/bin/env zsh
run_cloud() {
  _header "☁️  CLOUD CLI"

  has aws && _ok "AWS CLI"  || _warn "AWS CLI missing"
  has gh  && _ok "GitHub CLI" || _warn "gh CLI missing"
}