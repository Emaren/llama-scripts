#!/usr/bin/env bash
set -euo pipefail

# ───────────────────────────────
# 💡 Usage: ./direnv-bootstrap.sh /absolute/path/to/project
# ───────────────────────────────

PROJECT_DIR="${1:-$(pwd)}"
PYTHON_VERSION="3.13"
PYTHON_BIN="$(command -v python3.13 || true)"

if [[ -z "$PYTHON_BIN" || ! -x "$PYTHON_BIN" ]]; then
  echo "❌ Python $PYTHON_VERSION not found. Install it via:"
  echo "   brew install python@$PYTHON_VERSION"
  exit 1
fi

cd "$PROJECT_DIR"
echo "🔧 Setting up direnv in $PROJECT_DIR ..."

# Create .envrc with explicit layout
echo "layout python python-$PYTHON_VERSION" > .envrc
direnv allow

# Create the venv if not already present
if [[ ! -d ".direnv/python-$PYTHON_VERSION" ]]; then
  echo "🐍 Creating .direnv/python-$PYTHON_VERSION ..."
  "$PYTHON_BIN" -m venv ".direnv/python-$PYTHON_VERSION"
else
  echo "✅ Existing venv found."
fi

# Ensure .gitignore exists and includes necessary entries
touch .gitignore
grep -qxF '.envrc'     .gitignore || echo '.envrc'     >> .gitignore
grep -qxF '.direnv/'   .gitignore || echo '.direnv/'   >> .gitignore

# Activate the environment temporarily to upgrade pip
source ".direnv/python-$PYTHON_VERSION/bin/activate"
echo "🚀 Upgrading pip ..."
pip install --upgrade pip

echo "✅ Done. Python: $(which python)"

