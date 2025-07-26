#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

ROOT="$HOME/projects"
OUTFILE="$ROOT/llama-scripts/venv-missing.log"
> "$OUTFILE"

shorten_path() {
  echo "${1/#$HOME/~}" \
    | sed -E 's|/Users/[^/]+/projects/([^/]+)/.*|~/.p/\1/...python|'
}

# ───── Table Settings ─────
HEADER="📊 Global Python Venv Audit — $(date '+%Y-%m-%d %H:%M')"
w1=24 w2=9 w3=15 w4=11 w5=8 w6=38 w7=14
brd=$(printf '─%.0s' {1..134})
fmt="│ %-${w1}s│ %-${w2}s│ %-${w3}s│ %-${w4}s│ %-${w5}s│ %-${w6}s│ %-${w7}s│\n"

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

  if [[ -x .direnv/python-3.13/bin/python ]]; then
    PYBIN=".direnv/python-3.13/bin/python"; VTYPE="direnv-local"
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
    HINTS+=("missing")
  fi

  lf=$(ls -t venv-freeze-*.log 2>/dev/null | head -1 || true)
  if [[ -n $lf ]]; then
    m=$(stat -f "%m" "$lf"); now=$(date +%s)
    d=$(( (now - m) / 86400 ))
    FAGE="${d}d"; (( d>0 )) && FAGE+=" 🚨"

    if [[ -f requirements.txt ]] && ! diff -q requirements.txt "$lf" &>/dev/null; then
      HINTS+=("drift")
    fi
  else
    HINTS+=("no-freeze")
  fi

  # 🧼 Drift-cleanup logic: if HEALTH is good and direnv-local, remove hint
  if [[ "$HEALTH" == "✅" && "$VTYPE" == "direnv-local" ]]; then
    HINTS=("${HINTS[@]/drift}")
  fi

  # Collapse multiple spaces from empty hint slots
  HINT_TXT=$(printf "%-${w7}s" "$(IFS=" "; echo "${HINTS[*]}")")

  printf "$fmt" \
    "$repo" "$VERSION" "$VTYPE" "$FAGE" "$HEALTH" "$PYPATH" "$HINT_TXT"
done

# ───── Footer ─────
printf "└%s┘\n" "${brd}"
echo -e "\n📄 Broken or missing venvs logged to: $OUTFILE"
echo "✅ Done."
