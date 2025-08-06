#!/usr/bin/env zsh
# Lint the launcher itself (fast)

run_selflint() {
  _header "🪄  SHELL LINT"

  if has shellcheck; then
    shellcheck -q "$SANITY_DIR/sanity" \
      && _ok  "ShellCheck clean" \
      || _warn "ShellCheck reported issues"
  else
    _warn "shellcheck not installed"
  fi

  if has shfmt; then
    shfmt -d "$SANITY_DIR/sanity" | grep -q '^$' \
      && _ok  "shfmt formatted" \
      || _warn "shfmt would re-format sanity"
  else
    _warn "shfmt not installed"
  fi
}