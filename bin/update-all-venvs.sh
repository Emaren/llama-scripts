#!/usr/bin/env bash
set -euo pipefail

# ─── CONFIG ─────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOSTNAME_FQDN="$(hostname -f 2>/dev/null || hostname)"
PYTHON_VERSION="3.13.5"  # Harmonizing to 3.13.5 for all projects

# Dynamic project root resolution
if [[ "$HOSTNAME_FQDN" == *"wolo"* || -d /var/www ]]; then
  PROJECT_ROOT="/var/www"
else
  PROJECT_ROOT="$HOME/projects"
fi

BOOTSTRAP_ONE="$SCRIPT_DIR/direnv-bootstrap.sh"
BOOTSTRAP_ALL="$SCRIPT_DIR/direnv-bootstrap-all.sh"
REPAIR_SCRIPT="$SCRIPT_DIR/repair-missing-venvs.sh"
MISSING_LOG="$SCRIPT_DIR/venv-missing.log"

# ─── SAFETY: Deactivate active venv if present ─────────────────────────
if [[ -n "${VIRTUAL_ENV:-}" ]]; then
  deactivate 2>/dev/null || unset VIRTUAL_ENV
fi

# ─── Ensure Python 3.13.5 is installed via pyenv ────────────────────────
if ! pyenv versions --bare | grep -qx "$PYTHON_VERSION"; then
  echo "📥 Installing Python $PYTHON_VERSION via pyenv..."
  pyenv install "$PYTHON_VERSION"
fi

# ─── AUTO-REPAIR IF MISSING ────────────────────────────────────────────
if [[ -s "$MISSING_LOG" ]]; then
  echo "🔧 Detected non-empty $MISSING_LOG — repairing missing venvs..."
  bash "$REPAIR_SCRIPT"
fi

# ─── Ensure log directory exists ───────────────────────────────────────
LOG_DIR="$PROJECT_ROOT/venv-logs"
mkdir -p "$LOG_DIR"  # Create venv-logs directory if it doesn't exist

# ─── MAIN VENV BOOTSTRAP LOOP ──────────────────────────────────────────
cd "$PROJECT_ROOT"

for dir in */; do
  repo="${dir%/}"
  path="$PROJECT_ROOT/$repo"
  [[ -d "$path" ]] || continue
  cd "$path"

  echo "📦 Processing: $repo"

  echo "⚙️  Bootstrapping $repo with Python $PYTHON_VERSION"
  bash "$BOOTSTRAP_ONE" "$path"
  direnv allow
  
  # Correcting path to pip under the Python 3.13 environment
  if [[ -x ".direnv/python-3.13/bin/pip" ]]; then
    .direnv/python-3.13/bin/pip install --upgrade pip
  else
    echo "❌ pip not found in .direnv/python-3.13/bin. Skipping pip upgrade."
  fi

  # Save freeze log in the venv-logs folder with timestamp
  FREEZE_LOG="$LOG_DIR/venv-freeze-$(date +'%Y%m%d-%H%M').log"
  .direnv/python-3.13/bin/pip freeze > "$FREEZE_LOG"
  echo "📦 Saved freeze log: $FREEZE_LOG"
done

echo "✅ All venvs processed!"
