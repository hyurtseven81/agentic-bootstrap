# Setup Prompt — Claude Code Harness Configuration

> **Prompt version: v3 (2026-06-10)** — bump on every amendment; cite the lesson or
> incident that motivated it in the commit message. Phase A re-evaluates this file
> every run and proposes amendments when stale; after approval, backport them to
> the canonical copy in the prompts repo.

**How to use:** open a Claude Code session on the machine whose harness you are
configuring (any directory — the target is user-scope config) and paste this entire
prompt. For this setup run approvals stay ON by design — the agent inventories,
plans, asks, then acts; the auto-accept posture it *configures* (see SPEC) is for
later sessions, and regardless of when a written mode change takes effect, this
run keeps asking before every mutating unit.

Scope: the **agent harness itself** — model + context defaults, auto-memory,
permissions, hooks, sandbox, subagents, skills, plugins, MCP servers — at user
scope (`~/.claude/`), with project-scope conventions documented, never imposed.
Companions: `setup-dev-machine.md` provisions the OS/toolchain underneath; the
two system prompts (`setup-ml-research-system.md`, `setup-engineering-system.md`)
build per-project process on top. A project-level concern discovered here gets
noted for those prompts, not configured globally.

## Source of truth

This command file IS the source of truth — no external dotfiles repo or sync
service. The SPEC at the bottom defines my fixed choices and required outcomes.
Author the config to satisfy the SPEC using the harness's CURRENT documented
mechanisms: the specifics in this prompt were verified against the official docs
on 2026-06-10, and the harness ships frequently — on any mismatch the current
docs win, and Phase A reports the drift. Never write a settings key, model name, or
feature flag you have not confirmed against the installed version's docs or
`--help` output.

## Hard rules

- IDEMPOTENT and re-runnable: detect current state before changing anything; a
  second run immediately after a successful one must report zero changes needed.
- BACK UP every file before modifying it (timestamped `.bak`); never delete my
  files; never touch managed/enterprise scope.
- Show me a PLAN — per file, per key, with scope — and wait for confirmation
  before the first mutating step.
- JSON DISCIPLINE: settings files are parsed, not templated. Validate every write
  (`jq` or equivalent) before and after; PRESERVE every key you don't manage —
  reconcile, never regenerate a file wholesale. JSON carries no comments, so the
  run report (not the file) records each key this setup owns, its value, and why.
- MARKDOWN DISCIPLINE: in Markdown artifacts this setup writes into
  (`~/.claude/CLAUDE.md`), authored content lives between managed sentinel blocks
  (HTML comments, one block per unit) — re-runs replace block content in place;
  everything outside the blocks is MINE and preserved untouched; changes to MY
  lines happen only through a diff I approve.
- NARROWEST SCOPE: personal defaults at user scope (`~/.claude/settings.json`);
  project scope only when I name a project; `settings.local.json` for experiments.
- SUPPLY CHAIN: plugins, marketplaces, MCP servers, and hooks are code that runs
  with my permissions. Before installing any: name the source, the author, what it
  executes, and what data it can see. No blind installs; prefer official /
  first-party sources; pin where the mechanism allows. Secrets only via env
  expansion (`${VAR}`) — never literal in any config file.
- NO SECRETS in anything you write; warn me about any live credential you find.
- Author to satisfy the SPEC, then VERIFY each outcome with its stated check in a
  fresh probe session — never assume. Report failures as failures, with output.
- DURABLE RUN STATE: write a run report to
  `~/.devsetup/runs/<UTC-timestamp>-claude-code.md` (plan, before/after inventory,
  every file + key changed, every backup path, the owned-keys table,
  deferred/failed items) and append to `~/.devsetup/backups.manifest`. Phase 0
  reads prior reports — re-verify, don't re-derive.
- FAILURE BEHAVIOR: a failed unit stops cleanly (config valid, fully written or
  fully untouched), is recorded with the exact error, and independent units
  continue. The end report separates DONE / FAILED / DEFERRED.
- RULE BUDGET: every artifact this setup creates (hook, skill, agent, allowlist
  entry, CLAUDE.md line) cites the failure mode it blocks or the repeated workflow
  it serves. No speculative scaffolding — an unused mechanism is debt, not value.

## Phase 0 — Detect & inventory (READ-ONLY)

Report: `claude --version`, `claude doctor` health, auth mode + plan/tier (e.g.
via `/status` — subscription vs API key gates model and long-context
availability), OS/shell. Inventory every scope and artifact: `~/.claude/settings.json`,
`~/.claude.json`, `~/.claude/CLAUDE.md`, `~/.claude/agents/`, `~/.claude/skills/`,
any legacy commands directory the installed version honors (`~/.claude/commands/`;
a project's `.claude/commands/` only when I name a project),
installed plugins + marketplaces, MCP servers and their scopes, hooks, statusline,
the current default model, auto-memory state, and existing
`~/.claude/projects/*/memory/` content. Produce a desired-vs-current action column
per SPEC item. If a prior run report exists, summarize its end state first.

## Phase A — Best-practice review & SELF-EVOLVE (every run, BEFORE the plan)

Critically evaluate whether anything in THIS prompt is stale for the installed
version: read the current docs and release notes — model lineup and aliases,
context options and their plan gating, the memory mechanism, hook events,
permission-rule syntax, sandbox capabilities, and new power-user features worth
adopting. Standing re-evaluation candidates: is the SPEC's "strongest model"
resolution still right; did the evergreen alias (`best` at authoring time) change
semantics; did auto-memory's enablement or load limits move; is there a new hook
event or sandbox capability that turns one of my prose habits into a mechanical
gate. If you find drift or better options: stop, explain each with tradeoffs,
propose an updated version of this prompt (bump the header), and proceed only
after I approve. If nothing is stale, say so in one line and continue.

## Phase B — Interview (one batch, short)

Ask only what Phase 0 couldn't answer:

- Plan/tier if not detectable — it gates long-context availability and cost.
- The 3–5 workflows I repeat most across projects (skill/plugin candidates —
  beyond the SPEC's standing skills, which are already decided) and the
  integrations I actually use (MCP candidates). Propose; don't pre-install.
- Past pain: incidents where the agent did something I had to undo. Permission
  denies and hook guards are seeded from THESE answers, never from guesses.
- Preferences with no safe default: telemetry posture, transcript retention
  (`cleanupPeriodDays`), commit co-authorship attribution (`includeCoAuthoredBy`).

## Phase 1 — Model, context, reasoning

Required outcome (SPEC): every new session starts on the strongest model available
to this account, with the largest context that model supports, and the statusline
makes the active model visible at a glance.

Mechanism — as verified at authoring time, re-verify per Phase A:

- Set the persistent default via the `model` key in user settings (on current
  versions an in-session `/model` choice persists to user settings; env var and
  CLI flag override per session). Prefer an **evergreen alias** if the installed
  version has one whose semantics match the SPEC — at authoring time `best`
  resolves to the strongest generally-available model — so the default tracks new
  releases without re-running this setup. Confirm on THIS account what the alias
  resolves to and that the resolution carries the largest available context: at
  authoring time the frontier model runs a 1M-token window natively, while earlier
  strong models take an explicit `[1m]` suffix (e.g. `opus[1m]`, `sonnet[1m]`)
  whose availability is plan-gated. If no alias carries the largest context, set
  the explicit suffixed model id instead and record that evergreen tracking was
  traded for context — re-runs re-check whether an alias can take over.
- If strongest-available and largest-context ever diverge on this account (the
  strongest model capping below an older model's 1M variant): surface the
  tradeoff with cost notes and let me pick the default; the non-default becomes a
  one-command switch (a documented `/model` invocation or shell alias, recorded
  in the run report) so Phase 6 can verify it. Never silently pick either.
- Configure a fallback model (`fallbackModel` where supported — a chain where the
  mechanism allows) so provider incidents degrade to the next-strongest model
  instead of blocking work.
- Statusline: author the version's documented statusline mechanism (a minimal
  script printing at least the active model — verify the settings key) so the
  visibility outcome below has an authoring step, not just a check.
- Reasoning/effort: leave adaptive reasoning defaults alone unless the docs
  expose an effort control that materially fits my usage; if a fixed
  thinking-budget mechanism applies to the chosen model, set it deliberately and
  record why. Don't max every dial — record the cost implications of every
  Phase 1 choice in the run report.

VERIFY: a fresh probe session reports the intended model (and its context window
per the docs) via `/status` or equivalent, and the statusline shows it. Verifying
the configured identifier is sufficient — do not burn a >200K-token workload just
to prove the window.

## Phase 2 — Memory & instruction files

- AUTO-MEMORY ON (SPEC). At authoring time it is on by default with opt-outs
  (an `autoMemoryEnabled` settings key; a disable env var) — required outcome: no
  scope disables it, and after a session does real work the project's memory
  directory (`~/.claude/projects/<project>/memory/`) gains a `MEMORY.md` that
  auto-loads next session. Verify by probe, not by reading docs alone.
- Engineer around the loader's limits: only the index's first ~200 lines / 25KB
  auto-load (verified at authoring time — re-check), topic files load on demand.
  Seed no content; confirm the limit and record it in the run report so curation
  habits — short index, topic files, archive aggressively — have a stated reason.
- `~/.claude/CLAUDE.md` (user-global, loads into EVERY session): reconcile to a
  two-minute read. Only cross-project conventions I confirm in the interview —
  every line costs attention in every future session. Anything project-shaped
  belongs to the project-system prompts instead.

## Phase 3 — Permissions, hooks, sandbox — mechanical gates

Mindset (shared with the system prompts): a gate that blocks a failure beats a
paragraph asking for care; every gate cites its failure mode; the set stays small.

- **Default mode (SPEC: automode):** sessions default to auto-accept edits
  (`permissions.defaultMode: "acceptEdits"` at authoring time — verify key and
  value names). On current versions this auto-approves in-scope file edits and a
  small set of filesystem commands, while protected paths (VCS internals,
  `.claude/`, env/credential files) still prompt, deny/ask rules still bind, and
  arbitrary commands still prompt unless allowlisted. Confirm those boundaries
  against the installed version's docs and state them in the run report — they
  are the reason this posture is acceptable at all.
- **Permissions:** with per-edit prompts off, the rule lists are the control
  surface, so they get engineering attention first. Allowlist from observed
  friction, not speculation — the read-only operations I approve constantly
  (status/log/diff-class VCS reads, file listing and reading, package-manifest
  queries), in the current rule syntax (`Bash(git status:*)`-style at authoring
  time — verify). Deny-or-ask: the destructive classes from my interview answers
  (history rewrites, recursive deletes outside a repo, credential-file reads,
  force pushes) — these still bind in auto-accept mode, which is exactly why they
  must be explicit rules rather than left to per-action prompts.
- **Hooks:** propose only hooks traceable to a real failure mode I've named —
  e.g. a PreToolUse guard refusing force-push/history-rewrite on shared branches;
  a PostToolUse formatter only if my stack has exactly one canonical formatter.
  Each hook ships with the failure it blocks, a positive test (it fires) and a
  negative test (it doesn't over-fire). Validate hook config against the current
  events list before writing — broken hook config can wedge every session.
- **Sandbox:** if the installed version supports sandboxed execution, prefer it
  on, with the documented escape hatch noted in the run report — a mechanical
  boundary underneath the permission prompts.

## Phase 4 — Subagents, skills, plugins

- **Reviewer subagent (SPEC):** ensure a global read-only code-reviewer exists
  under `~/.claude/agents/` — read-only tools, strongest model, an explicit
  "never edits, never runs jobs" charter, frontmatter per the current agent
  format. Projects built by the system prompts generate their own tailored
  reviewers; the global one is the floor for everything else. (Projects built
  from `setup-ml-research-system.md` expect the global name
  `scientific-code-reviewer` — ask me before creating or renaming under it.)
- **Skills:** the SPEC's standing skills plus the interview's repeated workflows —
  nothing speculative. Interview-derived skills that never fire are pruned at
  re-runs; standing skills are SPEC-fixed — report disuse, never prune them.
  Personal skills at `~/.claude/skills/<name>/SKILL.md` per the current format
  (arguments via the documented convention — `$ARGUMENTS` / indexed / named
  frontmatter at authoring time, verify; set `argument-hint` for
  discoverability — it is UI-only, not parsing), each with a concrete trigger
  description.
- **Reconcile existing commands — never duplicate, never bulldoze.** Inventory
  every existing custom command and skill, including any legacy commands
  directory the installed version still honors (at authoring time
  `.claude/commands/*.md` and its user-scope equivalent still work, and a
  same-named skill silently takes precedence — the shadowing trap). For each one
  that a SPEC standing skill or interview workflow supersedes: keep its NAME and
  invocation habits, port its content into the current skill format upgraded to
  the SPEC's definition, show me the old-vs-new diff for approval, then retire
  the old file non-destructively — rename it to its timestamped `.bak` (the
  backup IS the retirement; nothing is deleted, and the vacated path goes into
  `backups.manifest`) so exactly one implementation answers the name — and
  record the migration in the run report. My existing prompt text is owner
  content — improve it, never discard it silently; ported skills remain owner
  content, and re-runs change them only via approved diffs.
- **Plugins:** browse marketplaces only for gaps the interview surfaced; every
  install passes the supply-chain rule (a plugin can bundle skills, agents,
  hooks, and MCP servers — review what it ships, not just its name); prefer few
  and first-party; uninstall on disuse at re-runs.

## Phase 5 — MCP servers

Only the integrations I named in the interview. Add at the right scope (`user`
for personal; project scopes belong to the project prompts) via the current
mechanism (`claude mcp add` / config file at authoring time). Secrets via
`${VAR}` env expansion; OAuth where offered; read-only tokens where the provider
supports them. A remote server sees whatever the session sends it, and its tool
output enters my context — treat third-party MCP content as untrusted input,
prefer official servers, and record each server's data exposure in the run
report.

## Phase 6 — Verify & report

- FIXTURE RULE: every probe that exercises a gate, an edit, or memory runs inside
  a disposable fixture (a scratch directory / throwaway git repo), using the most
  harmless representative of each denied class — a mis-syntaxed rule must not
  execute the destructive operation it was meant to block, and probes must not
  litter a real project.
- Fresh-probe checklist: intended model + context reported; statusline shows the
  model; auto-memory active (memory dir gains content after a real task in the
  fixture); one allowed read-only op runs without a prompt; an in-scope edit
  proceeds without a prompt (automode active); one denied destructive op is
  blocked despite auto-accept; each hook's positive and negative test passes; the
  fallback-model setting is present with the chosen value (config presence is the
  check — real failover can't be live-tested); agents, skills, and plugins are
  listed and loadable; each SPEC standing skill resolves under its final name as
  recorded in the run report's migration entry, with exactly one implementation
  answering that name across personal skills, legacy commands, and
  plugin-shipped skills; the deep-research skill body contains the current
  orchestration trigger (or invokes the wrapped official capability); every MCP
  server connects.
- EMIT A DOCTOR SCRIPT: every non-interactive check above goes into
  `~/.devsetup/verify-claude-code.sh` so harness health is re-checkable without
  this prompt. Run it once; it must pass. Checks that are inherently interactive
  (statusline appearance, in-session commands) are listed in the run report as
  manual steps with expected outcomes.
- CONVERGENCE CHECK: simulate an immediate second run; it must report zero
  changes needed. Any non-converged unit is an idempotency bug — fix it now.
- Write the run report per the DURABLE RUN STATE rule, separated
  DONE / FAILED / DEFERRED, including the owned-keys table and Phase 1's cost
  notes.

---

## SPEC — fixed choices and required outcomes

(The choices are mine and fixed; the mechanisms were verified 2026-06-10 and must
be re-verified at run time.)

- **Model:** the strongest model available to this account, as the persistent
  default. Evergreen alias preferred once its semantics are confirmed (at
  authoring time `best` = strongest generally-available model).
- **Context:** the largest window the default model supports — at authoring time
  the frontier model runs 1M natively; earlier strong models take the `[1m]`
  suffix, plan-gated. On any strongest-vs-longest divergence: surface it, ask,
  and configure the non-default as a named switch.
- **Fallback:** a fallback model (chain where supported) to the next-strongest.
- **Auto-memory:** ON at user scope; re-runs flag any scope that disables it.
- **Statusline:** always displays the active model — a wrong-model session must
  be visible at a glance.
- **Posture (automode):** sessions default to auto-accept edits
  (`defaultMode: acceptEdits` at authoring time); a read-only allowlist broad
  within its classes, every entry still cited; destructive classes explicitly
  deny/ask — they must bind despite auto-accept;
  sandbox on where supported. With per-edit prompts off, gates and hooks are the
  primary defense and get first-class tests. Full-bypass mode comes only from me
  launching with it deliberately, never from configuration.
- **Reviewer:** a global read-only reviewer subagent exists at user scope — the
  floor reviewer for projects without a tailored one.
- **Plugins & MCP:** interview-gated and supply-chain-vetted (source, author, and
  data exposure recorded), at user scope, secrets via `${VAR}` only; pruned on
  disuse at re-runs.
- **Standing skills** (fixed personal skills; ensure they exist at user scope
  and reconcile any existing same-purpose command per Phase 4, preserving my
  names):
  - `/deep-research <question>` — multi-source research: fan-out searches,
    adversarial verification of claims against independent sources, synthesis
    with citations. If the installed version ships an official deep-research
    capability, prefer or wrap it rather than reimplementing. When
    self-authoring, the skill runs under the harness's workflow orchestration —
    at authoring time skill frontmatter CANNOT set ultracode (valid efforts stop
    at `max`); the skill BODY carries the `ultracode` keyword and orchestration
    instructions instead. Verify the current mechanism.
  - `/review-paper <venue> <paper>` — conference-judge review for RecSys, CIKM,
    KDD, NeurIPS, ICML, SIGIR (keep my existing review command's name if one
    exists; paper = a file path, URL, or arXiv id — read or fetch it before
    judging). Three stages:
    1. *Form.* Resolve the venue's current review form and platform at
       invocation — most of my venues run EasyChair (overall score on the
       venue's scale with its labels, reviewer confidence, free-text body);
       others use OpenReview-style structured forms (summary, strengths,
       weaknesses, questions, limitations, per-axis scores). Render the review
       paste-ready for that form; if the form can't be verified, use the
       generic structure in stage 3 and say so — never fabricate a form.
    2. *Novelty via research.* The novelty/contribution judgment is
       research-backed, not text-only: run the deep-research skill (or an
       inline scoped search) over the paper's core claims — closest prior art,
       whether a claimed contribution already exists, missing citations or
       stronger baselines the authors should have compared against. Cite what
       the search actually found (real venues and years only); if search is
       unavailable, label the novelty assessment "text-only — prior art
       unverified" rather than guessing.
    3. *Judgment.* Structured output (summary, contributions, strengths,
       weaknesses, questions for authors, scores + confidence in the venue's
       conventions); grounded in the paper's actual text — quote what it
       judges, fabricate no citations; and always audit evaluation rigor
       (baseline comparability, split/leakage risks, seeds and significance,
       ablation coverage, effect sizes) — the same false-win failure modes my
       research protocol defends against.
- **Budget:** user-global `CLAUDE.md` stays a two-minute read; every hook, skill,
  agent, and allowlist entry cites its failure mode or workflow; re-runs prune
  the ones that never fire (standing skills exempt — disuse is reported, never
  auto-pruned).
