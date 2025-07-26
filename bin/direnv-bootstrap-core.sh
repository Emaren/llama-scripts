#!/usr/bin/env bash
# direnv-bootstrap-core.sh — Elite per-project venv setup

set -euo pipefail
dir="$1"
PYSHORT="3.13"
cd "$dir"

project="$(basename "$dir")"
echo -e "\n▶ \033[1mBootstrapping: $project\033[0m"
echo "────────────────────────────────────────────"

# Phase 1: .envrc + direnv
echo -e "\n🔧 [1/6] Writing .envrc"
echo "layout python" > .envrc
direnv allow .

# Phase 2: Create venv
echo -e "\n🐍 [2/6] Creating venv → .direnv/python-$PYSHORT"
python -m venv ".direnv/python-$PYSHORT"

# Phase 3: Activate
echo -e "\n✅ [3/6] Activating venv"
source ".direnv/python-$PYSHORT/bin/activate"

# Phase 4: Install deps
echo -e "\n📦 [4/6] Installing dependencies"
if [[ -f requirements.txt ]]; then
  echo "   • Found requirements.txt"
  pip install -r requirements.txt | tee "venv-pip-install.log"
elif [[ -f pyproject.toml ]]; then
  echo "   • Found pyproject.toml"
  pip install . | tee "venv-pip-install.log"
else
  echo "   • No install files found — skipping"
fi

# Phase 5: Freeze snapshot
echo -e "\n📌 [5/6] Freezing environment snapshot"
pip freeze > "venv-freeze-$(date +%Y%m%d-%H%M).log"

# Phase 6: Summary
echo -e "\n📊 [6/6] Final Environment Summary"
echo "   • Python:   $(python --version)"
echo "   • Venv:     .direnv/python-$PYSHORT"
echo "   • Path:     $(which python)"
echo "   • Site:     $(python -m site --user-site)"
echo "   • Packages: $(pip list | wc -l) total"
