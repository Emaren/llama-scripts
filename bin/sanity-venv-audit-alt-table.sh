# #!/usr/bin/env bash
# set -euo pipefail
# shopt -s nullglob

# ROOT="$HOME/projects"
# OUTFILE="$ROOT/llama-scripts/venv-missing.log"
# > "$OUTFILE"

# # Collapse full path to "~/.p/<repo>/...python"
# shorten_path() {
#   echo "${1/#$HOME/~}" \
#     | sed -E 's|/Users/[^/]+/projects/([^/]+)/.*|~/.p/\1/...python|'
# }

# # ───── Table Header ─────
# printf "\n📊 Global Python Venv Audit — %s\n\n" \
#   "$(date '+%Y-%m-%d %H:%M')"

# # ───── COLUMN WIDTHS ─────
# w1=22  # Repo
# w2=8   # Version
# w3=14  # Type
# w4=12  # Freeze Age
# w5=9   # Health
# w6=32  # Python Path
# w7=12  # Hints

# # ───── ROW FORMAT ─────
# fmt="%-${w1}s │ %-${w2}s │ %-${w3}s │ %-${w4}s │ %-${w5}s │ %-${w6}s │ %-${w7}s\n"

# # ───── PRINT HEADER ─────
# printf "$fmt" "Repo" "Version" "Type" "Freeze Age" "Health" "Python Path" "Hints"
# printf '───────────────────────┼──────────┼────────────────┼──────────────┼───────────┼──────────────────────────────────┼─────────────\n'

# # ───── ROW LOOP ─────
# for dir in "$ROOT"/*/; do
#   repo=${dir%/}; repo=${repo##*/}
#   cd "$dir" || continue

#   PYBIN="" VERSION="—" VTYPE="—" FAGE="—" HEALTH="❌"
#   PYPATH="(not found)" HINTS=()

#   # locate python
#   if [[ -x .direnv/python-3.13/bin/python ]]; then
#     PYBIN=".direnv/python-3.13/bin/python"; VTYPE="direnv-local"
#   elif [[ -d .direnv ]]; then
#     PYBIN=$(find .direnv -path '*/bin/python' -type f | head -1)
#     [[ -n $PYBIN ]] && VTYPE="direnv-unknown"
#   elif [[ -f .python-version ]]; then
#     env=$(<.python-version)
#     PYBIN="$(pyenv root)/versions/$env/bin/python"; VTYPE="pyenv-layout"
#   fi

#   # version & health
#   if [[ -x $PYBIN ]]; then
#     VERSION="$("$PYBIN" -c 'import sys; print(".".join(map(str,sys.version_info[:3])))')"
#     "$PYBIN" -c 'import sys' &>/dev/null && HEALTH="✅"
#     PYPATH=$(shorten_path "$PYBIN")
#   else
#     echo "$repo" >>"$OUTFILE"
#     HINTS+=("🛠 missing")
#   fi

#   # freeze-age & drift hint
#   lf=$(ls -t venv-freeze-*.log 2>/dev/null | head -1 || true)
#   if [[ -n $lf ]]; then
#     m=$(stat -f "%m" "$lf"); now=$(date +%s)
#     d=$(( (now - m) / 86400 ))
#     FAGE="${d}d"; (( d>0 )) && FAGE+=" 🚨"
#     if [[ -f requirements.txt ]] && ! diff -q requirements.txt "$lf" &>/dev/null; then
#       HINTS+=("🧹 drift")
#     fi
#   else
#     HINTS+=("📄 no-freeze")
#   fi

#   # print the row
#   printf "$fmt" \
#     "$repo" "$VERSION" "$VTYPE" "$FAGE" "$HEALTH" "$PYPATH" "${HINTS[*]:-}"
# done

# # ───── FOOTER ─────
# echo -e "\n📄 Broken or missing venvs logged to: $OUTFILE"
# echo "✅ Done."
