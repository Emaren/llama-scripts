#!/usr/bin/env bash
# Summarize Python venv info for all ~/projects/*
# Displays: repo, python version, venv type, resolved path
# 💡 Also writes a list of missing venvs to venv-missing.log

set -euo pipefail
shopt -s nullglob

ROOT="$HOME/projects"
OUTFILE="$ROOT/llama-scripts/venv-missing.log"
> "$OUTFILE"

printf "\n📦 Python Venv Audit for %s\n" "$ROOT"
printf "%-24s | %-10s | %-12s | %s\n" "Repo" "Version" "Venv Type" "Python Path"
printf "%s\n" "------------------------+------------+--------------+------------------------------"

for dir in "$ROOT"/*/; do
  repo="$(basename "$dir")"
  cd "$dir" || continue

  PYTHON_BIN=""
  VENV_TYPE="—"
  VERSION="—"

  # 1. Check for .direnv/python-*/bin/python
  if [[ -x ".direnv/python-3.13/bin/python" ]]; then
    PYTHON_BIN="$dir/.direnv/python-3.13/bin/python"
    VENV_TYPE="direnv-local"

  # 2. Fallback: search .direnv just in case
  elif [[ -d ".direnv" ]]; then
    PYTHON_BIN="$(find .direnv -path "*/bin/python" -type f 2>/dev/null | head -n1 || true)"
    if [[ -n "$PYTHON_BIN" && -x "$PYTHON_BIN" ]]; then
      VENV_TYPE="direnv-unknown"
    fi

  # 3. Check for legacy pyenv-based venv
  elif [[ -f .python-version ]]; then
    envname=$(cat .python-version)
    PYTHON_BIN="$(pyenv root)/versions/$envname/bin/python"
    VENV_TYPE="pyenv-layout"
  fi

  # Resolve version
  if [[ -x "$PYTHON_BIN" ]]; then
    VERSION="$("$PYTHON_BIN" -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')"
  else
    PYTHON_BIN="(not found)"
    echo "$repo" >> "$OUTFILE"
  fi

  printf "%-24s | %-10s | %-12s | %s\n" "$repo" "$VERSION" "$VENV_TYPE" "$PYTHON_BIN"
done

echo -e "\n📄 Missing venvs written to: $OUTFILE"
echo "✅ Done. This is a snapshot of venv state across all your repos."
