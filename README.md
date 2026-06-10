# Agentic Development System — Setup Prompts

Self-contained prompts that, when run through a frontier model (Claude Opus/Fable
in Claude Code or equivalent), **set up a tailored agentic development system** in
the target project — instead of copying a fixed boilerplate.

## The prompts

| Prompt | For |
|---|---|
| [`prompts/setup-ml-research-system.md`](prompts/setup-ml-research-system.md) | Complex ML research — recsys, ranking, retrieval; expensive experiments, human-in-the-loop Lead/Scientist split, pre-registration, verdict discipline |
| [`prompts/setup-engineering-system.md`](prompts/setup-engineering-system.md) | Standard product engineering — CMS, ERP, SaaS; backend / frontend / API / gRPC; spec-first, contract discipline, test gates |
| [`prompts/setup-dev-machine.md`](prompts/setup-dev-machine.md) | Provisioning the dev machine itself — macOS / Linux / Windows / WSL2, fresh or partial; shell, tmux, Neovim/LazyVim, runtimes, ML CLI tooling; idempotent, proxy-aware, approval-gated |

## Usage

1. Open an agent session at the root of your project (empty **or** existing) — or,
   for the machine prompt, anywhere on the target machine.
2. Paste the entire relevant prompt.
3. Answer the short interview; review the proposed plan; let it build.

On a **non-empty project** (or a partially set-up machine) the prompt audits what's
already there and proposes a *keep / add / prune* upgrade — it adapts to your setup
rather than imposing the template.

## Design philosophy

These prompts deliberately avoid strict, frozen rulebooks. Each one carries:

- **A small set of hard invariants** — anti-fabrication, append-only history,
  pre-commitment before expensive/irreversible actions, mechanical gates over
  prose. These never bend; they're the floor that keeps an agent honest.
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
cite the motivating lesson or incident in the commit message. When a generated
system learns a project-agnostic lesson (a new failure mode, a gate worth
standardizing, a harness capability worth exploiting), backport it to the relevant
prompt here. The machine prompt goes further: its Phase A re-reviews the prompt
itself on every run and proposes amendments before acting. The prompts are living
documents.

## Reference

`reference/legacy-strict-template/` holds the original v1 fixed boilerplate
(two-role Lead/Scientist protocol with fully specified role files). It's
superseded as a copy-paste artifact but kept as prior art — the battle-tested
mechanisms in it (pre-reg tamper checks, killed-register, retro checklist,
frozen-artifact manifests) informed the prompts and remain useful reading when
deciding which mechanisms a mature project should adopt.
