#!/usr/bin/env bash
set -euo pipefail

# ─── CONFIG ─────────────────────────────────────────────────────────────
LEGACY_PYENV=("llama-chat-api" "llama-chat-app" "llama-api" "llama-dashboard")
USE_PY313=("llama-scripts")  # Add more Py3.13 repos here if needed

BOOTSTRAP_ALL="./direnv-bootstrap-all.sh"
BOOTSTRAP_ONE="./direnv-bootstrap.sh"
REPAIR_SCRIPT="./repair-missing-venvs.sh"
MISSING_LOG="./venv-missing.log"
PROJECT_ROOT="$HOME/projects"

# ─── OPTIONAL AUTO-REPAIR ──────────────────────────────────────────────
if [[ -s "$MISSING_LOG" ]]; then
  echo "🔧 Detected non-empty $MISSING_LOG — repairing missing venvs..."
  bash "$REPAIR_SCRIPT"
fi

# ─── MAIN LOOP ──────────────────────────────────────────────────────────
cd "$PROJECT_ROOT"
for dir in */ ; do
  repo="${dir%/}"

  echo "📦 Processing: $repo"

  # ── Skip legacy layout:pyenv repos
  if [[ " ${LEGACY_PYENV[*]} " =~ " ${repo} " ]]; then
    echo "⏭  Skipping legacy pyenv repo ($repo)"
    continue
  fi

  # ── Run Py 3.13 bootstrap for specific repos
  if [[ " ${USE_PY313[*]} " =~ " ${repo} " ]]; then
    echo "⚙️  Bootstrapping with Py 3.13 for $repo"
    bash "$BOOTSTRAP_ONE" "$repo"
    (
      cd "$repo"
      direnv allow
      if [[ -x .direnv/python-3.13/bin/pip ]]; then
        .direnv/python-3.13/bin/pip install --upgrade pip
      fi
    )
    continue
  fi

  # ── Bulk-bootstrap (Py 3.12.3)
  echo "⚙️  Bulk bootstrapping Py 3.12.3 for $repo"
  bash "$BOOTSTRAP_ALL" "$repo"
  (
    cd "$repo"
    direnv allow
    if [[ -x .direnv/python-3.12.3/bin/pip ]]; then
      .direnv/python-3.12.3/bin/pip install --upgrade pip
    fi
  )
done

echo "✅ All venvs processed!"
