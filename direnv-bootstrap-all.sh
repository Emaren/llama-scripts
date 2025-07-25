#!/usr/bin/env bash
# Bootstraps pyenv + direnv + layout pyenv venvs for all valid Python projects

set -euo pipefail
shopt -s nullglob

DRY=0
[[ "${1:-}" == "--dry-run" ]] && DRY=1

PYVER="3.12.3"
ROOT="$HOME/projects"
SNAPSHOT="$ROOT/llama-scripts/LLAMA_SNAPSHOT.md"
HELPER="$ROOT/llama-scripts/direnv-bootstrap.sh"

echo "🔧 Bootstrapping Python $PYVER virtualenvs across ~/projects..."
echo "───────────────────────────────────────────────────────────────"

for dir in "$ROOT"/*/; do
  [[ -d "$dir" ]] || continue
  cd "$dir"

  # Only touch actual Python projects
  if [[ -f requirements.txt || -f pyproject.toml || -f setup.py ]]; then
    name="$(basename "$dir")"
    env="${name//[^a-zA-Z0-9]}${PYVER//./}"  # llama-chat-api → llamachatapi312

    echo "▶ $name  →  venv: $env"

    # Create pyenv virtualenv if missing
    if ! pyenv versions --bare | grep -qx "$env"; then
      (( DRY )) && echo "[dry] pyenv virtualenv $PYVER $env" || pyenv virtualenv "$PYVER" "$env"
    fi

    # Write .python-version and .envrc
    (( DRY )) && {
      echo "[dry] echo \"$env\" > .python-version"
      echo "[dry] echo 'layout pyenv' > .envrc"
    } || {
      echo "$env" > .python-version
      echo 'layout pyenv' > .envrc
    }

    # direnv allow
    (( DRY )) && echo "[dry] direnv allow ." || direnv allow . >/dev/null

    # Symlink helpful tools
    [[ -e LLAMA_SNAPSHOT.md ]] || ln -s "$SNAPSHOT" LLAMA_SNAPSHOT.md
    [[ -e direnv-bootstrap.sh ]] || ln -s "$HELPER" direnv-bootstrap.sh

    # Show resolved Python path
    if [[ -f .python-version ]]; then
      vpath="$(pyenv root)/versions/$env/bin/python"
      [[ -x "$vpath" ]] && echo "🐍 Python path: $vpath"
    fi

    echo "✅ $name ready."
    echo
  fi
done

echo "🏁 All detected Python projects are now harmonized."
