#!/usr/bin/env zsh
set -euo pipefail

# ---------- colours ----------
autoload -U colors && colors
_ok()    { print -P "%F{green}✔ OK%f  $1";   _json "OK"    "$1"; }
_warn()  { print -P "%F{yellow}⚠ WARN%f $1"; _json "WARN"  "$1"; _exitcode=1; }
_fail()  { print -P "%F{red}✖ FAIL%f $1";  _json "FAIL"  "$1"; _exitcode=2; }

# ---------- tiny helpers ----------
has() { command -v "$1" &>/dev/null; }

_exitcode=0
typeset -g _JSON="["

_json() { [[ $SANITY_JSON -eq 1 ]] || return
          local esc=${2//\"/\\\"}; _JSON+="{\"status\":\"$1\",\"msg\":\"$esc\"}," }

_header() { print -P "%B%F{cyan}── $1 ──%f%b"; }

# ---------- background / timeout ----------
_BG_LIMIT=5                     # parallelism cap
typeset -a _BG_PIDS _BG_NAMES

_run_module() {                 # $1 = function, $2 = slug (e.g. 10-python)
  local fn=$1 name=$2
  local slow_var="${fn}_SLOW"
  local slow_flag=${(P)slow_var:-0}   # 0 when flag undefined

  if [[ $slow_flag -eq 1 && $SANITY_FAST -eq 0 ]]; then
    local outf; outf=$(mktemp -t sanity)
    ( { timeout 120 "$fn" } &> "$outf" & )
    _BG_PIDS+=$!
    _BG_NAMES+="$name:$outf"
  else
    "$fn"
  fi
}

_wait_for_background() {
  for i in {1..${#_BG_PIDS[@]}}; do
      wait "${_BG_PIDS[i]}" || true
      local pair=${_BG_NAMES[i]}
      cat "${pair#*:}"
      rm -f "${pair#*:}"
  done
}

# ---------- caching ----------
_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/sanity"
mkdir -p "$_cache_dir"

cache_ok() {  # key seconds
  local f="$_cache_dir/$1.ok" max=$2
  [[ -f $f && $(( $(date +%s) - $(stat -f '%m' "$f") )) -lt $max ]]
}
cache_set() { touch "$_cache_dir/$1.ok"; }

# ---------- summary ----------
_summary_and_exit() {
  if [[ $SANITY_JSON -eq 1 ]]; then
    print "${_JSON%,}]"
  else
    [[ $_exitcode -eq 0 ]] && print -P "%F{green}All good (%$(_score) pts)%f" \
                            || print -P "%F{yellow}Warnings present (%$(_score) pts)%f"
  fi
  exit $_exitcode
}

_score() {                      # naive: 100 - (#WARN*3 + #FAIL*10)
  local w=${_JSON[(s:,:)##WARN]} f=${_JSON[(s:,:)##FAIL]}
  echo $(( 100 - ${#w}*3 - ${#f}*10 ))
}

# ---------- util ----------
_apply_fix() { local msg=$1 cmd=$2
  if [[ $SANITY_FIX -eq 1 ]]; then
       eval "$cmd" && _ok "$msg fixed" || _fail "$msg fix failed"
  fi
}
