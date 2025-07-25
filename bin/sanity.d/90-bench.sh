#!/usr/bin/env zsh
run_${0:t:r#*-}() {                           # e.g. run_python
  _header "${0:t:r#*-:u}  MODULE (stub)"
  _ok "placeholder"
}
export -f run_${0:t:r#*-}
