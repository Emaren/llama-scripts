#!/usr/bin/env bash
set -euo pipefail

# ─── CONFIG ─────────────────────────────────────────────────────────────
LEGACY_PYENV=("llama-chat-api" "llama-chat-app" "llama-api" "llama-dashboard")
USE_PY313=("llama-scripts")  # Add more Py3.13 repos here if needed

BOOTSTRAP_ALL="./llama-scripts/direnv-bootstrap-all.sh"
BOOTSTRAP_ONE="./llama-scripts/direnv-bootstrap.sh"
PROJECT_ROOT="$HOME/projects"

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

echo "✅ All 36 venvs processed!"
