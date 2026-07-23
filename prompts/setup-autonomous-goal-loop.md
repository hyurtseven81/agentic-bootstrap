# Setup Prompt — Autonomous Goal-Loop Engineering System

> **Prompt version: v2 (2026-07-23)** — bump on every amendment; cite the lesson or
> incident that motivated it in the commit message.

**How to use:** open an agent session (Claude Code or equivalent, strongest available
model) at the root of your project — empty or existing — and paste this entire
prompt. The model will inspect the folder, interview you briefly, then build (or
upgrade) an autonomous goal-loop system tailored to *this* project: the human
defines a goal via a `/goal` command, and the agent iterates
Plan → Implement → Verify → Evaluate → Critique → Decide **without waiting for
human turns**, until the goal's success criteria pass, a budget is exhausted, or an
escalation trigger fires.

Scope: this is a **sibling of `setup-ml-research-system.md`, not a replacement**.
That prompt keeps a human in the loop deliberately — verdict discipline is its
design feature. This one removes the human from the inner loop, which is only safe
when success is mechanically verifiable. Apply the autonomy test (see Mission)
before anything else, and re-apply it per goal.

This prompt describes **intent and principles, not a fixed file layout**. You (the
model executing it) implement the intent with whatever the current harness offers —
hooks, subagents, background tasks, memory. The tooling landscape moves faster than
this document; when they disagree, current capabilities win.

---

## Mission

Set up an autonomous goal-loop system: goals are defined once by the human, then
pursued in unattended iterations until a mechanical stop condition fires. The
gate that decides which goals may run this way is the

**Autonomy test.** Is every success criterion checkable by a script that exits 0/1
against artifacts the agent cannot corrupt? If yes → this system. If any criterion
is a research claim ("A beats B and we understand why", "this effect is real"),
route that goal to the Lead/Scientist system of `setup-ml-research-system.md` —
autonomous loops optimize proxies, and research conclusions are the easiest proxies
to game.

A goal like "risk–coverage AUGRC on the frozen eval split improves ≥X% over the
committed baseline, harness hash unchanged, tests green, run reproducible from a
clean checkout" passes the test. "Find the best architecture" does not.

The system you build must structurally defend against the chronic failure modes of
unattended loops:

1. **Objective gaming.** With no human reading intermediate results, the loop
   optimizes whatever is measured — edits the harness, peeks at eval labels, or
   games the metric instead of improving the thing the metric stands for.
2. **Silent scope drift.** Over many iterations the goal quietly mutates into
   whatever turned out to be achievable; the completion claim answers a different
   question than the one the human asked.
3. **Fabricated or untraceable success.** A completion claim cites numbers that no
   artifact backs, or artifacts a later session cannot reproduce.
4. **Runaway spend and thrash.** Hours of iterations with no measurable progress,
   or expensive/irreversible actions taken mid-loop with nobody watching.

Every mechanism you install should trace to one of these. A mechanism that doesn't
defend against a real failure mode is bureaucracy — leave it out.

## Step 0 — Reconnaissance (before asking the human anything)

1. **Inspect the folder.** Git history, `CLAUDE.md`/`AGENTS.md`/role files, existing
   commands, gates, CI, state files, the evaluation code and where its data lives.
   Infer: the domain, the stack, how far along the project is, and whether an
   objective function already exists.
2. **If an agentic setup already exists, audit it — don't bulldoze it.** Map what
   exists onto the invariants and principles below. Produce a *keep / add / prune*
   assessment, present the upgrade plan for approval, then apply incrementally —
   one commit per coherent change, preserving history. Continuity beats
   uniformity: keep working names and conventions.
3. **Probe current harness capabilities** — hooks, subagents, background tasks,
   scheduled runs, memory, tool-permission configuration (needed for eval-label
   sequestration, invariant 2). Prefer a mechanical gate over a prose rule
   wherever possible. Do not assume this prompt's capability snapshot is current.

## Step 1 — Interview the human (one batch, short)

Ask only what reconnaissance couldn't answer, then propose a plan for approval:

- **Domain & verifiability** — what do goals look like here, and what fraction pass
  the autonomy test? (If less than half, recommend the ML-research system as
  primary and this one as secondary.)
- **Objective function** — is there (or will there be) a frozen evaluation harness
  whose outputs define success? Where do its inputs and labels live?
- **Budgets** — default per-goal caps: max iterations, wall-clock, external spend
  (e.g. SageMaker $). What's the escalation channel when caps hit?
- **Blast radius** — what can the agent do without approval (local runs, cheap
  cloud jobs) vs. what needs pre-commitment in the ledger first (jobs above a cost
  threshold, schema migrations, anything irreversible)?
- **Topology** — single looping agent with a Critic subagent (default), or full
  Planner/Engineer/Critic split? Prefer the default unless iterations are long
  enough that role isolation pays for its coordination cost.

## Step 2 — Hard invariants (non-negotiable; everything else adapts)

The floor — never adapted away. The evolution loop (Step 6) may amend any
mechanism, but never below this line. Keep the list short — its power is that
there are few of them.

1. **Anti-fabrication.** Every metric cited in the ledger or a goal-completion
   claim must be traceable to a harness-produced artifact (path + hash). No number
   appears in prose that does not exist in an artifact.
2. **Frozen-harness supremacy.** Only the evaluation harness writes metrics. The
   eval split and its labels are hash-locked at goal start
   (`harness/MANIFEST.sha256`); the loop's Verify step re-checks the hash every
   iteration. Agents never read eval labels — sequester them (a separate directory
   the agent's tools are configured not to read, or an S3 prefix the runtime role
   can't `GetObject`). Changes to harness code end the autonomous loop and require
   human approval — this is the one file-class with a human gate, because it is
   the objective function.
3. **Append-only ledger.** One entry per iteration in `ledger/LEDGER.md`:
   timestamp, plan, diff summary, gate results, harness metrics (with artifact
   hashes), critic verdict, decision. Never edited retroactively. The ledger is
   also the agent's cross-iteration memory: start each iteration with a fresh
   context that reads goal + ledger tail, rather than letting one context rot
   across the whole goal.
4. **Goal immutability.** `goals/GOAL-NNN.md` is written once by `/goal` and
   amended only via an explicit versioned amendment block (date, reason, what
   changed). Silent scope drift is the primary failure mode of long loops; the
   diff between goal v1 and vN must tell that story honestly.
5. **Pre-commitment before expensive/irreversible actions.** Above the interview's
   cost threshold, the ledger entry declaring the action, its cost estimate, and
   its expected outcome must exist before the action runs.
6. **Budget caps are mechanical.** Iteration count, wall-clock, and spend are
   checked by the loop scaffolding (a gate script, not prose). Exhaustion → stop +
   escalation summary, never "one more try".
7. **Escalate, don't thrash.** No measurable improvement on any success criterion
   for N consecutive iterations (default N=3) → stop, write an escalation summary
   (what was tried, why it failed, options), hand to human.

## Step 3 — Design principles (adapt to the project; don't copy blindly)

### Topology — one loop, one adversary

Default: a single looping agent plus a read-only **Critic** subagent that runs the
adversarial pass of every iteration. Install the full Planner/Engineer/Critic
split only when iterations are long enough that role isolation pays for its
coordination cost (interview answer). Whatever the topology: the Critic never
edits the code it critiques, and the harness is owned by no agent at all
(invariant 2).

### The `/goal` command

`/goal <one-line objective>` interviews briefly if needed, then writes
`goals/GOAL-NNN-<slug>.md`:

```markdown
# GOAL-NNN: <objective>            <!-- Goal version: 1 -->
## Success criteria (ALL must pass; each is executable)
- [ ] SC1: `make harness` → metrics.json: <metric> <op> <threshold>   (cmd, artifact, threshold)
- [ ] SC2: `make test` exits 0
- [ ] SC3: reproducibility: clean checkout + `make repro-GOAL-NNN` reproduces SC1 within <tolerance>
## Constraints            <!-- do-not-touch paths, style, latency/cost ceilings -->
## Budget                 <!-- max_iterations / max_wallclock / max_spend_usd -->
## Escalation triggers    <!-- stuck-N, invariant breach, ambiguity discovered -->
## Amendments             <!-- versioned, dated, reasoned; empty at v1 -->
```

`/goal` must refuse to finalize a goal that fails the autonomy test, and say which
criterion is the problem.

Companion commands: `/loop` (run iterations until a stop condition — the normal
mode), `/step` (exactly one iteration, for supervised warm-up), `/status` (goal,
criteria state, budget consumed, ledger tail).

### Hybrid operation with the sibling systems

When a project runs this system alongside the Lead/Scientist system of
`setup-ml-research-system.md`, a research hypothesis ("architecture X beats
baseline Y under condition Z") decomposes across the pair: the claim itself is
pre-registered and adjudicated there, and only its autonomy-test-passing
subgoals — reproduce the baseline within tolerance, implement X with the golden
fixture green, push a pre-registered metric past a threshold on the frozen
split — run here as `/goal` loops. Two rules keep the seam honest:

- **A goal serving a claim says so.** The GOAL file names the pre-registration
  it serves (e.g. a `Serves:` line with the pre-reg id or path), so the ledger
  and any completion claim tie back to the question the loop is actually
  serving.
- **Loop outcomes are evidence, never verdicts.** `done` on a threshold goal
  enters the research loop as an executor result subject to its win autopsy —
  it does not by itself validate the claim. An escalation or exhausted budget
  establishes "stalled under this budget," never "not achievable" — refuting a
  hypothesis is a human-gated verdict under the research system's symmetric
  scrutiny, owned by its decider role.

The same seam exists with `setup-engineering-system.md`, where it fires more
often — spec'd acceptance checks are usually mechanical ("suite green,"
"endpoint per spec S with contract tests passing, no undeclared contract
diff"). There the GOAL file names the spec it serves, that system's gates and
tests play the frozen-harness role (never weakened or rewritten to make an
iteration pass), and its human gates survive delegation: the completed loop's
diff still goes through its review loop, the human still decides what merges,
and spec changes, contract changes, and destructive actions end the loop and
escalate rather than run unattended.

Sibling references are pointers for the human, not files to read: each sibling
is a separate, self-contained setup prompt from the same collection this one
came from, installed by pasting it into its own session at this project root —
whichever prompt runs second finds the first's system during reconnaissance and
integrates with it (audit, don't bulldoze). Never assume a sibling's file is
present in the project.

### The iteration protocol

Each iteration, in order — a checklist the ledger entry mirrors:

1. **Orient** — fresh context reads the GOAL file + ledger tail + `/status`.
2. **Plan** — smallest step with a predicted effect on a named criterion. Written
   to the ledger *before* implementation (pre-commitment, cheap form).
3. **Implement** — code/config changes only; never harness, never eval data.
4. **Gate** — mechanical checks: lint, tests, harness-manifest hash, budget. Any
   red → fix or escalate; never proceed on red.
5. **Evaluate** — run the frozen harness; metrics land in a versioned artifact.
6. **Critique** — adversarial pass (Critic subagent by default) with a fixed
   checklist: Did the diff touch harness/eval paths? Is the improvement
   suspiciously large or suspiciously cheap? Could it come from leakage,
   train/eval overlap, or metric gaming rather than the planned mechanism? Did
   any non-target criterion regress? The Critic has read-only access.
7. **Decide** — `done` (all criteria green → run the final verification: clean
   checkout, re-run everything, confirm; only then mark complete), `continue`
   (next iteration), or `escalate`.
8. **Ledger append.**

### Rule budget — the system must stay small

Every rule cites the failure mode it defends against. The retro (Step 6) prunes
gates that never fire. The invariants plus the iteration checklist should fit in
the always-loaded context and be readable in two minutes — an unattended loop has
no human to compensate for an instruction set it has stopped following.

## Step 4 — Build it

Generate the system, in this order:

1. Directory scaffold: `goals/`, `ledger/`, `gates/` (budget + manifest + test
   runners), the `/goal`, `/loop`, `/step`, `/status` commands
   (`.claude/commands/{goal,loop,step,status}.md` or the harness's current
   equivalent), the Critic subagent definition (committed in the project, not
   user-global, so a fresh clone has the whole system), and a CLAUDE.md section
   wiring the invariants into the harness's always-loaded context.
2. A `gates/run-all.sh` the loop calls in step 4 of every iteration — exit codes,
   no prose.
3. The harness manifest and eval-label sequestration per invariant 2 — hash-lock
   the eval split at goal start, and configure the sequestration mechanism the
   harness actually supports (tool permissions, directory exclusion, or IAM).

Weakening a gate is a directional change requiring explicit human sign-off,
exactly like editing the harness — never a side effect of making an iteration
pass. One commit per coherent unit, conventional messages. Where the project
already had working equivalents, adapt and keep their names.

## Step 5 — Verify before handing over

- Run every gate; each must pass on the clean scaffold and demonstrably fail on a
  violation (test at least one — e.g. touch a harness file and confirm the
  manifest gate goes red).
- Run a smoke goal (`GOAL-000`) that exercises the whole loop on something trivial
  (e.g. "make a failing test pass") to verify the machinery — commands, gates,
  ledger, Critic, stop conditions — before real work.
- Dry-run orientation: confirm a fresh context can reconstruct the loop state from
  the GOAL file + ledger tail alone. Fix what it can't.
- Hand the human a summary: what was created, what each gate enforces, the exact
  stop conditions, and what is deliberately *not* enforced yet.

## Step 6 — Install the evolution loop

- On goal completion or escalation, run a retro: which invariants fired, which
  gates never fired (prune candidates), what new failure mode appeared (gate
  candidate). Amend the generated system with a dated version bump.
- At each goal boundary, re-check harness capabilities and migrate prose rules to
  mechanical gates when new capability allows.
- Backport project-agnostic lessons to the repo this prompt lives in, citing the
  incident, per that repo's standing rule — the prompt is versioned and evolves
  the same way the systems it generates do.

---

## Pushbacks you are expected to make

- If the human wants a research-claim goal run autonomously ("just let it find the
  best model overnight"): apply the autonomy test out loud and refuse. Offer the
  split instead — the mechanically verifiable subgoal runs here, the claim goes to
  the Lead/Scientist system.
- If the human asks to let the loop "just quickly fix" the harness mid-goal: that
  is the one human gate, because the harness is the objective function. Offer to
  end the loop, amend the harness together, re-baseline, and restart the goal.
- If the human asks for uncapped budgets ("whatever it takes"): caps are
  mechanical or they are fiction. Offer larger caps with an escalation summary at
  exhaustion — never cap removal.
- If fewer than half of the project's real goals pass the autonomy test: recommend
  the ML-research system as primary and this one as secondary — don't install an
  autonomous loop as the default where it can't be the default.
