#!/usr/bin/env bash
# direnv-bootstrap-all.sh — Multi-project Python venv bootstrapper
# 🐍 Uses Python 3.13.5 via pyenv, sets up .direnv/venv and logs summary
# ────────────────────────────────────────────────────────────────────
# Flags:
#   --dry-run        → Preview actions without executing
#   --force          → Bootstrap even if no Python files detected
#   --only <project> → Bootstrap just one matching project

set -euo pipefail
shopt -s nullglob

# ──────────────── ⚙️ Config ────────────────
PYVER="3.13.5"
PYSHORT="3.13"
ROOT="$HOME/projects"
HELPER="$ROOT/llama-scripts/bin/direnv-bootstrap.sh"
LOGFILE="$HOME/.venv-bootstrap.log"
UPDATED=()
SKIPPED=()
STALE=()

# ⏱ Start timer
START=$(date +%s)

# 🏷️ Flag parsing
DRY=0
FORCE=0
ONLY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY=1 ;;
    --force)   FORCE=1 ;;
    --only)    shift; ONLY="$1" ;;
    --help|-h)
      echo -e "Usage: direnv-bootstrap-all.sh [--dry-run] [--force] [--only <project>]\n"
      echo "  --dry-run         Preview what would happen"
      echo "  --force           Run even if no Python files found"
      echo "  --only <project>  Run only the specified project"
      exit 0
      ;;
  esac
  shift
done

# 🐍 Ensure Python installed
echo -e "\033[1;34m🐍 Ensuring pyenv has Python $PYVER …\033[0m"
pyenv install "$PYVER" -s
pyenv global "$PYVER"

# 🔐 Check for secrets
[[ -f .env || -f secrets.env ]] && echo -e "🔐 \033[33m.env or secrets.env detected — ensure secrets are excluded from Git!\033[0m"

# 🚫 Warn about active venv
if [[ -n "${VIRTUAL_ENV:-}" ]]; then
  echo -e "⚠️  \033[31mActive venv detected: $VIRTUAL_ENV — consider deactivating before running this script.\033[0m"
fi

# 🔍 Bootstrap loop
echo -e "\n\033[1;36m🔁 Scanning for Python projects in $ROOT\033[0m"
echo "────────────────────────────────────────────"

for dir in "$ROOT"/*/; do
  [[ -d "$dir" ]] || continue
  name="$(basename "$dir")"
  [[ -n "$ONLY" && "$name" != "$ONLY" ]] && continue

  cd "$dir"

  # Check if it's a Python project
  if [[ "$FORCE" -eq 0 && ! ( -f requirements.txt || -f pyproject.toml || -f setup.py ) ]]; then
    SKIPPED+=("$name")
    continue
  fi

  # Check for stale venv
  marker="$dir/.direnv/python-$PYSHORT"
  if [[ -d "$marker" ]]; then
    if [[ ( -f requirements.txt && requirements.txt -nt "$marker" ) || \
          ( -f pyproject.toml && pyproject.toml -nt "$marker" ) ]]; then
      echo -e "⚠️  \033[33m$name — venv may be stale (dependencies updated)\033[0m"
      STALE+=("$name")
    else
      echo -e "⏭️  \033[2mSkipping $name — already has .direnv/python-$PYSHORT\033[0m"
      SKIPPED+=("$name")
      continue
    fi
  fi

  echo -e "\n▶ \033[1mBootstrapping: $name\033[0m"
  if (( DRY )); then
    echo "[dry-run] $HELPER \"$dir\""
  else
    "$HELPER" "$dir"

    # Save freeze & diff if possible
    FREEZE="venv-freeze-$(date +%Y%m%d-%H%M).log"
    pip freeze > "$FREEZE" || true
    if [[ -f .venv-freeze-prev.log ]]; then
      echo "🧬 Changes since last freeze:"
      diff .venv-freeze-prev.log "$FREEZE" | grep '^[<>]' || echo "  No diff."
    fi
    cp "$FREEZE" .venv-freeze-prev.log

    UPDATED+=("$name")
  fi
done

# 📊 Summary
echo -e "\n📊 \033[1;33mBootstrap Summary\033[0m"
printf "\n%-24s │ %-10s\n" "Project" "Status"
echo "────────────────────────────┼──────────────"
for name in $(printf '%s\n' "${UPDATED[@]}" | sort); do printf "%-24s │ ✅ Updated\n" "$name"; done
for name in $(printf '%s\n' "${STALE[@]}"   | sort); do printf "%-24s │ ⚠️  Rebuilt\n" "$name"; done
for name in $(printf '%s\n' "${SKIPPED[@]}" | sort); do printf "%-24s │ ⏭️  Skipped\n" "$name"; done

# 📜 Log
if [[ "${#UPDATED[@]}" -gt 0 ]]; then
  {
    echo -e "\n▶ $(date '+%F %T') — venv bootstrap summary:"
    for proj in "${UPDATED[@]}"; do
      echo "  • $proj"
    done
  } >> "$LOGFILE"
fi

# ⏱ Done
END=$(date +%s)
echo -e "\n✅ \033[1;32mAll applicable Python projects are now bootstrapped with .direnv/python-$PYSHORT\033[0m"
echo -e "⏱ Total time: $((END - START))s"
