#!/usr/bin/env bash
# repair-missing-venvs.sh — Regenerate missing venvs from latest venv-missing log
# 🧠 Uses .direnv/<project>313 layout and logs repaired entries

set -euo pipefail

# ─── CONFIG ────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="$(ls -t /tmp/venv-missing-*.log 2>/dev/null | head -n1 || true)"
REPAIRED="$SCRIPT_DIR/repaired-venvs.log"
PYVER="3.13.5"
PYTHON_BIN="$(pyenv root)/versions/3.13.5/bin/python3"
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
  echo "⚠️  $LOG exists but is empty. Nothing to do."
  exit 0
fi

echo "📄 Reading missing entries from: $LOG"

# ─── MAIN REPAIR LOOP ──────────────────────────────────────────────────────────
while read -r dir; do
  [[ -z "$dir" ]] && continue
  echo -e "\n📦 Repairing venv for: $dir"

  TARGET="$PROJECTS_DIR/$dir"
  if [[ ! -d "$TARGET" ]]; then
    echo "❌ Directory not found: $TARGET — skipping"
    continue
  fi
  cd "$TARGET"

  VENV_PATH=".direnv/${dir}${PYSHORT}"
  if [[ $DRY_RUN == true ]]; then
    echo "🔍 DRY RUN: Would create $VENV_PATH"
    continue
  fi

  if [[ ! -d "$VENV_PATH" ]]; then
    echo "🐍 Creating venv in $VENV_PATH"
    "$PYTHON_BIN" -m venv "$VENV_PATH"
  else
    echo "✅ Already exists: $VENV_PATH"
  fi

  # Pin to layout python <named> in .envrc if missing
  if ! grep -q "$VENV_PATH" .envrc 2>/dev/null; then
    echo "📎 Updating .envrc layout → $VENV_PATH"
    echo "layout python $VENV_PATH" > .envrc
  fi

  echo "$dir" >> "$REPAIRED"
  echo "✅ $dir repaired"
done < "$LOG"

# ─── RE-RUN DIRENV ALLOW ACROSS ALL PROJECTS ───────────────────────────────────
echo -e "\n🔁 Rehydrating environments with direnv allow..."
find "$PROJECTS_DIR" -maxdepth 2 -name .envrc -execdir bash -c 'echo "🌱 Allowing: $(pwd)" && direnv allow' \;

# ─── OPTIONAL UPDATE ───────────────────────────────────────────────────────────
if $UPDATE_AFTER && ! $DRY_RUN; then
  echo -e "\n🔁 Running full update-all-venvs.sh after repair..."
  "$SCRIPT_DIR/update-all-venvs.sh"
fi

echo -e "\n🎯 \033[1;32mAll missing venvs repaired.\033[0m"
