#!/usr/bin/env bash
# Gate: markdown cross-references actually resolve, and the collection's
# self-containment rule (CLAUDE.md) holds mechanically.
#
# Three checks:
#   1. Every relative markdown link in a tracked .md file resolves to a file that
#      exists, relative to the LINKING FILE's directory. There is deliberately no
#      repo-root fallback: it would let `prompts/x.md` link `README.md` and pass,
#      which is exactly the violation check 2 exists to catch.
#   2. No file in prompts/ contains a relative link at all. A prompt is pasted
#      alone into someone else's project, where nothing this repo ships exists —
#      sibling prompts are named in prose, never linked.
#   3. Every prompt is reachable from README.md, the collection's only index.
#      A prompt nothing points at is a prompt nobody runs.
#
# Links inside fenced code blocks are ignored — those are file templates the
# generated system writes, not references into this repo.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

status=0

# Emit "<line>:<target>" for each relative link outside a fenced code block.
links_in() {
  awk '/^[[:space:]]*```/ { fence = !fence; next }
       !fence {
         line = $0
         while (match(line, /\]\([^)]+\)/)) {
           t = substr(line, RSTART + 2, RLENGTH - 3)
           line = substr(line, RSTART + RLENGTH)
           sub(/[[:space:]].*$/, "", t)          # drop a link title
           if (t ~ /^(https?:\/\/|mailto:|#)/) continue
           sub(/#.*$/, "", t)                    # drop an anchor
           if (t == "") continue
           print NR ":" t
         }
       }' "$1"
}

while IFS= read -r f; do
  dir=$(dirname "$f")
  while IFS= read -r hit; do
    [[ -n "$hit" ]] || continue
    n="${hit%%:*}"
    target="${hit#*:}"
    if [[ "$f" == prompts/* ]]; then
      echo "FAIL: $f:$n links to '$target' — prompts must be self-contained (name siblings in prose, never link them)" >&2
      status=1
    elif [[ ! -f "$dir/$target" ]]; then
      echo "FAIL: $f:$n links to missing file: ($target)" >&2
      status=1
    fi
  done < <(links_in "$f")
done < <(git ls-files '*.md')

for p in prompts/*.md; do
  if ! grep -qF "$(basename "$p")" README.md; then
    echo "FAIL: $p is not referenced from README.md — the collection's only index" >&2
    status=1
  fi
done

exit "$status"
