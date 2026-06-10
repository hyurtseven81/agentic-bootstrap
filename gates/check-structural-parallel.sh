#!/usr/bin/env bash
# Gate: the two system prompts stay in structural parallel (CLAUDE.md rule:
# recon -> interview -> invariants -> principles -> build -> verify -> evolution).
# Compares the top-level `## ` heading skeletons; parenthetical suffixes may
# differ in wording, and `###` subsections are intentionally domain-specific.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

skeleton() { grep '^## ' "$1" | sed -E 's/ *\(.*$//'; }

a=$(skeleton prompts/setup-ml-research-system.md)
b=$(skeleton prompts/setup-engineering-system.md)

if [[ "$a" != "$b" ]]; then
  echo "FAIL: top-level section skeletons of the two system prompts diverged:" >&2
  diff <(printf '%s\n' "$a") <(printf '%s\n' "$b") >&2 || true
  exit 1
fi
