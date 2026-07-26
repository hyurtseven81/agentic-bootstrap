# Preamble — Applying a Setup Prompt to a LIVE Project

> **Prompt version: v4 (2026-07-26)** — bump on every amendment; cite the lesson or
> incident that motivated it in the commit message.

**How to use:** when the target project is already operating — role files in active
use, state files current, possibly an expensive run in flight — open a **fresh**
agent session at the project root, paste this preamble first (editing the bracketed
lines), then paste the full setup prompt (`setup-ml-research-system.md`,
`setup-engineering-system.md`, or `setup-autonomous-goal-loop.md`) below it in the
same message. Do not run the upgrade inside an existing role session.

---

You are being run at the root of a LIVE project, not a fresh one. Read this before
executing the setup prompt that follows; where the two conflict, this preamble wins.

Facts about this project:

- An agentic protocol is already operating here and is in active use.
  [Edit to match, e.g.: "Two-role Lead/Scientist split: `lead/CLAUDE.md` +
  `scientist/CLAUDE.md`, shared root `CLAUDE.md`, `problems.md`, `RUN_STATUS.md`,
  `REVIEW_LOG.md`, `preregs/`, and a code-reviewer subagent."]
- [Edit if true: "An expensive run is IN FLIGHT right now; `RUN_STATUS.md` and
  `REVIEW_LOG.md` are current as of this session."]
- You are a temporary protocol-upgrade session. You hold no role in the existing
  topology: do not write into its decision record — verdicts, hand-offs, ledger
  entries, task-ledger state — and do not launch, modify, or stop any job, run, or
  loop.

Hard constraints for this upgrade:

1. **Audit-and-upgrade only** (the setup prompt's Step 0.2): produce the
   keep/add/prune table and mutate nothing until I approve it.
2. **Do not modify live state or evidence:** e.g. run-status content, review-log
   entries, sealed pre-registrations, ledgers, reports, checkpoints — nor any code
   or config that produces reported numbers. Whatever this project calls them, the
   class is "what the running protocol has already written down." Protocol files,
   role files, gates, and docs only. Decision records (ADRs) reconstructed from the
   project's visible history are docs and may be seeded, but each is marked inferred
   and left for the role that owns direction here to confirm — never assert a
   guessed rationale as fact.
3. **Rename nothing.** Keep every existing file name and convention — continuity
   beats uniformity.
4. **History is sacred.** One commit per coherent change, `git mv` over
   delete-and-recreate, no rebase or amend of existing commits, local commits
   only — never push. In-flight commitments pin to a SHA — a pre-registration to its
   launch SHA, a goal's frozen objective to its manifest hash; nothing you do may
   disturb that audit trail.
5. **New gates and tests are additive.** If a gate or golden-fixture test you add
   exposes a latent bug in existing code, STOP and report it as a finding for the
   role that owns direction here (the human, if the topology has none) — do not fix
   it and do not invalidate anything yourself; the project's existing invalidation
   protocol owns that adjudication.
6. **Defer refactors.** Code improvements you would recommend go into a deferred
   list, to be executed after the in-flight work closes — not now.

Finish by reporting: what changed and why, what each new gate enforces, the
plan-version bump you propose for the root instruction file, and a one-line
append-only log entry for the role that owns direction here (the human, if the
topology has none) to record this upgrade. Any live sessions will be restarted
afterwards so they bootstrap on the amended files.

The setup prompt follows.

---
