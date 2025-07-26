#!/usr/bin/env bash
set -euo pipefail

SRC_DIRS=("scripts" "tools")      # Source folders
DEST_DIR="$HOME/projects/llama-scripts/bin"
LINK_DIR="$HOME/.local/bin"

mkdir -p "$DEST_DIR" "$LINK_DIR"

function kebabify() {
  local name="$1"
  name="${name%.*}"                             # Strip extension
  echo "$name" | tr '_' '-' | tr '[:upper:]' '[:lower:]'
}

function detect_shebang() {
  head -n 1 "$1" | grep -qE '^#!'
}

for src in "${SRC_DIRS[@]}"; do
  [ -d "$src" ] || continue
  find "$src" -maxdepth 1 -type f | while read -r file; do
    base="$(basename "$file")"
    name="$(kebabify "$base")"
    dest="$DEST_DIR/$name"

    cp "$file" "$dest"

    # Add shebang if missing
    if ! detect_shebang "$dest"; then
      if [[ "$file" == *.py ]]; then
        sed -i '' '1i\
#!/usr/bin/env python3
' "$dest"
      else
        sed -i '' '1i\
#!/usr/bin/env bash
' "$dest"
      fi
    fi

    chmod +x "$dest"
    ln -sf "$dest" "$LINK_DIR/$name"
    echo "✅ Normalized and linked: $name"
  done
done
