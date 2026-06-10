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
- When editing a prompt, keep the two in structural parallel where their content
  overlaps (recon → interview → invariants → principles → build → verify →
  evolution loop) so lessons can be backported across them easily.
- `reference/legacy-strict-template/` is frozen prior art — don't extend it;
  backport lessons into the prompts instead.
- Conventional commits (`feat(prompts):`, `docs(readme):`, …).
