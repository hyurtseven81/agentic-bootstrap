#!/usr/bin/env bash
# Gate: every file in prompts/ carries a `Prompt version: vN (YYYY-MM-DD)` header,
# and — when a base ref is given — any prompt changed relative to that ref also
# changed its version line (CLAUDE.md: bump the version on any amendment).
#
# Usage: gates/check-prompt-versions.sh [BASE_REF]
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

base="${1:-}"
status=0
header_re='^> \*\*Prompt version: v[0-9]+ \([0-9]{4}-[0-9]{2}-[0-9]{2}\)\*\*'

for f in prompts/*.md; do
  if ! grep -Eq "$header_re" "$f"; then
    echo "FAIL: $f has no '> **Prompt version: vN (YYYY-MM-DD)**' header" >&2
    status=1
  fi
done

if [[ -n "$base" ]]; then
  if ! changed=$(git diff --name-only "$base"...HEAD -- prompts/ 2>&1); then
    echo "FAIL: cannot diff against '$base' (shallow clone?): $changed" >&2
    exit 1
  fi
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    # new files need no bump (header presence is checked above);
    # deleted files have nothing to check
    git cat-file -e "$base:$f" 2>/dev/null || continue
    [[ -f "$f" ]] || continue
    old=$(git show "$base:$f" | grep -E "$header_re" | head -1 || true)
    new=$(grep -E "$header_re" "$f" | head -1 || true)
    if [[ "$old" == "$new" ]]; then
      echo "FAIL: $f changed vs $base but its version header did not: '$new'" >&2
      status=1
    fi
  done <<< "$changed"
fi

exit "$status"
