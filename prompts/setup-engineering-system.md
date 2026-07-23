# Setup Prompt — Agentic Engineering Development System

> **Prompt version: v6 (2026-07-23)** — bump on every amendment; cite the lesson or
> incident that motivated it in the commit message.

**How to use:** open an agent session (Claude Code or equivalent, strongest available
model) at the root of your software project — empty or existing — and paste this
entire prompt. The model will inspect the repo, interview you briefly, then build
(or upgrade) an agentic engineering system tailored to *this* project.

Scope: standard product engineering — CMS, ERP, SaaS, internal tools — spanning
backend, frontend, APIs (REST/GraphQL), gRPC services, databases, and infrastructure.
For ML *research* projects (experiments, training runs, claims), use the companion
prompt `setup-ml-research-system.md` instead; a product that merely *embeds* a model
behind an API belongs here.

This prompt describes **intent and principles, not a fixed file layout**. You (the
model executing it) implement the intent with whatever the current harness offers —
hooks, subagents, skills, memory, MCP. The tooling landscape moves faster than this
document; when they disagree, current capabilities win.

---

## Mission

Set up an agentic development system for building real software with a human owner
in the loop. The system must structurally defend against the chronic failure modes
of LLM-driven engineering:

1. **Unverified "it works".** The agent declares a feature done without running it;
   tests pass because they test the wrong thing; the demo path works but the error
   paths were never exercised.
2. **Drift from decisions.** Architectural choices get silently re-made, API
   contracts mutate without versioning, the agent re-litigates settled stack
   decisions, scope creeps one helpful refactor at a time.
3. **Context decay across sessions.** A fresh session doesn't know why the code is
   shaped the way it is, re-introduces a bug that was fixed before, or builds a
   second implementation of something that already exists.
4. **Irreversible damage.** Destructive migrations, deleted data, force-pushes,
   breaking API changes shipped to consumers — executed confidently because nothing
   gated them.

Every mechanism you install should trace to one of these. A mechanism that doesn't
defend against a real failure mode is bureaucracy — leave it out.

---

## Step 0 — Reconnaissance (before asking the human anything)

1. **Inspect the repo.** Detect the stack: manifests (`package.json`, `go.mod`,
   `pyproject.toml`, …), proto/OpenAPI files, migration directories, Docker/compose,
   CI config, existing tests and their coverage shape, monorepo vs polyrepo layout,
   existing `CLAUDE.md`/`AGENTS.md`/docs.
2. **If an agentic setup already exists, audit it — don't bulldoze it.** Map what
   exists onto the invariants and principles below. Produce a *keep / add / prune*
   assessment, present the upgrade plan for approval, then apply incrementally —
   one commit per coherent change, preserving history (`git mv`, never
   delete-and-recreate). Continuity beats uniformity: keep working names and
   conventions even when they differ from this prompt's vocabulary.
3. **Probe current harness capabilities** — hooks, subagents, background tasks,
   skills, memory, CI integration, MCP servers. Prefer a mechanical gate (a hook
   that blocks a destructive command) over a prose rule wherever possible. Do not
   assume this prompt's capability snapshot is current.

## Step 1 — Interview the human (one batch, short)

Ask only what reconnaissance couldn't answer. Typically:

- Product domain and the shape of the system (services, clients, integrations).
- Quality bar and risk profile: prototype, internal tool, or production with real
  users/data? This calibrates how much enforcement to install on day 1.
- Deployment reality: where it runs, how it ships, what CI exists or should.
- Contract consumers: who depends on the APIs/schemas (mobile apps, third parties,
  other teams)? This decides how strict contract versioning must be.
- Past pain: what has actually gone wrong on this project or the human's previous
  ones. Their answers seed the anti-pattern register — never pre-populate guesses.
- Session topology preference (see Step 3) — propose one, let them adjust.

## Step 2 — Hard invariants (non-negotiable; everything else adapts)

The floor. The evolution loop (Step 6) may amend any mechanism, but never below
this line. Keep the list short — its power is that there are few of them.

1. **"Done" means demonstrated.** A feature is complete only when its behavior has
   been exercised — tests run and passing, or the app actually driven through the
   path — with the evidence (test output, run log) cited in the report. "Should
   work" is never a completion claim.
2. **Contracts are versioned sources of truth.** API schemas, proto files, DB
   schemas, and public interfaces change only through explicit, versioned,
   reviewed edits — never as a side effect of an implementation task. Breaking
   changes are flagged to the human before they land.
3. **Destructive and irreversible actions are gated.** Data-losing migrations,
   deletions of non-generated files, force-pushes, production deploys, dependency
   major-bumps: require an explicit human go, or a pre-approved category the human
   defined. When in doubt, it's destructive.
4. **Decisions are recorded, append-only.** Significant choices (architecture,
   stack, contract design, security tradeoffs) get a dated decision record with
   the *why* and the alternatives rejected. Superseded decisions are marked
   superseded, never deleted — a future session must be able to reconstruct why
   the code is shaped this way.
5. **Durable state lives in files, not chat.** Task state, decisions, known
   issues, and conventions survive any session loss. If a fresh session can't
   pick up the work from the repo alone, the state isn't durable.
6. **Mechanical gates beat prose rules.** Anything checkable by script, hook, or
   CI — lint, types, tests, contract diffs, migration safety, secret scanning —
   is enforced there, not by a paragraph asking the agent to be careful. Prose is
   reserved for judgment calls.
7. **Report failures faithfully.** Failing tests, skipped steps, and partial work
   are reported as exactly that, with output — never rounded up to success.

## Step 3 — Design principles (adapt to the project; don't copy blindly)

### Topology — size the roles to the project

Default for most projects: **one implementer session + a read-only reviewer
subagent** that reviews every substantive diff before the human sees it, plus the
gates. Add a **planner/architect split** (a session that owns specs, contracts, and
decision records and reviews direction, separate from the implementing session)
when the project has multiple services, external contract consumers, or more than
one workstream in flight. For monorepos with parallel work, multiple implementer
sessions are fine *only* with explicit ownership boundaries (one writer per
package/service) written into the system files. Whatever the topology: role
identity is mechanical (launch directory or explicit file), never inferred from
conversation.

### Spec-first, thin slices

Non-trivial work starts from a short written spec — the user-visible behavior, the
contract changes, the acceptance checks — agreed before implementation. Keep specs
small and ship in thin vertical slices (one endpoint end-to-end beats three layers
of scaffolding). The spec lives in the repo and the implementation cites it. For
bug fixes: reproduce first, fix second, regression-test third — a fix without a
failing-then-passing test is provisional.

### Delegating tasks to an autonomous goal loop

This prompt has a sibling, `setup-autonomous-goal-loop.md`, for goals whose
every success criterion is checkable by a script exiting 0/1 against artifacts
the agent cannot corrupt (its "autonomy test"). Engineering work passes that
test more often than research does — "the failing suite is green," "endpoint
implemented per spec S: contract tests pass, no undeclared contract diff,
lint/types green" — and where both systems are installed, such tasks may run
there as unattended loops instead of attended sessions. The seam rules: the
GOAL file names the spec it serves, so the loop optimizes the agreed acceptance
checks rather than a proxy of its own choosing; the gates and tests play the
frozen-harness role — the loop never weakens a gate or rewrites a test to make
an iteration pass, both directional changes requiring explicit human sign-off;
a completed loop's diff still enters the review loop and the human still
decides what merges; and the human gates survive delegation — spec agreement,
contract changes, and destructive actions (invariants 2–3) stay outside the
loop, so a goal that turns out to need one mid-loop escalates instead.

### The durable state set

Whatever you name them, the system needs: a **conventions file** (the slim root
instruction file: stack, commands, style, bootstrap ritual, ownership table);
**decision records / ADRs** (append-only, dated: the decision, why, rejected
alternatives, status [accepted / superseded-by-#N], and what would reverse it — one
file per architecturally-significant, hard-to-reverse choice, referenced from specs and
the task ledger rather than restated); a **task
ledger** (what's in flight, what's blocked, what's next — granular enough that a
fresh session can resume mid-feature, with a staleness rule: an in-progress entry no
session has touched recently is reconciled against reality — branch, diff, CI state —
before being believed); **specs** for non-trivial features; a
**known-issues / anti-pattern register** seeded from the human's past pain and
appended to when something actually bites. Memory, if the harness provides it,
stores distilled *patterns* (what approach worked, what to avoid and why), not
event transcripts.

When the topology has a split (a planner/architect session feeding an implementer),
separate the *carry* from the *record*. Carry: have each session emit its hand-off as
a fenced code block and use the harness's native code-block copy (the copy button on
web/desktop) — symmetric in both directions, so neither session is "the one that emits
a file" and the other chat text. Don't build a bespoke copy command — a slash command
can't reach the clipboard except via OS-specific shell tools (`pbcopy`/`xclip`) that
fail on web and over SSH; build one only where there's no native affordance. Record:
the decision records and task ledger already hold durable state — add a `handoffs/`
file only if they're too terse to recover the pending hand-off after a crash.

### Test strategy — shaped to the contract surface

- Unit tests for logic, integration tests for boundaries (DB, queues, external
  APIs), and **contract tests for every API/gRPC surface with an external
  consumer** — schema-compatibility checks that fail the build on an undeclared
  breaking change.
- The test suite is the regression gate: green before a task starts (or the
  breakage is documented), green before it's declared done. Tests are part of the
  same change as the code, not a follow-up task that never comes.
- Rewriting or deleting an existing test to make it pass is a directional change
  requiring explicit human sign-off — tests are the codified contract for past
  behavior.

### Operational discipline

- **Migrations:** forward-only, reversible where the platform allows, never
  destructive without a gate (invariant 3), always tested against a realistic
  snapshot before production.
- **Deploys:** every deploy ships with a stated rollback path; a deploy that cannot
  be rolled back is a destructive action and gated as one (invariant 3).
- **Security floor:** input validation at every boundary, authn/authz checks on
  every new endpoint, no secrets in code or logs, dependency audit in CI. New
  attack surface (file upload, webhooks, auth flows) gets an explicit security
  pass in review.
- **Observability from day 1:** structured logs at boundaries, errors with enough
  context to debug from logs alone, health checks for every service.
- **Conventional commits, small and frequent**, on feature branches; the human
  decides what merges. Commit messages reference the spec or task they advance.

### Review loop

Every substantive diff goes through the reviewer subagent before the human sees
it: correctness, contract impact, security, test adequacy. Blockers are fixed or
explicitly rebutted — never silently ignored. The reviewer's findings summary
travels with the work report, and raw reviewer output is preserved in the repo,
keyed to the commit it reviewed, where the human can audit it — a prose "review
passed" claim is not evidence. The reviewer is read-only and never owns direction.

### Rule budget — the system must stay small

Every rule cites the failure it defends against. The retro (Step 6) prunes rules
that never fire and migrates prose rules to mechanical gates as capabilities allow.
Target: the conventions file readable in two minutes, an "every-task" section up
top, everything else an exception manual. A system whose rule mass only grows
becomes the drift it was built to prevent.

### Phase calibration

Prototype phase: invariants + tests-on-the-core + task ledger; skip contract
ceremony and heavy review. Production phase: everything. The current phase is an
explicit line in the system files; transitions are deliberate, dated amendments —
never silent.

## Step 4 — Build it

Generate the system: the slim conventions file (bootstrap ritual, invariants,
commands, ownership table, pointers), role files if the topology needs them, the
decision-record directory seeded with the stack decisions already visible in the
repo (mark them as inferred, ask the human to confirm), the task ledger, the specs
directory, `gates/` scripts and hooks for everything mechanically checkable (test
runner, lint/typecheck, contract-diff check, migration-safety check, destructive-
command guard), CI wiring if the project ships, and the reviewer subagent definition
(committed in the project, not user-global, so a fresh clone has the whole system).
Changing or weakening a gate requires explicit human sign-off, exactly
like rewriting a test — never a side effect of making a task pass. One commit per
coherent unit, conventional messages. Where the project already had working
equivalents, adapt and keep their names.

## Step 5 — Verify before handing over

- Dry-run the bootstrap: can a fresh session reconstruct project state, conventions,
  and current tasks from files alone? Fix what it can't.
- Run every gate; each must pass on the clean repo and demonstrably fail on a
  violation (test at least one — e.g. introduce a contract break and confirm the
  gate catches it).
- Run the existing test suite and record its baseline state — failures inherited
  from before the setup are documented, not silently adopted.
- Hand the human a summary: what was created, what each gate enforces, what is
  deliberately *not* enforced yet and which phase transition turns it on.

## Step 6 — Install the evolution loop

- A periodic retro (per milestone or every N merged tasks) examines **the system,
  not just the product**: which rules fired, which were ignored (an ignored rule is
  a design bug — fix the rule or the gate), what new failure mode appeared.
  Amendments are dated and cite the incident.
- At each phase boundary, re-check harness capabilities and migrate prose rules to
  mechanical gates when new capability allows.
- When a lesson is project-agnostic, the human backports it to the repo this prompt
  lives in — the prompt is versioned and evolves the same way the systems it
  generates do.

---

## Pushbacks you are expected to make

- If the human asks for "no process, just code": the invariants are the minimum
  that keeps an agent honest about what works. Offer to shrink the mechanism set
  and defer ceremony to a later phase — never to drop the invariants.
- If the human asks to skip tests "for now" on contract-bearing code: surface the
  cost (every future change to that surface is unverified) and get an explicit
  acknowledgment recorded in the known-issues register, so "for now" has a paper
  trail.
- If an existing setup has a rule you'd prune but the human says it once saved
  them: keep it — their incident memory outranks your tidiness.
