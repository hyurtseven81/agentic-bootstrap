#!/usr/bin/env bash
# Gate: the system prompts stay in structural parallel (CLAUDE.md rule:
# recon -> interview -> invariants -> principles -> build -> verify -> evolution).
# Compares the top-level `## ` heading skeletons; parenthetical suffixes may
# differ in wording, `###` subsections are intentionally domain-specific, and
# headings inside fenced code blocks (file templates) are ignored.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

prompts=(
  prompts/setup-ml-research-system.md
  prompts/setup-engineering-system.md
  prompts/setup-autonomous-goal-loop.md
  prompts/setup-autonomous-research-campaign.md
)

skeleton() {
  awk '/^```/ { fence = !fence; next }
       !fence && /^## / { sub(/ *\(.*$/, ""); print }' "$1"
}

ref=$(skeleton "${prompts[0]}")
status=0
for f in "${prompts[@]:1}"; do
  b=$(skeleton "$f")
  if [[ "$ref" != "$b" ]]; then
    echo "FAIL: top-level section skeleton of $f diverged from ${prompts[0]}:" >&2
    diff <(printf '%s\n' "$ref") <(printf '%s\n' "$b") >&2 || true
    status=1
  fi
done

exit "$status"
