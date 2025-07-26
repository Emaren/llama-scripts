#!/usr/bin/env bash
set -euo pipefail

PROJECTS_DIR="$HOME/projects"
SCRIPT_LINE='export PATH="$PWD/bin:$PATH"'

echo "🔧 Updating .envrc in each project..."

find "$PROJECTS_DIR" -maxdepth 1 -type d | while read -r dir; do
  # Skip the top-level directory itself
  [[ "$dir" == "$PROJECTS_DIR" ]] && continue

  envrc="$dir/.envrc"

  # Skip if not a git repo or not a real project folder
  [[ ! -d "$dir/.git" && ! -f "$dir/package.json" && ! -d "$dir/sanity" ]] && continue

  # Ensure the .envrc file exists
  touch "$envrc"

  # Check if the line is already present
  if grep -Fxq "$SCRIPT_LINE" "$envrc"; then
    echo "✅ $dir/.envrc already contains export line"
  else
    echo "$SCRIPT_LINE" >> "$envrc"
    echo "➕ Added export line to $dir/.envrc"
  fi

  # Run direnv allow
  (cd "$dir" && direnv allow)
done

echo "🎉 Done updating all .envrc files!"
