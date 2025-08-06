#!/usr/bin/env zsh
run_path() {
  _header "🛣️  PATH SANITY"

  local dup=$(tr ':' '\n' <<<"$PATH" | sort | uniq -d)
  [[ -z $dup ]] && _ok "no duplicate segments" \
                || _warn "duplicate PATH: $dup"

  grep -q "$HOME/.local/bin" <<<"$PATH" \
      && _ok  "~/.local/bin present" \
      || _warn "~/.local/bin missing"
}