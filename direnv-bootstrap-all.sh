#!/usr/bin/env bash
# Scan ~/projects for python repos and bootstrap pyenv+direnv

PYVER="3.12.3"                          # <-- change here if you upgrade
ROOT="$HOME/projects"

shopt -s nullglob

for dir in "$ROOT"/*/; do
  [[ -d "$dir" ]] || continue
  cd "$dir" || continue

  # Heuristic: treat as python repo if we see any of these
  if [[ -f requirements.txt || -f pyproject.toml || -f setup.py ]]; then
    name="$(basename "$dir")"
    env="${name//[^a-zA-Z0-9]}${PYVER%.*}"   # e.g. llama-chat-api → llamachatapi311
    printf "▶ %s  →  %s\n" "$name" "$env"

    # create env if missing
    if ! pyenv versions --bare | grep -qx "$env"; then
      pyenv virtualenv "$PYVER" "$env"
    fi

    # write markers
    echo "$env" > .python-version
    echo 'layout pyenv' > .envrc

    # direnv allow (non-interactive)
    direnv allow . >/dev/null
  fi
done
