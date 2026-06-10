#!/usr/bin/env bash
# Gate: every tracked shell script passes a bash syntax check, and shellcheck
# where available (CI always has it; locally it warns loudly if missing).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

status=0
while IFS= read -r s; do
  [[ -z "$s" ]] && continue
  if ! bash -n "$s"; then
    echo "FAIL: bash syntax error in $s" >&2
    status=1
  fi
done < <(git ls-files '*.sh')

if command -v shellcheck >/dev/null 2>&1; then
  if ! git ls-files '*.sh' | xargs shellcheck; then
    status=1
  fi
else
  echo "WARN: shellcheck not installed — syntax-only pass locally; CI enforces shellcheck" >&2
fi

exit "$status"
