#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

# ───── Detect root path ─────
if [[ -d /var/www && "$(hostname)" == "wolo" ]]; then
  ROOT="/var/www"
else
  ROOT="$HOME/projects"
fi

OUTFILE="/tmp/venv-missing-$(date +%s).log"
> "$OUTFILE"

# ───── Path shortening logic ─────
shorten_path() {
  case "$1" in
    "$HOME"/*) echo "${1/#$HOME/~}" ;;
    /var/www/*) echo "${1/#\/var\/www/\/var/www}" ;;
    *) echo "$1" ;;
  esac
}

# ───── Table Settings ─────
HEADER="📊 Global Python Venv Audit — $(date '+%Y-%m-%d %H:%M')"
w1=24 w2=8 w3=15 w4=10 w5=8 w6=36 w7=16
brd=$(printf '─%.0s' {1..132})
fmt="│ %-$(($w1-1))s│ %-$(($w2-1))s│ %-$(($w3-1))s│ %-$(($w4-1))s│ %-$(($w5-1))s│ %-$(($w6-1))s│ %-${w7}s│\n"

# ───── Print Header ─────
printf "\n%s\n\n" "$HEADER"
printf "┌%s┐\n" "${brd}"
printf "$fmt" "Repo" "Version" "Type" "Freeze Age" "Health" "Python Path" "Hints"
printf "├%s┤\n" "${brd}"

# ───── Row Logic ─────
for dir in "$ROOT"/*/; do
  repo=${dir%/}; repo=${repo##*/}
  cd "$dir" || continue

  PYBIN="" VERSION="—" VTYPE="—" FAGE="—" HEALTH="❌"
  PYPATH="(not found)" HINTS=()

  if [[ -x .direnv/python-3.13.5/bin/python ]]; then
    PYBIN=".direnv/python-3.13.5/bin/python"; VTYPE="direnv-local"
  elif [[ -x .direnv/python-3.13/bin/python ]]; then
    PYBIN=".direnv/python-3.13/bin/python"; VTYPE="direnv-legacy"
  elif [[ -d .direnv ]]; then
    PYBIN=$(find .direnv -path '*/bin/python' -type f | head -1)
    [[ -n $PYBIN ]] && VTYPE="direnv-unknown"
  elif [[ -f .python-version ]]; then
    env=$(<.python-version)
    PYBIN="$(pyenv root)/versions/$env/bin/python"; VTYPE="pyenv-layout"
  fi

  if [[ -x $PYBIN ]]; then
    VERSION="$("$PYBIN" -c 'import sys; print(".".join(map(str,sys.version_info[:3])))')"
    "$PYBIN" -c 'import sys' &>/dev/null && HEALTH="✅"
    PYPATH=$(shorten_path "$PYBIN")
  else
    echo "$repo" >>"$OUTFILE"
    HINTS+=("🛠 missing")
  fi

  if [[ -f venv-freeze.log ]]; then
    if stat -f "%m" . &>/dev/null; then
      m=$(stat -f "%m" venv-freeze.log)  # macOS
    else
      m=$(stat -c "%Y" venv-freeze.log)  # Linux
    fi
    now=$(date +%s)
    d=$(( (now - m) / 86400 ))
    FAGE="${d}d"; (( d>0 )) && FAGE+=" 🚨"

    TMP_FREEZE=$(mktemp)
    "$PYBIN" -m pip freeze > "$TMP_FREEZE" 2>/dev/null || true
    if ! diff -q "$TMP_FREEZE" venv-freeze.log &>/dev/null; then
      HINTS+=("🧹 drift")
    fi
    rm -f "$TMP_FREEZE"
  else
    HINTS+=("📄 no-freeze")
  fi

  # ───── Patch .envrc for clean Starship ─────
  if [[ -x $PYBIN ]]; then
    ENVRC_PATH="$dir/.envrc"
    ACTIVATE_LINE="source $PYBIN/activate"
    if [[ -f "$ENVRC_PATH" ]]; then
      grep -vE '^export VIRTUAL_ENV=|^export PATH=|^source .*/activate|^export STARSHIP_VENV=' "$ENVRC_PATH" > "$ENVRC_PATH.tmp" || true
      echo "$ACTIVATE_LINE" >> "$ENVRC_PATH.tmp"
      mv "$ENVRC_PATH.tmp" "$ENVRC_PATH"
    else
      echo "$ACTIVATE_LINE" > "$ENVRC_PATH"
    fi
  fi

  HINT_TXT=$(printf "%-${w7}s" "${HINTS[*]:-}")
  printf "$fmt" \
    "$repo" "$VERSION" "$VTYPE" "$FAGE" "$HEALTH" "$PYPATH" "$HINT_TXT"

  # ───── Move freeze logs to ./venv-logs/ ─────
  mkdir -p "$dir/venv-logs"
  mv -f "$dir"/venv-freeze*.log* "$dir/venv-logs/" 2>/dev/null || true
done

# ───── Footer ─────
printf "└%s┘\n" "${brd}"
echo -e "\n📄 Broken or missing venvs logged to: $OUTFILE"
echo "✅ Done."
