# CLAUDE.md

This repo is a collection of **setup prompts** for agentic development systems —
see `README.md`. It is not itself a research project, and none of the prompts
govern sessions in this repo.

## Working on this repo

- The deliverables are the four prompt files in `prompts/`. They must each be
  **self-contained** — a user pastes one into a session in a *different* project
  folder, so a prompt can never assume this repo's files are present.
- The collection stays at four: one system prompt (`setup-agentic-system.md`), one
  workflow prompt (`plan-review-execute.md`), one blind reviewer
  (`review-plan-blind.md`), one workstation prompt (`setup-workstation.md`). A new
  concern goes into the prompt whose job it serves — as a profile, a stage, or a
  phase — not into a new file. The 2026-09-12 consolidation from eleven prompts to
  four happened because the owner could no longer tell which one to run.
- Prompts describe intent and principles, not fixed file layouts. Keep the hard
  invariants short and the mechanism guidance adaptive; instruct the executing
  model to probe current harness capabilities rather than trusting a snapshot.
  Exception: `setup-workstation.md` legitimately carries fixed personal choices in
  its two SPEC sections — those are the owner's preferences, not best-practice
  claims; don't "modernize" them without the owner asking.
- Every prompt has a `Prompt version: vN (date)` header — bump it on any
  amendment and cite the motivating lesson in the commit message. A merged prompt
  continues the highest version it absorbed, because the bump gate follows renames.
- `gates/run-all.sh` is this repo's own gate suite (version headers + bump-on-change
  with renames followed, link resolution + prompt self-containment + README index,
  shellcheck). Run it before committing — pass the upstream ref,
  `gates/run-all.sh origin/main`, since a stale local `main` narrows what the bump
  check can see. The bump check reads the working tree, so it catches an unbumped
  edit before the commit exists. CI runs the same script on every PR.
- `setup-agentic-system.md` carries three profiles — research, engineering, goal
  loop — on one skeleton (recon → interview → invariants → principles → build →
  verify → evolution loop). A lesson learned in one profile is usually a lesson for
  the others: add it once at the shared level and mark the profile-specific part
  explicitly, rather than copying it per profile.
- `plan-review-execute.md` and `review-plan-blind.md` are *workflow* prompts: they
  run before or beside a system rather than building one. Keep the review prompt
  blind — it may name its workflow sibling for the human, but must never describe
  what that prompt asked the author to produce: its lenses are field standards, not
  the sibling's section list. A reviewer that knows the rubric grades the rubric.
  That is the reason the reviewer stays a separate file instead of a section of the
  workflow prompt.
- `reference/` holds retired prompts, frozen as prior art — don't extend them;
  backport lessons into the live prompts instead. A retirement is a `git mv` into
  `reference/` with a dated note at the top saying why and where the live
  mechanisms went. Prompts absorbed by a merge are not retired and get no
  `reference/` copy: their content lives on in the merged file, and the README
  cites the last commit that carried them separately. The original v1 boilerplate
  was deleted from the tree on 2026-09-12 and is reachable at commit `bcb6304`,
  the last one that carried it.
- Conventional commits (`feat(prompts):`, `docs(readme):`, …).
