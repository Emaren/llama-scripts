#!/usr/bin/env bash
set -euo pipefail

# 🔧 Config
PYVER="3.13.5"
ROOT="$HOME/projects"
TARGET_FILE=".python-version"

echo "🐍 Writing .python-version = $PYVER in all Python projects…"
echo "────────────────────────────────────────────────────────────"

UPDATED=()

for dir in "$ROOT"/*/; do
  [[ -d "$dir" ]] || continue
  name="$(basename "$dir")"

  # Only update if it's a Python project with .envrc or .direnv
  if [[ -f "$dir/.envrc" || -d "$dir/.direnv" ]]; then
    echo "📌 $name"
    echo "$PYVER" > "$dir/$TARGET_FILE"
    UPDATED+=("$name")
  fi
done

echo -e "\n📦 Summary of updated projects:"
for name in "${UPDATED[@]}"; do
  echo "  • $name"
done

echo -e "\n✅ All applicable projects now have a pinned Python version ($PYVER)."
