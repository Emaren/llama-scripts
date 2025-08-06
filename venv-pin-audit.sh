#!/usr/bin/env bash
set -euo pipefail

echo "📌 Auditing .envrc and .python-version pins — $(date +%F\ %T)"
echo

find /var/www -maxdepth 2 -type f \( -name ".envrc" -o -name ".python-version" \) | sort | awk -F/ '
  {
    proj = $4;
    file = $5;
    getline val < $0;
    data[proj][file] = val;
  }
  END {
    printf "%-25s │ %-30s │ %-15s\n", "Project", ".envrc", ".python-version";
    print "────────────────────────────────────────────┼────────────────────────────────────────────────┼─────────────────────";
    for (p in data) {
      printf "%-25s │ %-30s │ %-15s\n", p, data[p][".envrc"], data[p][".python-version"];
    }
  }'
