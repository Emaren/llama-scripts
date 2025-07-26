#!/usr/bin/env bash
# direnv-bootstrap-all.sh — Python 3.13.5 full-project upgrade
# ──────────────────────────────────────────────────────────────
# Replaces layout pyenv with local .direnv/python-3.13 venvs
# for all valid Python projects in ~/projects
# Options:
#   --dry-run        Only print what would happen
#   --force          Bootstrap even if no requirements found
#   --only <project> Only run for that project name

set -euo pipefail
shopt -s nullglob

# ────────────────────────
# ⚙️  Config
# ────────────────────────
PYVER="3.13.5"
PYSHORT="3.13"
ROOT="$HOME/projects"
HELPER="$ROOT/llama-scripts/bin/direnv-bootstrap.sh"

# ────────────────────────
# 🏷️  Flags
# ────────────────────────
DRY=0
FORCE=0
ONLY=""
UPDATED=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)   DRY=1 ;;
    --force)     FORCE=1 ;;
    --only)      shift; ONLY="$1" ;;
    --help|-h)
      echo -e "Usage: direnv-bootstrap-all.sh [--dry-run] [--force] [--only <project>]\n"
      echo "  --dry-run         Show what would be done"
      echo "  --force           Run even if no Python files are detected"
      echo "  --only <project>  Run only on the named project"
      exit 0
      ;;
  esac
  shift
done

# ────────────────────────
# 🐍 Ensure Python is available
# ────────────────────────
echo "🐍 Ensuring pyenv has Python $PYVER …"
pyenv install "$PYVER" -s
pyenv global "$PYVER"

# ────────────────────────
# 🔍 Scan and run
# ────────────────────────
echo "🔁 Scanning for Python projects in $ROOT"
echo "────────────────────────────────────────────"

for dir in "$ROOT"/*/; do
  [[ -d "$dir" ]] || continue
  name="$(basename "$dir")"

  # If --only set and doesn't match, skip
  if [[ -n "$ONLY" && "$name" != "$ONLY" ]]; then
    continue
  fi

  cd "$dir"

  # Skip if already bootstrapped
  if [[ -d .direnv/python-$PYSHORT ]]; then
    echo "⏭️  Skipping $name — already has .direnv/python-$PYSHORT"
    continue
  fi

  # Skip if not a Python project (unless --force)
  if [[ "$FORCE" -eq 0 && ! ( -f requirements.txt || -f pyproject.toml || -f setup.py ) ]]; then
    continue
  fi

  echo "▶ Bootstrapping: $name"
  if (( DRY )); then
    echo "[dry] $HELPER $dir"
  else
    "$HELPER" "$dir"
    UPDATED+=("$name")
  fi

  echo
done

# ────────────────────────
# 📊 Summary
# ────────────────────────
echo "📊 Summary of updated projects:"
if [[ "${#UPDATED[@]}" -eq 0 ]]; then
  echo "  (none)"
else
  for proj in "${UPDATED[@]}"; do
    echo "  • $proj"
  done
fi

echo ""
echo "✅ All applicable Python projects are now bootstrapped with .direnv/python-$PYSHORT"
