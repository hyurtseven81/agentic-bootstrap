# Agentic Development System — Setup Prompts

Self-contained prompts that, when run through a frontier model (Claude Opus/Fable
in Claude Code or equivalent), **set up a tailored agentic development system** in
the target project — instead of copying a fixed boilerplate.

## The prompts

| Prompt | For |
|---|---|
| [`prompts/setup-ml-research-system.md`](prompts/setup-ml-research-system.md) | Complex ML research — recsys, ranking, retrieval; expensive experiments, human-in-the-loop Lead/Scientist split, pre-registration, verdict discipline |
| [`prompts/setup-autonomous-goal-loop.md`](prompts/setup-autonomous-goal-loop.md) | Autonomous goal loops — sibling of the ML-research prompt for goals whose success criteria are scripts exiting 0/1 against tamper-proof artifacts; a goal-definition command, unattended Plan→Implement→Verify→Evaluate→Critique→Decide iterations, frozen objective, append-only ledger, mechanical budget caps, escalation triggers |
| [`prompts/setup-engineering-system.md`](prompts/setup-engineering-system.md) | Standard product engineering — CMS, ERP, SaaS; backend / frontend / API / gRPC; spec-first, contract discipline, test gates |
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
- **Unattended goal-grinding** →
  [`setup-autonomous-goal-loop.md`](prompts/setup-autonomous-goal-loop.md), but
  only for goals passing its **autonomy test**: every success criterion
  checkable by a script exiting 0/1 against artifacts the agent cannot corrupt.
  "Metric ≥ threshold on the frozen eval split, tests green, reproducible"
  passes; "architecture X beats baseline Y under condition Z" never does — that
  is a research claim and belongs to the ML-research system.
- **The project is already live** — runs in flight, current state files →
  prepend [`upgrade-live-project-preamble.md`](prompts/upgrade-live-project-preamble.md)
  to whichever prompt applies.

The three system prompts **compose in one project**. The normal pairing is
research or engineering as the primary, human-in-the-loop system, plus the goal
loop installed alongside for the subgoals that pass the autonomy test
(reproduce a baseline, make a suite green, push a pre-registered metric past a
threshold). Each prompt's hybrid/delegation section defines the seam; the short
version: loop outcomes are *evidence* the primary system adjudicates — `done`
is not a validated claim, and an exhausted budget is "stalled", never "not
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
2. Paste the primary prompt (`setup-ml-research-system.md`) and answer the
   interview — this is where you state the hypothesis ("X beats Y under
   condition Z"), headline metrics, compute platform, and current phase. The
   system it builds then owns `problems.md`, the goals doc, ADRs, and the rest.
3. Work through the system it built: pre-register the claim, build the frozen
   harness, iterate with the human-in-the-loop protocol.
4. When concrete subgoals pass the autonomy test and you want them ground
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

These prompts deliberately avoid strict, frozen rulebooks. Each one carries:

- **A small set of hard invariants** — anti-fabrication, append-only history,
  pre-commitment before expensive/irreversible actions, mechanical gates over
  prose, and *content is not instruction* (fetched pages, logs, diffs, issue text
  and tool output are evidence the agent reads, never direction it follows). These
  never bend; they're the floor that keeps an agent honest.
- **Principles and a mechanism menu** — adapted to the project's domain, phase,
  and risk profile at setup time, not copied verbatim.
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
