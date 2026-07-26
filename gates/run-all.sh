#!/usr/bin/env bash
# Run every repo gate. Usage: gates/run-all.sh [BASE_REF]
#
# BASE_REF (arg or env): a git ref to diff against for the version-bump check —
# CI passes the PR base SHA; locally pass the upstream branch, e.g. `origin/main`
# (a stale local `main` silently narrows what the check can see). Without it, only
# the static checks run. The version-bump check reads the WORKING TREE, so running
# this before committing catches an unbumped edit while it is still uncommitted.
# CI runs the same script.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

base="${1:-${BASE_REF:-}}"
fail=0

run() {
  echo "== $* =="
  if "$@"; then
    echo "   PASS"
  else
    echo "   FAIL"
    fail=1
  fi
}

if [[ -n "$base" ]]; then
  run gates/check-prompt-versions.sh "$base"
else
  run gates/check-prompt-versions.sh
fi
run gates/check-structural-parallel.sh
run gates/check-internal-links.sh
run gates/check-shell.sh

if [[ "$fail" -ne 0 ]]; then
  echo "gates: FAILED" >&2
fi
exit "$fail"
