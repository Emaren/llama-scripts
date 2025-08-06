#!/usr/bin/env bash
set -euo pipefail

# ─── CONFIG ─────────────────────────────────────────────────────
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── SYMLINK ALL FILES TO OTHER PROJECTS' bin/ FOLDERS ─────────
for PROJECT in ~/projects/*/; do
  # Skip this script's own directory (llama-scripts)
  [[ "$PROJECT" == *llama-scripts* ]] && continue

  DEST_BIN="${PROJECT}bin"
  mkdir -p "$DEST_BIN"

  for FILE in "$SRC_DIR"/*; do
    BASENAME="$(basename "$FILE")"
    TARGET="$DEST_BIN/$BASENAME"

    # Skip if the symlink already exists and is correct
    if [[ -L "$TARGET" && "$(readlink "$TARGET")" == "$FILE" ]]; then
      continue
    fi

    ln -sf "$FILE" "$TARGET"
    echo "🔗 Linked $BASENAME → $DEST_BIN/"
  done
done
