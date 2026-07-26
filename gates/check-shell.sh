#!/usr/bin/env bash
# Gate: every tracked shell script passes a bash syntax check, and shellcheck
# where available. A missing shellcheck is a warning locally and a FAILURE in CI —
# the enforcement claim is checked rather than assumed.
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
elif [[ -n "${CI:-}" ]]; then
  echo "FAIL: shellcheck is not installed on this CI runner — install it or the gate is fiction" >&2
  status=1
else
  echo "WARN: shellcheck not installed — syntax-only pass locally; CI enforces shellcheck" >&2
fi

exit "$status"
