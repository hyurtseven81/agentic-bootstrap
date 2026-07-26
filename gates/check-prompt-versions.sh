#!/usr/bin/env bash
# Gate: every file in prompts/ carries a `Prompt version: vN (YYYY-MM-DD)` header,
# and — when a base ref is given — any prompt changed relative to that ref also
# ADVANCED its version (CLAUDE.md: bump the version on any amendment).
#
# "Changed" spans committed history AND the working tree, so the pre-commit run
# CLAUDE.md prescribes (`gates/run-all.sh main`) catches an unbumped edit while it
# is still fixable. Both sides are read at the MERGE BASE, so a branch that has
# not caught up with main is judged on its own changes, not on main's.
#
# "Advanced" means the version number strictly increases and the date does not go
# backwards — a whitespace touch, a date-only edit, or a version regression is not
# a bump. Renames are followed, so `git mv` + rewrite cannot slip through.
#
# Usage: gates/check-prompt-versions.sh [BASE_REF]
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

base="${1:-}"
status=0
header_re='^> \*\*Prompt version: v[0-9]+ \([0-9]{4}-[0-9]{2}-[0-9]{2}\)\*\*'

for f in prompts/*.md; do
  if ! grep -Eq "$header_re" "$f"; then
    echo "FAIL: $f has no '> **Prompt version: vN (YYYY-MM-DD)**' header" >&2
    status=1
  fi
done

[[ -n "$base" ]] || exit "$status"

if ! mb=$(git merge-base "$base" HEAD 2>&1); then
  echo "FAIL: cannot find a merge base with '$base' (shallow clone?): $mb" >&2
  exit 1
fi

# new path -> the path its OLD header is read from at the merge base
declare -A oldpath=()

# Committed changes since the merge base. --find-renames so a `git mv` is still
# compared against the content it came from; A/D need no version check (the
# header-presence loop above owns new files, deletions have nothing to check).
while IFS=$'\t' read -r st a b; do
  [[ -n "${st:-}" ]] || continue
  case "$st" in
    A* | D*) continue ;;
    R*) oldpath["$b"]="$a" ;;
    *) oldpath["$a"]="$a" ;;
  esac
done < <(git diff --name-status --find-renames "$mb" HEAD -- prompts/)

# Uncommitted changes, staged and unstaged, so the gate is useful BEFORE the
# commit exists. Untracked files appear in neither diff, which is correct: a
# brand-new prompt needs a header, not a bump.
while IFS= read -r f; do
  [[ -n "$f" && -f "$f" ]] || continue
  [[ -n "${oldpath[$f]+set}" ]] && continue
  git cat-file -e "$mb:$f" 2>/dev/null && oldpath["$f"]="$f"
done < <(git diff --name-only HEAD -- prompts/; git diff --cached --name-only -- prompts/)

version_of() { sed -E 's/.*Prompt version: v([0-9]+) .*/\1/' <<<"$1"; }
date_of() { sed -E 's/.*Prompt version: v[0-9]+ \(([0-9-]+)\).*/\1/' <<<"$1"; }

for f in "${!oldpath[@]}"; do
  old=$(git show "$mb:${oldpath[$f]}" 2>/dev/null | grep -E "$header_re" | head -1)
  # No header at the base: the file just gained one, and presence is all we ask.
  [[ -n "$old" ]] || continue
  new=$(grep -E "$header_re" "$f" | head -1)
  [[ -n "$new" ]] || continue  # missing header already reported above

  old_v=$(version_of "$old"); new_v=$(version_of "$new")
  old_d=$(date_of "$old"); new_d=$(date_of "$new")

  if (( 10#$new_v == 10#$old_v )); then
    echo "FAIL: $f changed vs $base but its version did not advance: still v$new_v" >&2
    status=1
  elif (( 10#$new_v < 10#$old_v )); then
    echo "FAIL: $f version went backwards: v$old_v -> v$new_v" >&2
    status=1
  elif [[ "$new_d" < "$old_d" ]]; then
    echo "FAIL: $f bumped to v$new_v but its date went backwards: $old_d -> $new_d" >&2
    status=1
  fi
done

exit "$status"
