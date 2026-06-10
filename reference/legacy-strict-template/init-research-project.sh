#!/usr/bin/env bash
# init-research-project.sh — scaffold a new ML research project from this template.
#
# Lays down:
#   - lead/CLAUDE.md, scientist/CLAUDE.md, repo-root CLAUDE.md
#   - problems.md, RUN_STATUS.md, REVIEW_LOG.md
#   - empty preregs/, tech-debt/, reports/, scripts/, configs/ablations/, docs/
#   - the curated-memory directory under ~/.claude/projects/<key>/memory/
# Substitutes the standard placeholders so the result is ready to commit.
#
# Usage:
#   ./init-research-project.sh \
#     --name "MyProject" \
#     --key  "myproject" \
#     --path /path/to/new-project \
#     [--compute-threshold "\$50"] \
#     [--iteration-scale 100K] \
#     [--paper-scale 10M] \
#     [--production-scale 89M] \
#     [--canonical-config configs/main.yaml] \
#     [--data-catalog-ref ~/.claude/rules/datasets.md] \
#     [--git-init]            # also run `git init` + initial commit
#
# After running:
#   1. Open <path>/problems.md and fill in §1, the goals (G1–G_N), §3 metrics, §6 anti-patterns.
#   2. Open <path>/CLAUDE.md and replace the "What This Is", "Commands", "Architecture",
#      "Critical Invariants", "Datasets", "Compute platform" sections.
#   3. cd <path>/lead && claude  (Lead session)
#      cd <path>/scientist && claude  (Scientist session — separate terminal)

set -euo pipefail

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- defaults
NAME=""
KEY=""
PROJECT_PATH=""
COMPUTE_THRESHOLD='$50'
ITERATION_SCALE="100K"
PAPER_SCALE="10M"
PRODUCTION_SCALE="89M"
CANONICAL_CONFIG="configs/main.yaml"
DATA_CATALOG_REF="(none — describe in problems.md §7)"
DO_GIT_INIT="false"

# --- arg parsing
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)              NAME="$2"; shift 2 ;;
    --key)               KEY="$2"; shift 2 ;;
    --path)              PROJECT_PATH="$2"; shift 2 ;;
    --compute-threshold) COMPUTE_THRESHOLD="$2"; shift 2 ;;
    --iteration-scale)   ITERATION_SCALE="$2"; shift 2 ;;
    --paper-scale)       PAPER_SCALE="$2"; shift 2 ;;
    --production-scale)  PRODUCTION_SCALE="$2"; shift 2 ;;
    --canonical-config)  CANONICAL_CONFIG="$2"; shift 2 ;;
    --data-catalog-ref)  DATA_CATALOG_REF="$2"; shift 2 ;;
    --git-init)          DO_GIT_INIT="true"; shift ;;
    -h|--help)
      sed -n '2,30p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

# --- validation
if [[ -z "$NAME" || -z "$KEY" || -z "$PROJECT_PATH" ]]; then
  echo "Required: --name, --key, --path" >&2
  echo "See $0 --help" >&2
  exit 2
fi

if [[ ! "$KEY" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "--key must be kebab-case (lowercase alnum + hyphens). Got: $KEY" >&2
  exit 2
fi

if [[ -e "$PROJECT_PATH" && -n "$(ls -A "$PROJECT_PATH" 2>/dev/null || true)" ]]; then
  echo "Refusing to scaffold into non-empty path: $PROJECT_PATH" >&2
  echo "Move or empty it first." >&2
  exit 2
fi

MEMORY_PATH="$HOME/.claude/projects/$KEY/memory/"
SCALE_LADDER="$ITERATION_SCALE → $PAPER_SCALE → $PRODUCTION_SCALE"

# --- compute placeholder (escape \ and / for sed)
sed_escape() { printf '%s' "$1" | sed -e 's/[\/&]/\\&/g'; }

NAME_E=$(sed_escape "$NAME")
KEY_E=$(sed_escape "$KEY")
MEM_E=$(sed_escape "$MEMORY_PATH")
COMP_E=$(sed_escape "$COMPUTE_THRESHOLD")
ITER_E=$(sed_escape "$ITERATION_SCALE")
PAPER_E=$(sed_escape "$PAPER_SCALE")
PROD_E=$(sed_escape "$PRODUCTION_SCALE")
LADDER_E=$(sed_escape "$SCALE_LADDER")
CANON_E=$(sed_escape "$CANONICAL_CONFIG")
CATALOG_E=$(sed_escape "$DATA_CATALOG_REF")

# --- layout
echo ">> Creating project at: $PROJECT_PATH"
mkdir -p "$PROJECT_PATH"/{lead,scientist,preregs,tech-debt,reports,scripts,configs/ablations,docs/archive,docs/regsweep,tests}

# --- copy and substitute role files + shared CLAUDE.md
for f in CLAUDE.md lead/CLAUDE.md scientist/CLAUDE.md; do
  cp "$TEMPLATE_DIR/$f" "$PROJECT_PATH/$f"
done

# --- copy templated docs (strip the .template suffix)
cp "$TEMPLATE_DIR/problems.md.template"     "$PROJECT_PATH/problems.md"
cp "$TEMPLATE_DIR/RUN_STATUS.md.template"   "$PROJECT_PATH/RUN_STATUS.md"
cp "$TEMPLATE_DIR/REVIEW_LOG.md.template"   "$PROJECT_PATH/REVIEW_LOG.md"

# --- substitute placeholders in every templated file
TARGETS=(
  "$PROJECT_PATH/CLAUDE.md"
  "$PROJECT_PATH/lead/CLAUDE.md"
  "$PROJECT_PATH/scientist/CLAUDE.md"
  "$PROJECT_PATH/problems.md"
  "$PROJECT_PATH/RUN_STATUS.md"
  "$PROJECT_PATH/REVIEW_LOG.md"
)
for f in "${TARGETS[@]}"; do
  sed -i \
    -e "s|<PROJECT_NAME>|$NAME_E|g" \
    -e "s|<PROJECT_KEY>|$KEY_E|g" \
    -e "s|<MEMORY_PATH>|$MEM_E|g" \
    -e "s|<COMPUTE_THRESHOLD>|$COMP_E|g" \
    -e "s|<ITERATION_SCALE>|$ITER_E|g" \
    -e "s|<PAPER_SCALE>|$PAPER_E|g" \
    -e "s|<PRODUCTION_SCALE>|$PROD_E|g" \
    -e "s|<SCALE_LADDER>|$LADDER_E|g" \
    -e "s|<CANONICAL_CONFIG>|$CANON_E|g" \
    -e "s|<DATA_CATALOG_REF>|$CATALOG_E|g" \
    "$f"
done

# --- gitkeeps for empty dirs (so `git add` picks them up)
for d in preregs tech-debt reports scripts configs/ablations docs/archive docs/regsweep tests; do
  touch "$PROJECT_PATH/$d/.gitkeep"
done

# --- curated memory
mkdir -p "$MEMORY_PATH"
if [[ ! -e "${MEMORY_PATH}MEMORY.md" ]]; then
  cat > "${MEMORY_PATH}MEMORY.md" <<EOF
# $NAME — curated memory index

(Empty. Lead writes patterns here at phase boundaries — what worked, what
didn't, the conditions. One line per memory file: \`- [Title](file.md) — hook\`.)
EOF
fi
echo ">> Curated memory at: $MEMORY_PATH"

# --- reviewer agent existence check
REVIEWER_AGENT="$HOME/.claude/agents/scientific-code-reviewer.md"
if [[ -e "$REVIEWER_AGENT" ]]; then
  echo ">> scientific-code-reviewer found: $REVIEWER_AGENT"
else
  echo "WARNING: $REVIEWER_AGENT not found." >&2
  echo "         The auto-route to scientific-code-reviewer will fail until you place" >&2
  echo "         the agent file there. Copy from a project that has it." >&2
fi

# --- optional git init
if [[ "$DO_GIT_INIT" == "true" ]]; then
  (
    cd "$PROJECT_PATH"
    git init -q
    git add .
    git -c user.useConfigOnly=true commit -q -m "feat(scaffold): two-role protocol from template

Project: $NAME (key: $KEY)
Scale ladder: $SCALE_LADDER
Compute threshold: $COMPUTE_THRESHOLD
Canonical config: $CANONICAL_CONFIG

Files: shared CLAUDE.md, lead/CLAUDE.md, scientist/CLAUDE.md, problems.md
(stub), RUN_STATUS.md (idle), REVIEW_LOG.md (with KILLED-REGISTER header),
empty preregs/, tech-debt/, reports/, scripts/, configs/ablations/, docs/,
tests/. Curated memory initialized at $MEMORY_PATH." \
      || { echo "git commit failed — check user.email / user.name" >&2; exit 1; }
  )
  echo ">> git initialized + initial commit landed"
fi

echo ""
echo "Done. Next steps:"
echo "  1. cd $PROJECT_PATH && \$EDITOR problems.md   # fill in §1, goals, metrics, anti-patterns"
echo "  2. \$EDITOR CLAUDE.md                          # replace project-specific sections"
echo "  3. cd $PROJECT_PATH/lead && claude            # Lead session (separate terminal)"
echo "     cd $PROJECT_PATH/scientist && claude      # Scientist session"
echo ""
echo "  Read $TEMPLATE_DIR/README.md for the porting checklist + phased-adoption notes."
