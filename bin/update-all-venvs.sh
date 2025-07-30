#!/usr/bin/env bash
# update-all-venvs.sh — Re-bootstrap all Python venvs with per-project naming
# 🐍 Uses Python 3.13.5 via pyenv and logs to venv-logs/venv-freeze-<timestamp>-<project>.log

set -euo pipefail

# ─── CONFIG ─────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOSTNAME_FQDN="$(hostname -f 2>/dev/null || hostname)"
PYTHON_VERSION="3.13.5"
PYSHORT="313"

if [[ "$HOSTNAME_FQDN" == *"wolo"* || -d /var/www ]]; then
  PROJECT_ROOT="/var/www"
else
  PROJECT_ROOT="$HOME/projects"
fi

BOOTSTRAP_ONE="$SCRIPT_DIR/direnv-bootstrap.sh"
REPAIR_SCRIPT="$SCRIPT_DIR/repair-missing-venvs.sh"
MISSING_LOG="$SCRIPT_DIR/venv-missing.log"
LOG_DIR="$PROJECT_ROOT/venv-logs"

mkdir -p "$LOG_DIR"

# ─── SAFETY: Deactivate active venv if present ─────────────────────────
if [[ -n "${VIRTUAL_ENV:-}" ]]; then
  deactivate 2>/dev/null || unset VIRTUAL_ENV
fi

# ─── Ensure Python 3.13.5 is installed via pyenv ───────────────────────
if ! pyenv versions --bare | grep -qx "$PYTHON_VERSION"; then
  echo "📥 Installing Python $PYTHON_VERSION via pyenv..."
  pyenv install "$PYTHON_VERSION"
fi
pyenv global "$PYTHON_VERSION"

# ─── AUTO-REPAIR IF MISSING ────────────────────────────────────────────
if [[ -s "$MISSING_LOG" ]]; then
  echo "🔧 Detected non-empty $MISSING_LOG — repairing missing venvs..."
  bash "$REPAIR_SCRIPT"
fi

# ─── MAIN LOOP ─────────────────────────────────────────────────────────
cd "$PROJECT_ROOT"

for dir in */; do
  repo="${dir%/}"
  path="$PROJECT_ROOT/$repo"
  [[ -d "$path" ]] || continue
  cd "$path"

  # Skip non-Python projects
  if [[ ! -f requirements.txt && ! -f pyproject.toml && ! -f setup.py ]]; then
    echo "⏭️  Skipping $repo — no Python markers"
    continue
  fi

  echo -e "\n📦 \033[1mProcessing: $repo\033[0m"
  bash "$BOOTSTRAP_ONE" "$path"
  direnv allow || true

  VENV_PATH=".direnv/${repo}${PYSHORT}"
  PIP="$VENV_PATH/bin/pip"

  if [[ -x "$PIP" ]]; then
    echo "🚀 Upgrading pip for $repo"
    "$PIP" install --upgrade pip || true

    TIMESTAMP="$(date +'%Y%m%d-%H%M')"
    FREEZE_FILE="$LOG_DIR/venv-freeze-${TIMESTAMP}-${repo}${PYSHORT}.log"
    "$PIP" freeze > "$FREEZE_FILE" || true
    echo "📄 Freeze saved → $FREEZE_FILE"
  else
    echo "❌ pip not found for $repo in $PIP"
  fi
done

echo -e "\n✅ \033[1;32mAll Python venvs have been updated and frozen\033[0m"
