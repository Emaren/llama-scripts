#!/usr/bin/env zsh
run_extras() {
  _header "☸️  EXTRA TOOLING"

  has poetry    && _ok "Poetry CLI"    || _warn "Poetry missing"
  has terraform && _ok "Terraform CLI" || _warn "Terraform missing"
  has kubectl   && _ok "kubectl CLI"   || _warn "kubectl missing"
  has helm      && _ok "Helm CLI"      || _warn "Helm missing"

  if [[ -f pyproject.toml && has poetry ]]; then
    poetry env info --path &>/dev/null \
        && _ok "Poetry venv OK" \
        || _fail "Poetry venv missing"
  fi
}