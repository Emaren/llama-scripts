#!/usr/bin/env zsh
run_bench() {
  [[ $SANITY_BENCH -eq 1 ]] || return
  _header "⏱️  TIMINGS"

  local shell_ms=${ZSH_START_TIME:-0}
  local run_ms=$(( $(date +%s%3N) - ${START_TS:-0} ))

  [[ $shell_ms -lt 500 ]] && _ok "shell startup ${shell_ms} ms" \
                           || _warn "shell startup ${shell_ms} ms"

  [[ $run_ms -lt 2000 ]] && _ok "runtime ${run_ms} ms" \
                          || _warn "runtime ${run_ms} ms"
}