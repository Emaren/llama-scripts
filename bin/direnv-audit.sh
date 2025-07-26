#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# 🧪 direnv-audit.sh — Audit all Python projects in ~/projects
# Checks:
#   1. .envrc file exists
#   2. .envrc file contains layout or VIRTUAL_ENV reference
#   3. direnv venv exists and is executable
# Also:
#   - Prints aligned results table with emoji status
#   - Lists 10 largest .direnv folders
#   - Logs ❌ summary if any problems found (but does NOT exit 1)
# ──────────────────────────────────────────────────────────────────────────────

ROOT="$HOME/projects"
declare -a size_report
bad_count=0

echo "──────────────────────────────────────────────────────"
echo "📋 Direnv Audit — Checking all Python projects"
echo "📁 Root directory: $ROOT"
echo "──────────────────────────────────────────────────────"
echo ""

printf "%-25s  %-8s  %-10s  %-10s  %-6s\n" "📦 Project" ".envrc" "Valid" "Venv" "Size"
printf "%-25s  %-8s  %-10s  %-10s  %-6s\n" "------------------------" "--------" "----------" "----------" "------"

for dir in "$ROOT"/*/; do
  [[ -d "$dir" ]] || continue
  cd "$dir" || continue

  name=$(basename "$dir")
  envrc="$dir.envrc"
  dvenv="$dir.direnv/python-3.13"

  has_envrc="❌"
  is_valid="❌"
  has_venv="❌"
  size="—"

  [[ -f "$envrc" ]] && has_envrc="✅"
  grep -qE "(VIRTUAL_ENV=|layout python|source venv/bin/activate)" "$envrc" 2>/dev/null && is_valid="✅"

  if [[ -x "$dvenv/bin/python" ]]; then
    has_venv="✅"
    size=$(du -sh "$dvenv" 2>/dev/null | cut -f1)
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
