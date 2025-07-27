#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

echo "🔧 Fixing venv drift + regenerating requirements.txt in ~/projects/*..."

for d in ~/projects/*/; do
  [[ -d "$d" ]] || continue
  cd "$d" || continue

  VENV=".direnv/python-3.13/bin/python"
  if [[ -x "$VENV" ]]; then
    echo "🛠  Syncing: $(basename "$d")"
    direnv allow

    # Freeze to canonical log, timestamped log, and regenerate requirements.txt
    "$VENV" -m pip freeze | tee \
      "venv-freeze-$(date '+%Y%m%d-%H%M').log" \
      "venv-freeze.log" \
      requirements.txt \
      > /dev/null
  else
    echo "⚠️  Skipping $(basename "$d") — no valid venv found"
  fi
done

echo -e "\n✅ All fixable venvs synced, frozen, and requirements.txt regenerated."
