#!/usr/bin/env bash
set -euo pipefail

# ─── CONFIG ────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="$(ls -t /tmp/venv-missing-*.log 2>/dev/null | head -n1 || true)"
REPAIRED="$SCRIPT_DIR/repaired-venvs.log"
PYSHORT="3.13"
PYTHON_BIN="$(command -v python${PYSHORT} || true)"
UPDATE_AFTER=false
DRY_RUN=false

# ─── DETECT ENVIRONMENT ────────────────────────────────────────────────────────
if [[ -d "/var/www" ]]; then
  PROJECTS_DIR="/var/www"
  echo "🌐 Detected VPS — using PROJECTS_DIR=$PROJECTS_DIR"
else
  PROJECTS_DIR="$HOME/projects"
  echo "💻 Detected Local Mac — using PROJECTS_DIR=$PROJECTS_DIR"
fi

echo "🔧 LOG = $LOG"
echo "🔧 PWD = $(pwd)"

# ─── CHECK PYTHON ──────────────────────────────────────────────────────────────
if [[ -z "$PYTHON_BIN" ]]; then
  echo "❌ Python $PYSHORT not found. Try: brew install python@$PYSHORT"
  exit 1
fi

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

  TARGET="$PROJECTS_DIR/$dir"
  if [[ ! -d "$TARGET" ]]; then
    echo "❌ Directory not found: $TARGET — skipping"
    continue
  fi
  cd "$TARGET"

  VENV_DIR=".direnv/python-3.13.5"

  if [[ $DRY_RUN == true ]]; then
    echo "🔍 DRY RUN: Would create $VENV_DIR"
    continue
  fi

  if [[ ! -d "$VENV_DIR" ]]; then
    echo "🐍 Creating venv in $VENV_DIR"
    "$PYTHON_BIN" -m venv "$VENV_DIR"
  fi

  echo "$dir" >> "$REPAIRED"
  echo "✅ $dir done"
done < "$LOG"

# ─── RE-RUN DIRENV ALLOW ACROSS ALL PROJECTS ───────────────────────────────────
echo "🔁 Rehydrating venvs by direnv allow…"
find "$PROJECTS_DIR" -maxdepth 2 -name .envrc -execdir bash -c 'echo "🌱 Allowing: $(pwd)" && direnv allow' \;

# ─── OPTIONAL UPDATE ───────────────────────────────────────────────────────────
if $UPDATE_AFTER && ! $DRY_RUN; then
  echo "🔁 Running full update after repair..."
  "$SCRIPT_DIR/update-all-venvs.sh"
fi
