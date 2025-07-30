#!/usr/bin/env bash
# direnv-bootstrap-all.sh — Multi-project Python venv bootstrapper
# 🐍 Uses Python 3.13.5 via pyenv, sets up named .direnv/<project><pyver> and logs summary
# ────────────────────────────────────────────────────────────────────
# Flags:
#   --dry-run        → Preview actions without executing
#   --force          → Bootstrap even if no Python files detected
#   --only <project> → Bootstrap just one matching project

set -euo pipefail
shopt -s nullglob

# ──────────────── ⚙️ Config ────────────────
PYVER="3.13.5"
PYSHORT="313"

if [[ -d "/var/www/llama-scripts" ]]; then
  ROOT="/var/www"
else
  ROOT="$HOME/projects"
fi

HELPER="$ROOT/llama-scripts/bin/direnv-bootstrap.sh"
LOGFILE="$HOME/.venv-bootstrap.log"
UPDATED=()
SKIPPED=()
STALE=()

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

# 🐍 Ensure pyenv has correct Python version
echo -e "\033[1;34m🐍 Ensuring pyenv has Python $PYVER …\033[0m"
pyenv install "$PYVER" -s
pyenv global "$PYVER"

# 🚫 Warn if inside active venv
if [[ -n "${VIRTUAL_ENV:-}" ]]; then
  echo -e "⚠️  \033[31mActive venv detected: $VIRTUAL_ENV — consider deactivating first.\033[0m"
fi

# 🔁 Loop over subdirectories
echo -e "\n\033[1;36m🔁 Scanning Python projects in $ROOT …\033[0m"
echo "────────────────────────────────────────────"

for dir in "$ROOT"/*/; do
  [[ -d "$dir" ]] || continue
  cd "$dir"
  name="$(basename "$dir")"
  [[ -n "$ONLY" && "$name" != "$ONLY" ]] && continue

  if [[ "$FORCE" -eq 0 && ! ( -f requirements.txt || -f pyproject.toml || -f setup.py ) ]]; then
    SKIPPED+=("$name")
    continue
  fi

  NEWVENV=".direnv/${name}${PYSHORT}"

  # Migrate legacy direnv layout
  if [[ -d ".direnv/python-$PYVER" && ! -d "$NEWVENV" ]]; then
    echo -e "♻️  \033[33m$name — migrating from .direnv/python-$PYVER → $NEWVENV\033[0m"
    mv ".direnv/python-$PYVER" "$NEWVENV"
    sed -i.bak "s|layout python .direnv/python-$PYVER|layout python $NEWVENV|" .envrc || true
    rm -f .envrc.bak
    direnv allow || true
  fi

  # Skip if venv already present
  if [[ -d "$NEWVENV" ]]; then
    echo -e "⏭️  \033[2mSkipping $name — $NEWVENV already exists\033[0m"
    SKIPPED+=("$name")
    continue
  fi

  echo -e "\n▶ \033[1mBootstrapping: $name\033[0m"
  if (( DRY )); then
    echo "[dry-run] $HELPER \"$dir\""
  else
    "$HELPER" "$dir"

    # Patch .envrc for named venv
    sed -i.bak "s|.direnv/python-$PYVER|$NEWVENV|g" .envrc || true
    rm -f .envrc.bak
    direnv allow || true

    # Freeze snapshot
    mkdir -p venv-logs
    FREEZE="venv-logs/venv-freeze-$(date +%Y%m%d-%H%M)-${name}${PYSHORT}.log"
    pip freeze > "$FREEZE" || true
    ln -sf "$(basename "$FREEZE")" venv-logs/venv-freeze.log
    cp "$FREEZE" venv-logs/venv-freeze.log.prev

    UPDATED+=("$name")
  fi
done

# 📊 Summary
echo -e "\n📊 \033[1;33mBootstrap Summary\033[0m"
printf "\n%-24s │ %-10s\n" "Project" "Status"
echo "────────────────────────────┼──────────────"
for name in $(printf '%s\n' "${UPDATED[@]}" | sort); do printf "%-24s │ ✅ Updated\n" "$name"; done
for name in $(printf '%s\n' "${SKIPPED[@]}" | sort); do printf "%-24s │ ⏭️  Skipped\n" "$name"; done

# 📜 Append to log
if [[ ${#UPDATED[@]} -gt 0 ]]; then
  {
    echo -e "\n▶ $(date '+%F %T') — Bootstrap completed:"
    for proj in "${UPDATED[@]}"; do
      echo "  • $proj"
    done
  } >> "$LOGFILE"
fi

END=$(date +%s)
echo -e "\n✅ \033[1;32mFinished bootstrapping Python projects with .direnv/<project>${PYSHORT}\033[0m"
echo "⏱ Total time: $((END - START))s"
