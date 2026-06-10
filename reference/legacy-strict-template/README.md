# Two-role research-project protocol — porting template

Generalized operating protocol for any ML research project that benefits from the
Lead-Scientist + Reviewer split. Use this when starting a new project and you want
the same rigor scaffolding (sealed pre-registration, killed-hypothesis register,
retro checklist, frozen-artifact integrity, etc.).

## Files

```
legacy-strict-template/
├── CLAUDE.md                  # repo-root shared rules (loaded by both sessions)
├── lead/CLAUDE.md             # Lead Scientist role file
├── scientist/CLAUDE.md        # Scientist role file
├── problems.md.template       # goals + anti-patterns scaffold (the source of truth)
├── RUN_STATUS.md.template     # empty status file
├── REVIEW_LOG.md.template     # empty review log with KILLED-REGISTER header
└── README.md                  # this file
```

## Sequence to port

**Order matters — `problems.md` first, because the role files cite it constantly.**

1. **Pick the project key.** Lowercase kebab-case (e.g. `myproject`,
   `seq-rec`, `topic-routing`). This becomes the memory path and the slug used
   in commits.

2. **Copy the template into the new project.**
   ```bash
   cp -r legacy-strict-template/{lead,scientist,CLAUDE.md} /path/to/new-project/
   cp legacy-strict-template/problems.md.template /path/to/new-project/problems.md
   cp legacy-strict-template/RUN_STATUS.md.template /path/to/new-project/RUN_STATUS.md
   cp legacy-strict-template/REVIEW_LOG.md.template /path/to/new-project/REVIEW_LOG.md
   mkdir -p /path/to/new-project/{preregs,tech-debt,reports,scripts,configs/ablations,docs}
   ```
   Or use `init-research-project.sh` (see below).

3. **Substitute the placeholders.** All template files use these — search-and-replace
   per project:

   | Placeholder | Meaning | Example |
   |---|---|---|
   | `<PROJECT_NAME>` | Human-readable name | `MyProject` |
   | `<PROJECT_KEY>` | Memory path slug, kebab-case | `myproject` |
   | `<MEMORY_PATH>` | Full memory dir | `~/.claude/projects/myproject/memory/` |
   | `<COMPUTE_THRESHOLD>` | $-amount above which pre-reg required | `$50` |
   | `<ITERATION_SCALE>` | Cheap exploration scale | `100K` |
   | `<PAPER_SCALE>` | Canonical apples-to-apples scale | `10M` |
   | `<PRODUCTION_SCALE>` | Post-paper / A-B scale | `100M` |
   | `<SCALE_LADDER>` | e.g. `100K → 10M → 100M` | same |
   | `<CANONICAL_CONFIG>` | Default-config filename | `configs/main.yaml` |
   | `<DATA_CATALOG_REF>` | Where data sources are catalogued | `(none — describe in problems.md §7)` |
   | `<NUM_GOALS>` | How many G-goals you've defined | `8` |
   | `<NUM_ANTIPATTERNS>` | How many A-anti-patterns | `12` |

   Quick sed (review the diff before committing):
   ```bash
   cd /path/to/new-project
   for f in CLAUDE.md lead/CLAUDE.md scientist/CLAUDE.md problems.md; do
     sed -i \
       -e 's|<PROJECT_NAME>|MyProject|g' \
       -e 's|<PROJECT_KEY>|myproject|g' \
       -e 's|<MEMORY_PATH>|~/.claude/projects/myproject/memory/|g' \
       -e 's|<COMPUTE_THRESHOLD>|\$50|g' \
       "$f"
     # … add more substitutions
   done
   git diff
   ```

4. **Fill in `problems.md`.** The template has G1–G3 stubs; replace with your real
   goals, external baselines, and an empty A-anti-pattern list (you'll add to it as
   you hit anti-patterns in the wild — don't pre-populate guesses).

5. **Initialize curated memory.** Create the directory and a stub MEMORY.md:
   ```bash
   mkdir -p ~/.claude/projects/<PROJECT_KEY>/memory/
   echo "# <PROJECT_NAME> curated memory index" > ~/.claude/projects/<PROJECT_KEY>/memory/MEMORY.md
   ```

6. **Confirm the reviewer agent is available.** It lives globally at
   `~/.claude/agents/scientific-code-reviewer.md` and is project-agnostic — no
   per-project copy needed. Confirm it exists; if not, copy it from a project that
   has it.

7. **Initialize git in the project (if not already), and commit the scaffold:**
   ```bash
   git init && git add . && git commit -m "feat(scaffold): two-role protocol from template"
   ```

## Phased adoption — don't enforce everything Day 1

Some rules earn their cost only at paper-stage. A fresh project doesn't need
sealed pre-regs, frozen artifacts, or scale-bound verdicts on Day 1. Suggested
phasing (you decide which paragraphs to keep / strip / comment-out):

- **Phase 0 (exploration, weeks 1–2):** auto-route to reviewer, local commits,
  dataset manifest, conventional commits. Skip pre-reg, scale-bound verdicts,
  frozen artifacts, retro checklist (no REVIEW_LOG entries to retro yet).
- **Phase 1 (baselines reproduced, ablations starting):** add ≥3-seed rule,
  retroactive-invalidation, anti-fabrication citation, killed-register, retro
  every ~25 entries.
- **Phase 2 (paper claims active):** all rules live — pre-reg gate, GREY-band,
  scale-bound verdicts, frozen artifacts, full retro checklist.

The role files don't gate themselves — comment-out / un-comment as you cross phases.

## Improving the template

When you find a rule that helps on one project, backport it here so the next
project starts with it. The flow:

1. Apply on the project's `lead/CLAUDE.md` or `scientist/CLAUDE.md`.
2. If the rule is project-agnostic, mirror it in the template files.
3. Bump the template's `Plan version` line (one is in the template's shared
   `CLAUDE.md`) so future projects know which template revision they started
   from.

## What's NOT in the template (intentionally)

- Project-specific goals / anti-patterns / scale ladders / config filenames.
- The `scientific-code-reviewer` agent itself (it's already global).
- Memory content (each project has its own).
- `problems.md` body (the template has stubs only).
