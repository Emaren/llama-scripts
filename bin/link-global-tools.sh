#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$HOME/projects/llama-scripts/bin"
DEST_DIR="$HOME/bin"
ZSHRC="$HOME/.zshrc"

# Optional alias map — you can add or remove as you like
declare -A ALIASES=(
  [direnv-bootstrap.sh]=direnv-boost
  [sanity-venv-audit.sh]=sva
  [git-check]=gc
  [git-check-light]=gcl
  [check-users]=cu
  [check-all-users]=cau
)

echo "🔗 Symlinking all scripts from $SRC_DIR → $DEST_DIR"
mkdir -p "$DEST_DIR"

cd "$SRC_DIR"

for FILE in *; do
  # Skip non-regular files or helper dirs
  [[ -d "$FILE" || "$FILE" == *.log || "$FILE" == "sanity.d" || "$FILE" == "repaired-venvs.log" ]] && continue

  TARGET="$DEST_DIR/$FILE"
  SOURCE="$SRC_DIR/$FILE"

  # Only symlink if needed
  if [[ -L "$TARGET" && "$(readlink "$TARGET")" == "$SOURCE" ]]; then
    echo "✅ Already linked: $FILE"
  else
    ln -sf "$SOURCE" "$TARGET"
    echo "🔗 Linked: $FILE → ~/bin/"
  fi

  # Add alias if configured
  if [[ -n "${ALIASES[$FILE]:-}" ]]; then
    SHORT="${ALIASES[$FILE]}"
    if ! grep -q "alias $SHORT=" "$ZSHRC"; then
      echo "alias $SHORT=\"$FILE\"" >> "$ZSHRC"
      echo "🧠 Added alias: $SHORT → $FILE"
    else
      echo "✅ Alias already exists: $SHORT"
    fi
  fi
done

echo "✅ Done. Reload shell or run: source ~/.zshrc"
