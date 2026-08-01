# CLAUDE.md

This repo is a collection of **setup prompts** for agentic development systems —
see `README.md`. It is not itself a research project; the two-session
Lead/Scientist protocol described under `reference/legacy-strict-template/` does
NOT govern sessions in this repo.

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
  `setup-engineering-system.md`, `setup-autonomous-goal-loop.md`,
  `setup-autonomous-research-campaign.md`), keep them in
  structural parallel where their content overlaps (recon → interview →
  invariants → principles → build → verify → evolution loop) so lessons can be
  backported across them easily.
- `reference/legacy-strict-template/` is frozen prior art — don't extend it;
  backport lessons into the prompts instead.
- Conventional commits (`feat(prompts):`, `docs(readme):`, …).
