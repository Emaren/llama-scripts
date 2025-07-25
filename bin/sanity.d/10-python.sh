#!/usr/bin/env zsh
# Python tool-chain

run_python() {
  _header "🐍  PYTHON TOOLCHAIN"

  if ! has pyenv; then
    _warn "pyenv not installed"
    return
  fi

  # pyenv doctor (slow) -----------------------------------------
  if [[ $SANITY_FAST -eq 1 ]]; then
    _warn "FAST mode – skipping pyenv doctor"
  else
    pyenv doctor &>/dev/null \
        && _ok  "pyenv doctor" \
        || _warn "pyenv doctor reported issues"
  fi

  # interpreter version -----------------------------------------
  python - <<'PY' && _ok "Python ⩾3.12" || _fail "Python <3.12"
import sys; exit(0 if sys.version_info >= (3,12) else 1)
PY

  # pre-commit ---------------------------------------------------
  if pre-commit --version 2>&1 | grep -q ' 4\.'; then
    _ok  "pre-commit ⩾4"
  else
    _warn "pre-commit <4"
    _apply_fix "install pre-commit" "pipx install pre-commit"
  fi

  # pipx shim path ----------------------------------------------
  tr ':' '\n' <<<"$PATH" | grep -q "$HOME/.local/bin" \
      && _ok  "pipx on PATH" \
      || _warn "pipx dir missing from PATH"

  # Poetry venv guard -------------------------------------------
  if [[ -f pyproject.toml ]]; then
    poetry env info --path &>/dev/null \
        && _ok  "Poetry venv detected" \
        || _fail "Poetry venv missing"
  else
    _ok "No pyproject.toml – Poetry check skipped"
  fi

  # single pyenv shim path --------------------------------------
  [[ $(tr ':' '\n' <<<"$PATH" | grep -c '/.pyenv/shims') -eq 1 ]] \
      && _ok  "single pyenv shim path" \
      || _warn "duplicate pyenv shim segments"
}
