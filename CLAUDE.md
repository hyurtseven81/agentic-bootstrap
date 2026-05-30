# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Operating Protocol — Two Sessions (Lead + Scientist)

**Plan version: v1 (YYYY-MM-DD)** — bump on every amendment to this file; the Lead cites it in each Plan check.

This repo is driven by two separate Claude Code sessions that share these files but not each other's context:

- **Lead Scientist** — reviewer. Launched from `lead/` (`cd lead && claude`), loads `lead/CLAUDE.md`. Validates scientific rigor, decides the next step or WAIT, guards this plan + `problems.md` (and the A1–A_N anti-patterns), writes curated memory. Never runs jobs.
- **Scientist** — developer/runner. Launched from `scientist/` (`cd scientist && claude`), loads `scientist/CLAUDE.md`. Develops, launches compute jobs, analyzes, reports. Never edits the Lead's files.

**Your role is fixed by your launch directory — run `pwd`, never infer it from the conversation.** Each role file (`lead/CLAUDE.md`, `scientist/CLAUDE.md`) is that session's project-root CLAUDE.md and is re-read from disk after `/compact`; this shared file loads in both sessions via parent crawl-up.

**Bootstrap — on session start AND immediately after any `/compact`, before anything else:**
1. `pwd` to confirm role.
2. Re-read as current ground truth, in order: this file → `problems.md` (it wins on any conflict) → `RUN_STATUS.md` → `REVIEW_LOG.md` → the curated memory folder at `<MEMORY_PATH>`.
3. State in one line where the loop stands before acting. If a file looks stale or missing, say so — don't guess.

**File ownership — both sessions can write, but one writer per file to avoid cross-session clobber:**

| File | Writer | Purpose |
|---|---|---|
| `problems.md` | Lead | goals G1–G_N, external baselines, A1–A_N — source of truth |
| this `CLAUDE.md` | Lead | plan amendments (bump Plan version) |
| `REVIEW_LOG.md` | Lead | one line per review turn + KILLED-REGISTER |
| curated memory (`<MEMORY_PATH>`) | Lead | distilled *patterns* (what worked/didn't + conditions), at phase boundaries |
| `RUN_STATUS.md` | Scientist | live run state — config, checkpoint path, launch time, queued, status, dataset manifest, launch SHA, pre-reg SHA |
| `preregs/` | Scientist | sealed pre-registrations for runs > <COMPUTE_THRESHOLD> |
| `reports/` | Scientist | eval / aggregation outputs |
| `scripts/`, `configs/`, `tests/` | Scientist | implementation |
| `tech-debt/` | Scientist | deferred-Medium register (Lead can override sunset) |
| `<PROJECT_KEY>/` (your code package) | Scientist | the importable code |
| `docs/` | Lead | documentation tree |
| `FROZEN.json` next to `_FROZEN_*` artifacts | Scientist | SHA-pinned integrity manifest |

**The human carries the Lead's "Prompt for Scientist" block to the Scientist session by hand — that hand-off is the control gate. All durable state syncs through the files above, not through the model.**

## Read First — `problems.md`

Before designing experiments, planning sweeps, or making architectural recommendations, **read `problems.md`** at the repo root. It is the single source of truth for what <PROJECT_NAME> is for. Every experiment must map to one of its goals (G1–G_N) and beat the **external baselines** it lists. When `problems.md` conflicts with any other doc, `problems.md` wins.

The full goals doc has the metric-to-goal mapping, the external-baselines vs internal-comparator distinction, the scale ladder, all documented anti-patterns A1–A_N, and decision heuristics for any experiment over <COMPUTE_THRESHOLD>.

## What This Is

(Replace this section with a project-specific architecture summary — what we're building, the modules, the data sources, the version-set / package layout. Keep it short — `problems.md` carries the goals; this section just gives a future session enough context to read the rest.)

## Commands

(Replace with project-specific commands — install, test, lint, smoke-test, pipeline launch, etc. Pattern-match on what the project actually uses.)

## Architecture

(Optional — package layout, pipeline stages, key invariants, train/serve interfaces. Anything that helps a future session not break things by accident.)

## Code Conventions

(Replace with project-specific style — Python version, line length, type hints, test framework, conventional-commit scopes, config framework.)

## Operational notes

Operational lessons specific to this project — silent-failure patterns, env-drift gotchas, region settings, IAM quirks. Add as you hit them; don't pre-populate.

A common pattern across ML research projects:
- Silent-failure root causes are usually environment / config drift (region env-var override, optimizer-state mismatch from prior checkpoint vs new optimizer kind, disk pressure during bootstrap), not code logic. **When a launch silently fails — submit returns OK but no job exists, or a "success" status returns suspiciously fast — check env vars, config drift, and region settings BEFORE assuming a code bug.**
- Diagnostic standard for any silent-failure incident: print region values, refute-or-confirm the hypothesis, minimal forensic fix. RCA before retry, not retry-and-instrument-after.

## No-local-runs for evals > 10 min

Any evaluation expected to run longer than ~10 min wall time goes on managed compute (SageMaker ProcessingJob / similar), not local CPU. Local CPU is fine for: single-seed sanity checks, aggregator scripts on existing artifacts, diff/audit work — anything where loss is recoverable.

Cost of managed compute (~$0.6/job × small batches) is negligible vs the operational risk of local-machine state loss during long-running evals (credential expiry mid-loop, session restart killing in-flight work).

## Critical Invariants

(Replace with project-specific invariants. Pattern: list each invariant with one line of reasoning. Examples from other projects: "FAISS uses METRIC_INNER_PRODUCT, towers L2-normalize at loss + serving boundaries"; "topic_user_dist is keyed by training-session position, held-out users derive their dist via the inference helper"; "negative sampler popularity matches logQ correction Q(j) — must stay in sync.")

## Datasets

(Replace with the project's data sources — buckets, glue tables, snapshot conventions, filter rules. Reference <DATA_CATALOG_REF> if a global catalog exists.)

## Compute platform

(Replace with how compute jobs are launched — SageMaker, Slurm, Kubernetes, etc. Include the env-config conventions, the launcher script names, and the resume mechanism for spot interruptions.)
