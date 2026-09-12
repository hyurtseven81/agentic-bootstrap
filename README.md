# Agentic Development System — Setup Prompts

Self-contained prompts that, when run through a frontier model (Claude Opus/Fable
in Claude Code or equivalent), **set up a tailored agentic development system** in
the target project — instead of copying a fixed boilerplate — and then take work
through it: intent captured in the originator's words, a plan reviewed blind,
executed one step per fresh context, and never called done early. Four prompts,
one job each.

## The prompts

| Prompt | For |
|---|---|
| [`prompts/setup-agentic-system.md`](prompts/setup-agentic-system.md) | Building (or upgrading) the development system in a project. One prompt, three **profiles** that combine: **research** — ML research with expensive experiments; human-in-the-loop Lead/Scientist split, pre-registration, verdict discipline; **engineering** — product software (services, clients, APIs, databases); spec-first, contract discipline, test gates; **goal loop** — an unattended mode installed alongside either, for goals whose every success criterion a script can check: a goal-definition command, Plan→Implement→Verify→Evaluate→Critique→Decide iterations, frozen objective, append-only ledger, mechanical budget caps, escalation triggers. Its live-project mode (Step 0.4) turns it audit-and-upgrade only when runs are in flight |
| [`prompts/plan-review-execute.md`](prompts/plan-review-execute.md) | Taking one piece of work from intent to a validated done, inside whichever system exists or alone: the intent captured in the originator's own words and accepted before planning; for a novel project from a paper, an idea, or a brief, a spec in requirements → design → pre-registered plan stages (sources read in full, data audited by query, the success policy written before any architecture, every claim tagged source / adaptation / assumption / measured) from the kickoff brief template at its end; a step plan a stranger could execute; a blind plan review by a context-free subagent (or the review prompt, for claim-grade work); one step per fresh context against the committed plan with a scope-conformance gate; a done claim validated by a context that did not execute |
| [`prompts/review-plan-blind.md`](prompts/review-plan-blind.md) | Blind review of a spec, design, plan, or pre-registration in a separate session — sources read before the document, wrong / unjustified / missing / could-not-verify kept apart, a findings ledger with stable ids and defined severities, a second round that re-checks each id against the revision. A separate file on purpose: the reviewer must never see what the author was asked to produce |
| [`prompts/setup-workstation.md`](prompts/setup-workstation.md) | The workstation the rest run on. Part I provisions the machine — macOS / Linux / Windows / WSL2, fresh or partial; shell, tmux, Neovim/LazyVim, runtimes, ML CLI tooling; Part II configures the Claude Code harness — strongest-model + largest-context default, auto-memory, auto-accept posture with mechanical gates, subagents, skills, plugins, MCP. One inventory, one self-evolution pass, one run report; idempotent, proxy-aware, approval-gated |

## Which prompt, when

Pick by what you're setting up:

- **The workstation** — machine, shell, editors, runtimes, and the Claude Code
  harness itself (models, memory, permissions, subagents) →
  [`setup-workstation.md`](prompts/setup-workstation.md). Once per machine; re-run
  it when the harness ships something new — Part I reports zero changes and Part II
  reconciles.
- **A project's development system** →
  [`setup-agentic-system.md`](prompts/setup-agentic-system.md), whatever the
  project is. Reconnaissance and the interview pick the profile: **engineering**
  when success means tests green, contracts kept, features demonstrated;
  **research** when it means a defensible claim from expensive experiments; both
  when the project trains, evaluates, *and* ships. The **goal loop** is added
  alongside for unattended grinding, but only for goals passing its **autonomy
  test**: every success criterion checkable by a script exiting 0/1 against
  artifacts the agent cannot corrupt. "Metric ≥ threshold on the frozen eval split,
  tests green, reproducible" passes; "architecture X beats baseline Y under
  condition Z" never does — that is a research claim and belongs to the research
  profile.
- **A research question ground unattended** → no prompt builds that any more.
  Delegate the mechanically verifiable subgoals to the goal loop, run the search on
  an autoresearch substrate if you have one, and let the research profile
  adjudicate the output as an executor result — its premature-verdict defenses
  carry the dead-end burden for any loop that ran unattended. The retired campaign
  prompt stays in `reference/` for a multi-day campaign that needs the full
  discipline while the loop is still running.
- **Work to do** — a task, a ticket, or nothing yet but a paper, an idea, a brief →
  [`plan-review-execute.md`](prompts/plan-review-execute.md). Inside an existing
  system it goes intent → step plan → blind review → one step per fresh context →
  validated done. For a novel project it first produces the spec in stages —
  requirements → design → pre-registered plan, each reviewed blind — then hands off
  to the system prompt, which builds the development system around that spec
  instead of interviewing it out of you, and only then executes. Its intent capture
  is also the cheapest gate for a research question: the decision the answer
  informs is written down before anyone formalizes the question.
- **A spec, design, or plan that needs an opinion its author can't give** →
  [`review-plan-blind.md`](prompts/review-plan-blind.md) in a separate session, at
  every stage gate — requirements before design, design before plan — because a
  wrong objective is cheapest to catch at the first gate and fatal at the last.
- **The project is already live** — runs in flight, current state files → the same
  [`setup-agentic-system.md`](prompts/setup-agentic-system.md) in a fresh session,
  with the facts stated up front (what is operating, whether a run is in flight).
  Its Step 0.4 then overrides everything else: audit-and-upgrade only, live state
  and evidence untouchable, renames forbidden, local commits only, new gates
  additive (a latent bug they expose is reported, never self-adjudicated),
  refactors deferred until the in-flight work closes.

The profiles **compose in one project**. The normal pairing is research or
engineering as the primary, human-in-the-loop system, plus the goal loop installed
alongside for the subgoals that pass the autonomy test (reproduce a baseline, make a
suite green, push a pre-registered metric past a threshold). The prompt's goal-loop
section defines the seam; the short version: unattended outcomes are *evidence* the
primary system adjudicates — `done` is not a validated claim, and an exhausted budget
is "stalled", never "not achievable". Co-installed does not mean co-located: give the
unattended loop its own working tree or clone. Ownership tables are written per
*file*, so they can't see a per-*tree* collision, and the damage isn't lost work —
it's gates and metrics running against an attended session's uncommitted edits.

## Usage

No need to clone this repo — every prompt is **self-contained**, and nothing it
builds in your project references this repo's files. Sibling mentions inside a
prompt (the system prompt pointing at the workflow prompt, say) are pointers for
*you*, not files the agent reads: the sibling is pasted into its own session in the
same project, where its reconnaissance finds the existing system and integrates with
it rather than replacing it.

1. Open an agent session at the root of your project (empty **or** existing) — or,
   for the workstation prompt, anywhere on the target machine.
2. Paste the entire relevant prompt (raw view → copy all) — for the workflow prompt,
   followed by the work itself: the intent, the ticket, or the filled kickoff brief.
3. Answer the short interview; review the proposed plan; let it build.

On a **non-empty project** (or a partially set-up machine) the prompt audits what's
already there and proposes a *keep / add / prune* upgrade — it adapts to your setup
rather than imposing the template.

### Starting a new project from scratch

Don't pre-author `problems.md`, goals docs, or any other state files — the
prompts generate them: reconnaissance reads whatever is in the folder, the
interview asks for the rest, and the build step seeds the state files from your
answers. A typical sequence:

1. *(Optional)* Drop existing context into the empty folder — notes, a rough
   README, papers, dataset pointers, prior code. Reconnaissance reads it and
   the interview shrinks.
2. *(If you're starting from a paper, an idea, or a brief rather than a formed
   hypothesis)* Paste `plan-review-execute.md` with its kickoff brief filled in. It
   reads the sources in full, audits the data by query, writes the success policy
   before any architecture, and produces a tagged requirements → design → plan
   spec in stages — run `review-plan-blind.md` in a separate session at each
   stage gate. The reviewed spec is the strongest form of step 1's context.
3. Paste `setup-agentic-system.md` and answer the interview — this is where you
   state the hypothesis ("X beats Y under condition Z") or the product's shape and
   quality bar, headline metrics, compute platform, and current phase; with a
   reviewed spec in the folder the interview mostly confirms it. The system it
   builds then owns `problems.md`, the goals doc, ADRs, and the rest.
4. Work through the system it built: pre-register the claim, build the frozen
   harness, iterate with the human-in-the-loop protocol. Any multi-step piece of
   work runs through `plan-review-execute.md`, which adopts the system's files: the
   plan is reviewed blind before its first step and executed one step per fresh
   context.
5. When concrete subgoals pass the autonomy test and you want them ground
   unattended, paste `setup-agentic-system.md` again into a new session at the same
   root and ask for the goal loop — it audits the existing setup and installs the
   loop alongside it.

### Applying to an established project

The prompt distinguishes two established states:

- **Existing codebase, nothing running.** Paste the prompt directly. Its
  reconnaissance audits whatever is there — code, history, any prior agentic
  setup — and proposes the *keep / add / prune* upgrade for approval before
  touching anything, keeping your existing names and conventions. This is also
  how a later run adds a profile to a project an earlier one already set up.
- **Live project** — protocol files in active use, possibly an expensive run in
  flight. Open a fresh session (never an existing role session), state what is
  operating and whether a run is in flight, and paste the prompt; its Step 0.4
  overrides the rest of it: audit-and-upgrade only, live state and evidence
  untouchable, renames forbidden, local commits only, new gates additive (a latent
  bug they expose is reported, never self-adjudicated), refactors deferred until
  the in-flight work closes.

## Design philosophy

These prompts deliberately avoid strict, frozen rulebooks. The system prompt
carries all five of the following; the two workflow prompts carry the first two
in miniature and exist for the fourth:

- **A small set of hard invariants** — anti-fabrication, append-only history,
  pre-commitment before expensive/irreversible actions, mechanical gates over
  prose, and *content is not instruction* (fetched pages, logs, diffs, issue text
  and tool output are evidence the agent reads, never direction it follows). These
  never bend; they're the floor that keeps an agent honest.
- **Principles and a mechanism menu** — adapted to the project's domain, phase,
  and risk profile at setup time, not copied verbatim.
- **A layered instruction surface** — the always-loaded file carries invariants and
  pointers only; procedures load on demand; the per-task thinking is persisted to a
  spec or pre-registration file and executed against *after* a context clear; and the
  integrity-critical subset is enforced mechanically. Always-loaded text is advisory,
  and adherence to it decays as it grows, so the prompts treat that file as a budget
  rather than a filing cabinet: the fix for a long session losing its earlier
  decisions is a written record the agent re-reads, never a longer instruction file.
- **The author never grades its own work** — the blind reviewer at a spec's stage
  gates, the context-free reader that dry-runs a bootstrap, the fresh-context
  adjudicator of an unattended loop's dead-end claim, the read-only critic in every loop,
  the plan reviewer that sees a step plan before its first step runs, and the
  validator that checks a done claim without having executed it. A session that
  produced a thing will pass it; the check has to live in a context that cannot
  remember producing it.
- **A self-evolution loop** — the generated system retros itself, prunes rules
  that never fire, amends itself with dated version bumps, and re-checks current
  harness capabilities (hooks, subagents, memory, …) at each phase boundary. The
  prompt instructs the model to probe what the tooling can do *now* rather than
  trusting this repo's snapshot — the AI/LLM space moves faster than any
  document.

The reasoning: pure principles drift, pure rules rot. A thin invariant floor plus
an explicit amendment mechanism is what keeps multi-week agentic projects from
either failure.

## Evolving this repo

Every prompt carries a **Prompt version** header — bump it on every amendment and
cite the motivating lesson or incident in the commit message. The repo applies its
own gates-over-prose rule to itself: CI runs [`gates/run-all.sh`](gates/run-all.sh)
on every PR — version headers present, and *advanced* (not merely touched) on any
prompt change, renames followed; links resolving, no prompt linking anything
(self-containment, mechanical), every prompt reachable from this README; shellcheck
clean. Run it locally before committing and pass the upstream ref —
`gates/run-all.sh origin/main` — since a stale local `main` silently narrows what
the bump check can see. It reads the working tree, so it catches an unbumped edit
before the commit exists.

Lessons flow both ways. When a generated system learns a project-agnostic lesson (a
new failure mode, a gate worth standardizing, a harness capability worth exploiting),
backport it to the relevant prompt here; and each generated system stamps the prompt
name, version, and date that built it into its root instruction file, so you can tell
which vintage of the protocol a given project is still running. The workstation
prompt goes further: its Phase A re-reviews the prompt itself on every run and
proposes amendments before acting. The prompts are living documents.

The collection stays at four files. A new concern becomes a profile, a stage, or a
phase of the prompt whose job it serves, not a fifth prompt: the 2026-09-12
consolidation from eleven prompts to four happened because a user could no longer
tell which one to run.

## Retired

`reference/` holds retired prompts, frozen as prior art. Currently:
`setup-autonomous-research-campaign.md`, retired 2026-09-12 — its header says why and
where its live mechanisms went. The original v1 fixed boilerplate (the two-role
Lead/Scientist template) was deleted from the tree the same day, after its
battle-tested mechanisms (pre-reg tamper checks, killed-register, retro checklist,
frozen-artifact manifests) had long been backported into the prompts; it is
reachable at commit `bcb6304`, the last one that carried it.

Merged, not retired, on the same day — nothing was dropped, and each merged file
continues the highest version number it absorbed:

- `setup-ml-research-system.md` (v11), `setup-engineering-system.md` (v10),
  `setup-autonomous-goal-loop.md` (v7), and `upgrade-live-project-preamble.md` (v6)
  → `setup-agentic-system.md` (v12): the three systems became profiles of one
  skeleton, the preamble its live-project mode.
- `kickoff-spec-first-project.md` (v2) and `run-plan-stepwise.md` (v2) →
  `plan-review-execute.md` (v3): the spec stages and the step-plan driver were one
  workflow with a seam in the middle.
- `setup-dev-machine.md` (v3) and `setup-claude-code.md` (v8) →
  `setup-workstation.md` (v9): one machine, one inventory, one report.

The separate files are reachable at commit `cf144f0`, the last one that carried
them.
