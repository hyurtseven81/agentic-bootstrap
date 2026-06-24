# Setup Prompt — Agentic ML Research Development System

> **Prompt version: v4 (2026-06-24)** — bump on every amendment; cite the lesson or
> incident that motivated it in the commit message.

**How to use:** open an agent session (Claude Code or equivalent, strongest available
model) at the root of your research project — empty or existing — and paste this
entire prompt. The model will inspect the folder, interview you briefly, then build
(or upgrade) a human-in-the-loop agentic research system tailored to *this* project.

This prompt describes **intent and principles, not a fixed file layout**. You (the
model executing it) implement the intent with whatever the current harness offers.
The agentic tooling landscape moves faster than this document — when they disagree,
current capabilities win.

---

## Mission

Set up an agentic development system for complex ML research (recommender systems,
ranking, retrieval, sequence models — any domain where experiments are expensive and
conclusions are subtle). The owner is a human researcher who reads every hand-off and
intervenes — **human-in-the-loop is a design feature, not a limitation to engineer
away.**

The system you build must structurally defend against the three chronic failure modes
of LLM-driven research:

1. **Drift** — the agent gradually loses the locked decisions and the actual problem
   being solved, re-litigates settled questions, or quietly redirects scope.
2. **Premature verdicts** — the agent declares "the baseline is better" or "no
   effect" without the scrutiny it would apply to a win; when the human probes, a
   bug surfaces. Negative results are accepted uncritically because they *feel*
   conservative.
3. **Expensive irreversible waste** — a multi-day training run is invalidated by a
   bug found after the fact, and the agent resets everything instead of salvaging
   what the bug didn't touch.

Every mechanism you install should trace to one of these three. A mechanism that
doesn't defend against a real failure mode is bureaucracy — leave it out.

---

## Step 0 — Reconnaissance (before asking the human anything)

1. **Inspect the folder.** Git history, `CLAUDE.md`/`AGENTS.md`/role files, docs,
   code layout, configs, CI, launcher scripts. Infer: the domain, the stack, the
   compute platform, the scale, how far along the project is.
2. **If an agentic setup already exists** (role files, protocol docs, status/log
   files): **audit it, don't bulldoze it.** Map what exists onto the invariants and
   principles below. Produce a three-column assessment — *keep* (working, leave
   alone), *add* (missing defense against a real failure mode), *prune* (rules that
   never fire, dead files, process that outgrew its purpose). Present the upgrade
   plan to the human for approval, then apply it incrementally, one commit per
   coherent change, preserving git history (`git mv`, never delete-and-recreate).
3. **Check what the harness can actually do right now.** Hooks, subagents, skills,
   persistent memory, MCP servers, background tasks, scheduled check-ins — read the
   current docs or probe the environment. Do not assume this prompt's snapshot of
   capabilities is current. Prefer a mechanical capability (a hook that blocks an
   unsafe launch) over a prose rule (a paragraph asking the agent to please not
   launch) wherever the harness allows it.

## Step 1 — Interview the human (one batch, short)

Ask only what reconnaissance couldn't answer. Typically:

- The research goals, headline metrics, and external baselines (or where they're
  written down).
- Compute platform and the cost/duration threshold above which a run is "expensive"
  (this gates pre-registration and mid-run monitoring).
- The scale ladder: cheap-iteration scale → claim-grade scale → production scale.
- Current phase: exploration / baselines reproduced / paper claims active. This
  calibrates how much enforcement to install on day 1.
- Past pain: what has actually gone wrong on this project before. Their answers
  become the first entries in the anti-pattern register — never pre-populate it
  with guesses.
- Session topology preference (see Step 3) — propose one, let them adjust.

## Step 2 — Hard invariants (non-negotiable; everything else adapts)

These are the floor. The evolution loop (Step 6) may amend any *mechanism*, but a
mechanism change that violates an invariant is rejected regardless of who proposes
it. Keep this list short — its power is that there are few of them.

1. **No unverifiable numbers.** Every reported metric traces to an artifact (file
   path, log line, object-store URI) that another session can open. A number without
   a citation is provisional, always labelled so.
2. **Symmetric scrutiny.** A negative or null result ("baseline wins", "no effect")
   is a claim, and gets the same citation, verification, and spot-checking as a
   claimed win. The most suspicious number in the building is the 0.0% delta on a
   method that should have moved something.
3. **Pre-commitment before expensive or irreversible actions.** Hypothesis, exact
   metric definitions, pass/grey/fail bands, and kill criteria are committed to git
   *before* launch, and the launch references that commit. Editing the prediction
   after seeing the result is the cardinal sin; the audit trail must make it
   detectable.
4. **Append, never rewrite.** Verdicts, decisions, and killed hypotheses are
   invalidated or superseded with dated notations — never edited in place, never
   deleted. A future session must be able to reconstruct *why* the plan evolved.
5. **Bugs invalidate downstream claims — with adjudicated scope.** When a bug is
   found in code that produced reported numbers, those numbers are flagged invalid
   until re-verified. But the *scope* of invalidation is adjudicated (see the salvage
   taxonomy in Step 3), not assumed to be "everything."
6. **Durable state lives in files, not in chat.** Anything the system needs to
   survive a crashed session, a context compaction, or a four-day gap is committed
   to the repo. If a fresh session can't reconstruct the loop state from files
   alone, the state isn't durable.
7. **Mechanical gates beat prose rules.** Anything a script or hook can check — SHA
   equality, file-exists-before-launch, line counts, required fields in a hand-off —
   is enforced by a script or hook, not by a paragraph. Prose is reserved for
   judgment calls.

## Step 3 — Design principles (adapt these to the project; don't copy them blindly)

### Topology — size the roles to the project

The proven pattern for serious projects is a **decider/executor split**: a Lead
session that owns direction, goals, and verdicts (and never runs jobs), and a
Scientist session that develops, launches, and reports (and never edits the Lead's
files) — with the human hand-carrying hand-offs between them as the control gate.
Two read-only reviewer subagents serve the split: a **code reviewer** giving the
executor a pre-hand-off scientific-correctness pass, and a **direction reviewer**
giving the *decider* a goal-alignment pass on its highest-stakes, hard-to-reverse
calls (see *Drift defense*). Neither subagent owns direction; both persist findings
to files keyed to what they reviewed.

But the split must earn its cost. For a solo exploration-phase project, a single
session with the code reviewer plus the invariants may be enough — though the
direction reviewer earns its place the moment the loop runs long experiments whose
local results can capture the agenda (see *Drift defense*); install the two-session
split when claims start carrying weight. Whatever topology you choose: each role's
identity is determined by something mechanical (launch directory, explicit file),
never inferred from conversation; and one writer per file, with an explicit
ownership table, so sessions never clobber each other.

### State files — the minimum durable set

Whatever you name them, the system needs durable homes for: **goals and locked
decisions** (the single source of truth, wins all conflicts — including an explicit
"decisions locked" vs "still open" split so settled questions don't get re-litigated);
**live run state** (enough for a fresh session to recover mid-experiment: config,
checkpoint path, launch SHA, dataset identity, status, with a staleness rule — if the
file says "in progress" but hasn't been touched in 24h, query the compute platform
before believing it); **a verdict log** (append-only, one line per review turn);
**a killed-hypothesis register** (so dead ideas aren't re-tried in six weeks —
summarize the most recent kills in every hand-off); and **curated memory** (distilled
*patterns* — what worked, what didn't, under what conditions — written at phase
boundaries by the decider role, not transcripts of events).

**Hand-offs: separate the carry from the record — they are different problems**, and
conflating them invites bespoke machinery the harness already obviates. *Carrying* the
block into the other session is the harness's job, not yours: have each role emit its
hand-off as a single fenced code block and let the human use the native code-block copy
(the copy button on web/desktop UIs). That is symmetric for free — both roles emit a
block, so neither is "the one that emits a file" while the other "emits chat text" (the
asymmetry that actually confuses people). Do **not** build a custom copy command for
this: a slash command cannot reach the system clipboard except by shelling to
OS-specific tools (`pbcopy`/`xclip`/`clip.exe`) that fail on web and over SSH, so it
either duplicates the native button or breaks — build one only where the harness has no
native affordance (a bare terminal) and a portable clipboard tool exists, and probe
first. *Durability* — surviving a crashed session — is the separate concern, and it is
already carried by the verdict log (the decider's per-turn next-step) and the run-state
file (the executor's latest results): make those entries rich enough that a fresh
session recovers the pending hand-off from them alone. A parallel `handoffs/` file tree
is justified only when they can't — then widen them or keep a lightweight handoff file;
don't stand up a second source of truth by default.

**Review evidence is state too.** Each reviewer's raw findings are persisted to a file
keyed to what it reviewed — the code reviewer to the commit (e.g. `reviews/<sha>.md`),
the direction reviewer to the verdict or amendment it checked — and the hand-off cites
the path. Gates become "review file exists at the cited SHA/id" — mechanically
checkable — instead of a prose `Review: passed` line taken on trust: the decider
checks the code-review file before approving a launch, and the human sees the
direction-review file beside any claim-grade verdict.

### Defense in depth for long runs (failure mode 3)

- **Golden-fixture eval tests before launch.** The eval harness must pass a test
  with a tiny hand-computable dataset and exact expected metric values, green at the
  launch SHA. Most "bug found on day 4" incidents are eval/metric/data bugs that
  this catches on day 0.
- **Smoke-at-scale.** The exact launch config, scaled to minutes, must produce sane
  outputs before the multi-day version launches.
- **Mid-run gates.** Any run over a wall-clock threshold (hours, separate from the
  cost threshold) pre-registers a checkpoint-eval schedule with sanity bands and an
  early-kill rule. A four-day run never gets four days of unexamined trust.
- **Salvage taxonomy on bug discovery.** Eval-code bug → re-eval existing
  checkpoints (hours). Data-pipeline bug → re-run affected arms. Training-code bug →
  full re-run. Logging bug → re-extract. The executor proposes the blast radius with
  evidence; the decider adjudicates *before* anything is deleted or relaunched.
  Checkpoints are expensive evidence — they survive eval bugs.

### Defense against premature verdicts (failure mode 2)

- **Result autopsy before any FAIL/null hand-off:** training curves plausible, eval
  ran on the intended checkpoint (path + step cited), cohort/item counts match the
  data manifest, both arms saw identical eval conditions, metric reproduced through
  a second path or the golden fixture.
- **Win autopsy before any claim-grade PASS** — invariant 2 cuts both ways, and the
  classic false win is leakage. Before a win that would change the plan: temporal
  split boundaries actually respected (no future information reaching features,
  sampling, or eval), no train/eval overlap of the entities the claim generalizes
  over, no duplicates across splits, eval ran on the intended checkpoint, and the
  delta plausible against known baselines. A too-good-to-be-true number is a bug
  hypothesis first, a result second.
- **Crashes are reported as crashes** — never repackaged as results. A truncated
  run's numbers enter the record only labelled "partial, crashed at step N", and a
  partial number never feeds a verdict.
- **Pre-registered failure explanations:** the pre-commitment includes "if this
  FAILs, the three most likely *non-scientific* explanations and the check that
  rules each out" — written at design time, when the model is neutral, not at
  verdict time, when it's anchored.
- **Spot-checks on every verdict-bearing number,** not just large deltas or wins.
  Selection of what to spot-check is deterministic or human-chosen, never "the agent
  picks one at random" (it will pick the easiest).
- **Claims are scale-bound.** A result at iteration scale is evidence at iteration
  scale; it neither promotes nor kills a claim-grade hypothesis. State the scale in
  every verdict.
- **Statistical floor:** multiple seeds for comparative claims, variance reported,
  multiple-comparison correction when comparing many variants, effect size alongside
  significance. Single-seed results always labelled provisional.

### Drift defense (failure mode 1)

- **Bootstrap ritual:** on session start and after any context compaction, each role
  re-reads the state files in a fixed order and states in one line where the loop
  stands before acting.
- **Headline anchor every turn.** The chronic, expensive form of drift is
  *local-result capture*: after a long experiment the decider adopts the sub-result as
  the objective — fixating on one ablation cell ("the model is weak at K=1") while the
  headline claim that ablation was only *serving* (does multi-interest ensembling of the
  upstream embeddings beat the baseline?) slips out of view, and the human has to keep
  steering it back. Defend it structurally: register every experiment with its **role**
  — *headline claim* vs *instrumental-for-G<n>* (an ablation/diagnostic in service of a
  named goal) — and have the decider's every-turn output re-state the headline G-goal it
  is serving and tag the current activity headline vs instrumental. An anchor the agent
  must re-type each turn is far harder to drift past than one buried in a goals file read
  only at bootstrap.
- **Instrumental results can't redirect the headline.** Parallel to *claims are
  scale-bound*: a finding from an instrumental experiment is evidence about a design
  knob, not a license to redefine the problem. A weakness surfaced inside an ablation is
  logged as a side-observation (a new hypothesis — possibly a fresh pre-reg or a
  killed-register entry); it becomes the new objective only through an explicit, dated,
  version-bumped plan amendment that ties it to a G-goal. The verdict on a
  pre-registered experiment answers *its registered question* — wandering off it onto
  whatever the run happened to surface is the named failure.
- **Direction reviewer on verdict and amendment turns.** The decider routes its
  highest-stakes, hard-to-reverse calls — claim-grade PASS, hypothesis kills, plan
  amendments / REDIRECTs, salvage-scope adjudications — past a read-only direction
  reviewer before the hand-off. Its one job is to attack goal-alignment the way the win
  autopsy attacks a win: *does this verdict answer the pre-registered question and serve
  its headline G-goal, or has the loop's center of gravity quietly shifted to a
  sub-result?* Scope it to irreversible calls only — not routine APPROVE / REVISE / WAIT
  turns — so it defends the failure mode without becoming the bureaucracy the rule budget
  forbids. It cannot redirect anything; it flags, persists its finding, and the human
  still decides.
- **Conflict order**, written down: goals doc > plan > scientific validity > human
  preference > agent suggestion. The order arbitrates whose *proposal* wins; it is
  not a license to execute a plan discovered to be scientifically invalid — that
  discovery triggers an amendment proposal, never silent deviation and never silent
  compliance. Plan changes happen only via explicit, dated, version-bumped
  amendments — silent redirection is the named enemy.
- **Periodic retro** (every N review turns or at phase boundaries) that checks
  direction against goals — including an explicit *center-of-gravity* check: is the
  headline G-goal still what the last N turns actually advanced, or did an ablation
  capture the agenda? — plus register health, debt accumulation, and, critically, a
  cumulative-delta sanity check: do the per-experiment deltas reported since the last
  retro sum to the actual movement against the baseline? This is the program-level
  fabrication detector.

### Rule budget — the system must stay small

Every rule in the generated system cites the failure it defends against. The retro
prunes rules that haven't fired and rules whose failure mode the harness now blocks
mechanically. A system whose rule mass only grows becomes the drift it was built to
prevent — instruction-following degrades with the number of simultaneously active
constraints. Target: each role file readable in two minutes, with a short
"every-turn" section up top and everything else as an exception manual.

### Phase calibration

Exploration phase: invariants + reviewer + run-state file; skip pre-registration
ceremony and frozen artifacts. Claims phase: everything. Make the current phase an
explicit line in the system files, and make phase transitions a decider-role
amendment — never silent.

## Step 4 — Build it

Generate the system: a slim root instruction file (bootstrap ritual, invariants,
ownership table, pointers), role files sized per Step 3, the goals doc seeded from
the interview, the state files, a `reviews/` directory (and a `handoffs/` directory
only if you keep durable hand-off files per *State files*), `gates/`
scripts for every mechanically checkable rule (pre-commitment tamper checks, hand-off
field validation — including the headline-vs-instrumental role tag on every experiment
and the headline-G-goal line on every verdict — staleness checks), hooks where the
harness supports them, the code-reviewer and direction-reviewer subagent definitions
(committed in the project, not user-global, so a fresh clone or restarted session has
the whole system from files alone), and memory initialization. Gate scripts belong to the
decider role in the ownership table: the executor never edits a gate to make a turn
pass — weakening a gate is a directional change, exactly like rewriting a test. One
commit per coherent unit, conventional commit messages. Where the project already had
working equivalents, adapt and keep their names — continuity beats uniformity.

## Step 5 — Verify before handing over

- Dry-run each role's bootstrap: can a fresh session reconstruct the loop state from
  files alone? Fix what it can't.
- Run every gate script; each must pass on the clean scaffold and demonstrably fail
  on a violation (test at least one).
- Walk one simulated hand-off round-trip (executor → human → decider → human →
  executor): confirm both directions emit a copy-pasteable fenced block, and that a
  fresh session could recover the pending next-step from the durable records alone.
- Hand the human a summary: what was created, what each gate enforces, what is
  deliberately *not* enforced yet and which phase transition turns it on.

## Step 6 — Install the evolution loop

The system must improve itself as the project and the tooling evolve:

- The periodic retro examines **the system, not just the science**: which rules
  fired, which were ignored (an ignored rule is a design bug — fix the rule or the
  gate, don't blame the agent), what new failure mode appeared. Amendments are
  dated, version-bumped, and cite the incident.
- At each phase boundary, re-check harness capabilities and migrate prose rules to
  mechanical gates when new capability allows.
- When a lesson is project-agnostic, the human backports it to the repo this prompt
  lives in — the prompt itself is versioned and evolves the same way the systems it
  generates do.

---

## Pushbacks you are expected to make

- If the human asks for "no rules, just principles": the invariants exist because
  principles alone are exactly how drift and premature verdicts happen. Offer to
  shrink the mechanism set, never the invariant set.
- If the human asks to skip the human-in-the-loop gate for speed: the hand-carry is
  the control gate that catches what every automated layer misses. Offer to reduce
  *what* requires the gate (more pre-approved categories), not to remove it.
- If the human asks to drop the headline anchor or the direction reviewer as overhead:
  local-result capture is the drift that most often forces a manual course-correction,
  so the check pays for itself. Offer to shorten the anchor to one line or narrow what
  the reviewer fires on — never to remove the goal-alignment check entirely.
- If an existing setup has a rule you'd prune but the human says it once saved them:
  keep it — their incident memory outranks your tidiness.
