# CLAUDE.md

This repo is a collection of **setup prompts** for agentic development systems —
see `README.md`. It is not itself a research project, and none of the prompts
govern sessions in this repo.

## Working on this repo

- The deliverables are the prompt files in `prompts/`. They must each be
  **self-contained** — a user pastes one into a session in a *different* project
  folder, so a prompt can never assume this repo's files are present.
- Prompts describe intent and principles, not fixed file layouts. Keep the hard
  invariants short and the mechanism guidance adaptive; instruct the executing
  model to probe current harness capabilities rather than trusting a snapshot.
  Exception: `setup-dev-machine.md` and `setup-claude-code.md` legitimately carry
  fixed personal choices in their SPEC sections — those are the owner's
  preferences, not best-practice claims; don't "modernize" them without the owner
  asking.
- Every prompt has a `Prompt version: vN (date)` header — bump it on any
  amendment and cite the motivating lesson in the commit message.
- `gates/run-all.sh` is this repo's own gate suite (version headers + bump-on-change,
  structural parallel of the system prompts, link resolution + prompt
  self-containment + README index, shellcheck). Run it before committing — pass the
  upstream ref, `gates/run-all.sh origin/main`, since a stale local `main` narrows
  what the bump check can see. The bump check reads the working tree, so it catches
  an unbumped edit before the commit exists. CI runs the same script on every PR.
- When editing the system prompts (`setup-ml-research-system.md`,
  `setup-engineering-system.md`, `setup-autonomous-goal-loop.md`), keep them in
  structural parallel where their content overlaps (recon → interview →
  invariants → principles → build → verify → evolution loop) so lessons can be
  backported across them easily.
- `setup-engineering-system.md` is on probation as of 2026-09-12: every change to it
  so far was a parallel copy of an ML-research lesson. If no engineering-specific
  lesson lands by the next retro, retire it to `reference/` the same way the
  campaign prompt was.
- `kickoff-spec-first-project.md`, `review-plan-blind.md`, and `run-plan-stepwise.md`
  are *workflow* prompts, not system prompts: they run before or beside a system
  rather than building one, so they are deliberately outside the structural-parallel
  gate. Keep the review prompt blind — it may name its kickoff sibling for the human,
  but must never describe what that prompt asked the author to produce: its lenses
  are field standards, not the kickoff's section list. A reviewer that knows the
  rubric grades the rubric.
- `reference/` holds retired prompts, frozen as prior art — don't extend them;
  backport lessons into the live prompts instead. A retirement is a `git mv` into
  `reference/` with a dated note at the top saying why and where the live
  mechanisms went. The original v1 boilerplate was deleted from the tree on
  2026-09-12 and is reachable at the git tag `legacy-strict-template`.
- Conventional commits (`feat(prompts):`, `docs(readme):`, …).
