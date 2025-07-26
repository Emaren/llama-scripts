#!/usr/bin/env bash
set -euo pipefail

# ─── CONFIG ────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS_DIR="$HOME/projects"
LOG="$SCRIPT_DIR/venv-missing.log"
REPAIRED="$SCRIPT_DIR/repaired-venvs.log"
UPDATE_AFTER=false
DRY_RUN=false

echo "🔧 LOG = $LOG"
echo "🔧 PWD = $(pwd)"

# ─── PARSE ARGS ────────────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --also-update|-u) UPDATE_AFTER=true ;;
    --dry-run|-n)     DRY_RUN=true ;;
    *) echo "❌ Unknown argument: $arg" && exit 1 ;;
  esac
done

# ─── VALIDATE LOG ──────────────────────────────────────────────────────────────
if [[ ! -f "$LOG" ]]; then
  echo "❌ Missing venv log not found: $LOG"
  exit 1
fi

if [[ ! -s "$LOG" ]]; then
  echo "⚠️  venv-missing.log exists but is empty. Nothing to do."
  exit 0
fi

# ─── MAIN REPAIR LOOP ──────────────────────────────────────────────────────────
while read -r dir; do
  [[ -z "$dir" ]] && continue

  echo "📦 Repairing venv for: $dir"
  cd "$PROJECTS_DIR/$dir"
  venv_name="${dir//-/_}3.12"

  if $DRY_RUN; then
    echo "🔍 DRY RUN: Would create pyenv virtualenv 3.12.3 $venv_name"
    echo "🔍 DRY RUN: Would write .python-version = $venv_name"
    continue
  fi

  pyenv virtualenv 3.12.3 "$venv_name" || echo "⚠️  Already exists: $venv_name"

  if [[ -f .python-version ]]; then
    current_version=$(<.python-version)
    if [[ "$current_version" != "$venv_name" ]]; then
      echo "⚠️  Mismatch: .python-version in $dir is '$current_version' but should be '$venv_name'"
    fi
  else
    echo "$venv_name" > .python-version
    echo "📝 Wrote .python-version for $dir"
  fi

  echo "$dir" >> "$REPAIRED"
  echo "✅ $dir done"
done < "$LOG"

# ─── OPTIONAL UPDATE ───────────────────────────────────────────────────────────
if $UPDATE_AFTER && ! $DRY_RUN; then
  echo "🔁 Running full update after repair..."
  "$SCRIPT_DIR/update-all-venvs.sh"
fi
