#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

# ───── Detect root path ─────
if [[ -d /var/www && "$(hostname)" == "wolo" ]]; then
  ROOT="/var/www"
else
  ROOT="$HOME/projects"
fi

echo "🔧 Fixing venv drift + regenerating requirements.txt in $ROOT/*..."

for d in "$ROOT"/*/; do
  [[ -d "$d" ]] || continue
  cd "$d" || continue

  repo=$(basename "$d")
  VENV=".direnv/python-3.13/bin/python"

  if [[ -x "$VENV" ]]; then
    echo "🛠  Syncing: $repo"

    [[ -f .envrc ]] && direnv allow

    "$VENV" -m pip freeze | tee \
      "venv-freeze-$(date '+%Y%m%d-%H%M').log" \
      "venv-freeze.log" \
      requirements.txt \
      > /dev/null
  else
    echo "⚠️  Skipping $repo — no valid venv found"
  fi
done

echo -e "\n✅ All fixable venvs synced, frozen, and requirements.txt regenerated."
