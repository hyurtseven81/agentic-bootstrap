#!/usr/bin/env bash
# Gate: every relative markdown link in tracked .md files resolves to a file
# that exists (relative to the linking file, falling back to the repo root).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

status=0
while IFS= read -r f; do
  while IFS= read -r link; do
    [[ -z "$link" ]] && continue
    case "$link" in
      http://* | https://* | mailto:* | \#*) continue ;;
    esac
    target="${link%%#*}"
    [[ -z "$target" ]] && continue
    dir=$(dirname "$f")
    if [[ ! -e "$dir/$target" && ! -e "$target" ]]; then
      echo "FAIL: $f links to missing file: ($link)" >&2
      status=1
    fi
  done < <(grep -oE '\]\([^)]+\)' "$f" | sed -E 's/^\]\(//; s/\)$//')
done < <(git ls-files '*.md')

exit "$status"
