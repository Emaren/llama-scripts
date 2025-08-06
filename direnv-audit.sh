#!/usr/bin/env bash
# 🧪 direnv-audit.sh — Audit all Python projects and their venv setup under ~/projects or /var/www
# ──────────────────────────────────────────────────────────────────────────────

set -euo pipefail
shopt -s nullglob

if [[ "$(hostname)" == "wolo" || -d /var/www ]]; then
  ROOT="${1:-/var/www}"
else
  ROOT="${1:-$HOME/projects}"
fi

declare -a size_report
bad_count=0

# ─── Check dependencies ───
if ! command -v direnv >/dev/null 2>&1; then
  echo "❌ Error: direnv not found in PATH"
  exit 1
fi

echo "──────────────────────────────────────────────────────"
echo "📋 Direnv Audit — Checking all Python projects"
echo "📁 Root directory: $ROOT"
echo "──────────────────────────────────────────────────────"
echo ""

printf "%-25s  %-8s  %-10s  %-10s  %-6s\n" "📦 Project" ".envrc" "Valid" "Venv" "Size"
printf "%-25s  %-8s  %-10s  %-10s  %-6s\n" "------------------------" "--------" "----------" "----------" "------"

for dir in "$ROOT"/*/; do
  [[ -d "$dir" ]] || continue
  name=$(basename "$dir")
  cd "$dir" || continue

  envrc="$dir.envrc"
  has_envrc="❌"
  is_valid="❌"
  has_venv="❌"
  size="—"

  # ─── Check .envrc existence ───
  [[ -f "$envrc" ]] && has_envrc="✅"

  # ─── Check .envrc contents ───
  if grep -qE "(layout python|source .*/activate|VIRTUAL_ENV=)" "$envrc" 2>/dev/null; then
    is_valid="✅"
  fi

  # ─── Detect .direnv/* venv folder ───
  venv_dir=$(find "$dir/.direnv" -maxdepth 1 -type d \( -name "${name}313" -o -name "python-3.*" \) 2>/dev/null | head -n1)

  if [[ -n "$venv_dir" && -x "$venv_dir/bin/python" ]]; then
    has_venv="✅"
    size=$(du -sh "$venv_dir" 2>/dev/null | cut -f1)
    size_report+=("$size|$name")
  fi

  [[ "$has_envrc" == "❌" || "$is_valid" == "❌" || "$has_venv" == "❌" ]] && ((bad_count++))

  printf "%-25s  %-8s  %-10s  %-10s  (%s)\n" "$name" "$has_envrc" "$is_valid" "$has_venv" "$size"
done

echo ""
echo "🔥 Top 10 Largest .direnv folders:"
printf "%s\n" "${size_report[@]}" | sort -hr | head -10 | awk -F'|' '{ printf "  %2d. %-22s → %s\n", NR, $2, $1 }'

echo ""
if (( bad_count > 0 )); then
  echo "🚨 WARNING: $bad_count project(s) had ❌ issues with .envrc or venv setup."
else
  echo "✅ All projects passed direnv + venv audit."
fi
