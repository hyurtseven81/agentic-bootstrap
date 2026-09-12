# Agentic Development System — Setup Prompts

Self-contained prompts that, when run through a frontier model (Claude Opus/Fable
in Claude Code or equivalent), **set up a tailored agentic development system** in
the target project — instead of copying a fixed boilerplate — plus three workflow
prompts that start a project spec-first from a paper or an idea, review the
resulting spec blind, and run a plan step by step without losing it or calling it
done early.

## The prompts

| Prompt | For |
|---|---|
| [`prompts/setup-ml-research-system.md`](prompts/setup-ml-research-system.md) | Complex ML research — recsys, ranking, retrieval; expensive experiments, human-in-the-loop Lead/Scientist split, pre-registration, verdict discipline |
| [`prompts/setup-autonomous-goal-loop.md`](prompts/setup-autonomous-goal-loop.md) | Autonomous goal loops — sibling of the ML-research prompt for goals whose success criteria are scripts exiting 0/1 against tamper-proof artifacts; a goal-definition command, unattended Plan→Implement→Verify→Evaluate→Critique→Decide iterations, frozen objective, append-only ledger, mechanical budget caps, escalation triggers |
| [`prompts/setup-autonomous-research-campaign.md`](prompts/setup-autonomous-research-campaign.md) | Autonomous research campaigns — you write a brief (question, dataset, methodology space, reference papers, resource ceiling) and the system runs unattended to a positive result or an established dead end; subagent cast (implementer, code reviewer, literature and industry-practice scouts, critic, adjudicator), sequestered confirmation split, stuck ladder instead of stopping, exhaustion burden on failure |
| [`prompts/setup-engineering-system.md`](prompts/setup-engineering-system.md) | Standard product engineering — CMS, ERP, SaaS; backend / frontend / API / gRPC; spec-first, contract discipline, test gates |
| [`prompts/kickoff-spec-first-project.md`](prompts/kickoff-spec-first-project.md) | Starting a novel project from a paper, an idea, or a brief — sources read in full, data audited by query, the success policy written before any architecture, a spec tagged source / adaptation / assumption / measured in requirements → design → pre-registered plan stages, each behind a blind review; the setup prompts are seeded from it. Paste the whole prompt into an agent session, or its filled brief alone into a spec-driven tool |
| [`prompts/review-plan-blind.md`](prompts/review-plan-blind.md) | Blind review of a spec, design, plan, or pre-registration in a separate session — sources read before the document, wrong / unjustified / missing / could-not-verify kept apart, a findings ledger with stable ids and defined severities, a second round that re-checks each id against the revision |
| [`prompts/run-plan-stepwise.md`](prompts/run-plan-stepwise.md) | Taking one piece of work from intent to a validated done — the intent captured in the originator's own words and accepted before planning, a step plan a stranger could execute, a blind plan review by a context-free subagent (or the review sibling for claim-grade work), one step per fresh context against the committed plan with a scope-conformance gate, and a done claim validated by a context that did not execute; runs inside any system from this collection or alone |
| [`prompts/setup-dev-machine.md`](prompts/setup-dev-machine.md) | Provisioning the dev machine itself — macOS / Linux / Windows / WSL2, fresh or partial; shell, tmux, Neovim/LazyVim, runtimes, ML CLI tooling; idempotent, proxy-aware, approval-gated |
| [`prompts/setup-claude-code.md`](prompts/setup-claude-code.md) | Configuring the Claude Code harness itself — strongest-model + largest-context default, auto-memory, auto-accept posture with mechanical gates, subagents, skills, plugins, MCP; idempotent, approval-gated, self-evolving |
| [`prompts/upgrade-live-project-preamble.md`](prompts/upgrade-live-project-preamble.md) | Companion preamble — prepend to a setup prompt when the target project is already **live** (runs in flight, current state files) to force audit-and-upgrade mode with explicit do-not-touch constraints |

## Which prompt, when

Pick by what you're setting up:

- **The machine itself** — shell, tmux, editors, runtimes →
  [`setup-dev-machine.md`](prompts/setup-dev-machine.md)
- **The Claude Code harness itself** — models, memory, permissions, subagents →
  [`setup-claude-code.md`](prompts/setup-claude-code.md)
- **A software product** — success means tests green, contracts kept, features
  demonstrated → [`setup-engineering-system.md`](prompts/setup-engineering-system.md)
- **ML research** — success means a defensible claim from expensive experiments →
  [`setup-ml-research-system.md`](prompts/setup-ml-research-system.md)
- **A research question ground unattended** — you have a brief and a methodology
  space, and what limits you is the *number of hand-carried turns* rather than the
  difficulty of the science →
  [`setup-autonomous-research-campaign.md`](prompts/setup-autonomous-research-campaign.md).
  It runs the claim autonomously, which the other two prompts refuse, and pays for
  it: the burden of proof on *failure* is higher than on success, the confirmation
  split is sequestered from the search loop, and the terminal verdict is adjudicated
  by a context that did not run the experiments. Its output is a defended draft
  conclusion — one human turn per campaign — not a validated claim.
- **Unattended goal-grinding** →
  [`setup-autonomous-goal-loop.md`](prompts/setup-autonomous-goal-loop.md), but
  only for goals passing its **autonomy test**: every success criterion
  checkable by a script exiting 0/1 against artifacts the agent cannot corrupt.
  "Metric ≥ threshold on the frozen eval split, tests green, reproducible"
  passes; "architecture X beats baseline Y under condition Z" never does — that
  is a research claim and belongs to the ML-research system.
- **Nothing exists yet — a paper, an idea, a brief** →
  [`kickoff-spec-first-project.md`](prompts/kickoff-spec-first-project.md) first.
  It reads the sources in full, audits the data, writes the success policy before
  any architecture, and produces a tagged spec in stages; the setup prompt you run
  next builds the development system around that spec instead of interviewing it
  out of you.
- **A spec, design, or plan that needs an opinion its author can't give** →
  [`review-plan-blind.md`](prompts/review-plan-blind.md) in a separate session, at
  every stage gate — requirements before design, design before plan — because a
  wrong objective is cheapest to catch at the first gate and fatal at the last.
- **A plan to run without losing it** — plan first, review it blind, execute one
  step per fresh context, and never call it done early →
  [`run-plan-stepwise.md`](prompts/run-plan-stepwise.md), inside whichever system
  exists. Its intent capture is also the cheapest gate for a research question: the
  decision the answer informs is written down before anyone formalizes the question.
- **The project is already live** — runs in flight, current state files →
  prepend [`upgrade-live-project-preamble.md`](prompts/upgrade-live-project-preamble.md)
  to whichever prompt applies.

The four system prompts **compose in one project**. The normal pairing is
research or engineering as the primary, human-in-the-loop system, plus the goal
loop installed alongside for the subgoals that pass the autonomy test
(reproduce a baseline, make a suite green, push a pre-registered metric past a
threshold), and the research campaign for a whole question you want ground
overnight. Each prompt's hybrid/delegation section defines the seam; the short
version: unattended outcomes are *evidence* the primary system adjudicates — `done`
is not a validated claim, a campaign's terminal verdict is a defended draft, and an
exhausted budget is "stalled", never "not
achievable". Co-installed does not mean co-located: give the unattended loop its
own working tree or clone. Ownership tables are written per *file*, so they can't
see a per-*tree* collision, and the damage isn't lost work — it's gates and metrics
running against an attended session's uncommitted edits.

## Usage

No need to clone this repo — every prompt is **self-contained**, and nothing it
builds in your project references this repo's files. Sibling mentions inside a
prompt (the research system pointing at the goal loop, say) are pointers for
*you*, not files the agent reads: the sibling is installed by pasting that
prompt into its own session in the same project, where its reconnaissance finds
the existing system and integrates with it rather than replacing it.

1. Open an agent session at the root of your project (empty **or** existing) — or,
   for the machine prompt, anywhere on the target machine.
2. Paste the entire relevant prompt (raw view → copy all). If the project is
   live, prepend the upgrade preamble.
3. Answer the short interview; review the proposed plan; let it build.

On a **non-empty project** (or a partially set-up machine) the prompt audits what's
already there and proposes a *keep / add / prune* upgrade — it adapts to your setup
rather than imposing the template.

### Starting a new project from scratch

Don't pre-author `problems.md`, goals docs, or any other state files — the
prompts generate them: reconnaissance reads whatever is in the folder, the
interview asks for the rest, and the build step seeds the state files from your
answers. A typical sequence for a research project:

1. *(Optional)* Drop existing context into the empty folder — notes, a rough
   README, papers, dataset pointers, prior code. Reconnaissance reads it and
   the interview shrinks.
2. *(If you're starting from a paper, an idea, or a brief rather than a formed
   hypothesis)* Paste `kickoff-spec-first-project.md` with your kickoff brief. It
   reads the sources in full, audits the data by query, writes the success policy
   before any architecture, and produces a tagged requirements → design → plan
   spec in stages — run `review-plan-blind.md` in a separate session at each
   stage gate. The reviewed spec is the strongest form of step 1's context.
3. Paste the primary prompt (`setup-ml-research-system.md`) and answer the
   interview — this is where you state the hypothesis ("X beats Y under
   condition Z"), headline metrics, compute platform, and current phase; with a
   kickoff spec in the folder the interview mostly confirms it. The system it
   builds then owns `problems.md`, the goals doc, ADRs, and the rest.
4. Work through the system it built: pre-register the claim, build the frozen
   harness, iterate with the human-in-the-loop protocol. Any multi-step piece of
   work runs through `run-plan-stepwise.md`, which adopts the system's files: the
   plan is reviewed blind before its first step and executed one step per fresh
   context.
5. When concrete subgoals pass the autonomy test and you want them ground
   unattended, paste `setup-autonomous-goal-loop.md` into a new session at the
   same root — it audits the existing setup and installs the loop alongside it.

Engineering projects follow the same shape with `setup-engineering-system.md`
as the primary.

### Applying to an established project

The prompts distinguish two established states:

- **Existing codebase, nothing running.** Paste the prompt directly. Its
  reconnaissance audits whatever is there — code, history, any prior agentic
  setup — and proposes the *keep / add / prune* upgrade for approval before
  touching anything, keeping your existing names and conventions. This is also
  how a sibling prompt joins a project the first one already set up.
- **Live project** — protocol files in active use, possibly an expensive run in
  flight. Prepend
  [`upgrade-live-project-preamble.md`](prompts/upgrade-live-project-preamble.md)
  (edit its bracketed facts first) in a fresh session. It overrides the setup
  prompt where they conflict: audit-and-upgrade only, live state and evidence
  untouchable, renames forbidden, new gates additive (a latent bug they expose
  is reported, never self-adjudicated), refactors deferred until the in-flight
  work closes.

## Design philosophy

These prompts deliberately avoid strict, frozen rulebooks. Each system prompt
carries all five of the following; the three workflow prompts carry the first two
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
  gates, the context-free reader that dry-runs a bootstrap, the campaign's
  adjudicator that never ran the experiments, the read-only critic in every loop,
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
prompt change, renames followed; the system prompts' section skeletons in structural
parallel; links resolving, no prompt linking anything (self-containment, mechanical),
every prompt reachable from this README; shellcheck clean. Run it locally before
committing and pass the upstream ref — `gates/run-all.sh origin/main` — since a stale
local `main` silently narrows what the bump check can see. It reads the working tree,
so it catches an unbumped edit before the commit exists.

Lessons flow both ways. When a generated system learns a project-agnostic lesson (a
new failure mode, a gate worth standardizing, a harness capability worth exploiting),
backport it to the relevant prompt here; and each generated system stamps the prompt
name, version, and date that built it into its root instruction file, so you can tell
which vintage of the protocol a given project is still running. The machine prompt
goes further: its Phase A re-reviews the prompt itself on every run and proposes
amendments before acting. The prompts are living documents.

## Reference

`reference/legacy-strict-template/` holds the original v1 fixed boilerplate
(two-role Lead/Scientist protocol with fully specified role files). It's
superseded as a copy-paste artifact but kept as prior art — the battle-tested
mechanisms in it (pre-reg tamper checks, killed-register, retro checklist,
frozen-artifact manifests) informed the prompts and remain useful reading when
deciding which mechanisms a mature project should adopt.
