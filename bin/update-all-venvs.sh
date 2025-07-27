#!/usr/bin/env bash
set -euo pipefail

# ─── CONFIG ─────────────────────────────────────────────────────────────
PROJECT_ROOT="$HOME/projects"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_ONE="$SCRIPT_DIR/direnv-bootstrap.sh"
BOOTSTRAP_ALL="$SCRIPT_DIR/direnv-bootstrap-all.sh"
REPAIR_SCRIPT="$SCRIPT_DIR/repair-missing-venvs.sh"
MISSING_LOG="$SCRIPT_DIR/venv-missing.log"

PY313_REPOS=("llama-scripts")     # Add more if needed
PY312_REPOS=("llama-chat-api" "llama-chat-app" "llama-api" "llama-dashboard")

# ─── AUTO-REPAIR IF MISSING ────────────────────────────────────────────
if [[ -s "$MISSING_LOG" ]]; then
  echo "🔧 Detected non-empty $MISSING_LOG — repairing missing venvs..."
  bash "$REPAIR_SCRIPT"
fi

# ─── MAIN VENV BOOTSTRAP LOOP ──────────────────────────────────────────
cd "$PROJECT_ROOT"

for dir in */; do
  repo="${dir%/}"
  echo "📦 Processing: $repo"

  cd "$PROJECT_ROOT/$repo"

  if [[ " ${PY313_REPOS[*]} " =~ " ${repo} " ]]; then
    echo "⚙️  Bootstrapping $repo with Python 3.13"
    bash "$BOOTSTRAP_ONE" "$repo"
    direnv allow
    if [[ -x .direnv/python-3.13/bin/pip ]]; then
      .direnv/python-3.13/bin/pip install --upgrade pip
    fi
    continue
  fi

  if [[ " ${PY312_REPOS[*]} " =~ " ${repo} " ]]; then
    echo "⚙️  Bootstrapping $repo with Python 3.12.3"
    bash "$BOOTSTRAP_ALL" "$repo"
    direnv allow
    if [[ -x .direnv/python-3.12.3/bin/pip ]]; then
      .direnv/python-3.12.3/bin/pip install --upgrade pip
    fi
    continue
  fi

  echo "⚠️  Skipping untagged repo: $repo"
done

echo "✅ All venvs processed!"
