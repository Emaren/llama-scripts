#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$PWD/bin"

for PROJECT in ~/projects/*/; do
  # Skip llama-scripts itself
  [[ "$PROJECT" == *llama-scripts* ]] && continue

  # Create bin folder if not exists
  mkdir -p "${PROJECT}bin"

  for FILE in "$SRC_DIR"/*; do
    BASENAME=$(basename "$FILE")
    TARGET="${PROJECT}bin/$BASENAME"

    # Only symlink if not already correct
    if [[ -L "$TARGET" && "$(readlink "$TARGET")" == "$FILE" ]]; then
      continue
    fi

    ln -sf "$FILE" "$TARGET"
    echo "🔗 Linked $BASENAME → ${PROJECT}bin/"
  done
done
