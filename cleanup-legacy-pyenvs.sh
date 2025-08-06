#!/usr/bin/env bash
set -euo pipefail

echo "🧹 Starting legacy pyenv cleanup..."

# List of legacy-style pyenv venvs to delete
LEGACY_VENVS=(
  "llamachatapi3.12"
  "llamachatapp3.12"
  "llamaapi3.12"
  "llamadashboard3.12"
  # Add more here if needed
)

for venv in "${LEGACY_VENVS[@]}"; do
  if pyenv versions --bare | grep -q "^$venv$"; then
    echo "🗑  Removing: $venv"
    pyenv uninstall -f "$venv"
  else
    echo "✅ Already gone: $venv"
  fi
done

echo "🎉 Cleanup complete!"
