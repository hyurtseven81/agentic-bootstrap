# Setup Prompt — Claude Code Harness Configuration

> **Prompt version: v8 (2026-09-12)** — bump on every amendment; cite the lesson or
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
three system prompts (`setup-ml-research-system.md`, `setup-engineering-system.md`,
`setup-autonomous-goal-loop.md`) build per-project process on top, and the workflow
prompts (`kickoff-spec-first-project.md`, `review-plan-blind.md`,
`run-plan-stepwise.md`) run beside them. A project-level concern discovered here
gets noted for those prompts, not configured globally.

## Source of truth

This command file IS the source of truth — no external dotfiles repo or sync
service. The SPEC at the bottom defines my fixed choices and required outcomes.
Author the config to satisfy the SPEC using the harness's CURRENT documented
mechanisms: the specifics in this prompt were verified against the official docs
on 2026-09-12, and the harness ships frequently — on any mismatch the current
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
`~/.claude.json`, `~/.claude/CLAUDE.md`, `~/.claude/rules/`, `~/.claude/agents/`,
`~/.claude/skills/`, the plans directory (`plansDirectory`),
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
  (`cleanupPeriodDays`), commit and PR attribution (the `attribution` key at
  authoring time; `includeCoAuthoredBy` is its deprecated predecessor).

## Phase 1 — Model, context, reasoning

Required outcome (SPEC): every new session starts on the strongest model available
to this account, with the largest context that model supports, and the statusline
makes the active model visible at a glance.

Mechanism — as verified at authoring time, re-verify per Phase A:

- Set the persistent default via the `model` key in user settings (an in-session
  `/model` choice persists there; `s` in the picker applies to the session only; env
  var and CLI flag override per session). Prefer an **evergreen alias** if the
  installed version has one whose semantics match the SPEC — at authoring time `best`
  resolves to Fable when the account has it, else Opus — so the default tracks new
  releases without re-running this setup. Confirm on THIS account what the alias
  resolves to and that the resolution carries the largest available context: at
  authoring time Fable, Sonnet 5, and Opus 4.7 and later run a 1M-token window
  natively, and only older models take an explicit `[1m]` suffix (e.g. `opus[1m]`),
  plan-gated. If no alias carries the largest context, set the explicit suffixed
  model id instead and record that evergreen tracking was traded for context —
  re-runs re-check whether an alias can take over. Record what the `default` alias
  means on this plan, since it differs by plan.
- If strongest-available and largest-context ever diverge on this account (the
  strongest model capping below an older model's 1M variant): surface the
  tradeoff with cost notes and let me pick the default; the non-default becomes a
  one-command switch (a documented `/model` invocation or shell alias, recorded
  in the run report) so Phase 6 can verify it. Never silently pick either.
- Configure a fallback chain (`fallbackModel`, an ordered array of up to three
  models at authoring time; the whole array is taken from the highest-precedence
  settings file, so set it in one place) so provider incidents degrade to the
  next-strongest model instead of blocking work. Note the separate content-based
  fallback (`switchModelsOnFlag`, on by default) that can move a Fable session to
  Opus mid-session — one more reason the statusline must show the live model.
- Statusline: author it via the `statusLine` key (`type: command` plus a script
  that reads the session JSON on stdin — `model.display_name`,
  `context_window.used_percentage`, `effort.level` at authoring time; `/statusline`
  can generate the script) so the visibility outcome below has an authoring step,
  not just a check.
- Reasoning/effort: effort is a first-class control at authoring time (`effortLevel`,
  a per-model `modelSettings` form, a `maxEffortLevel` cap, `/effort` in session, and
  `effort:` frontmatter on skills and subagents). Set the default deliberately and
  record why; leave extended-thinking toggles alone unless the docs expose one that
  materially fits my usage. Don't max every dial — record the cost implications of
  every Phase 1 choice in the run report.

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
- LAYER instructions; don't accumulate them. The always-loaded file is ADVISORY —
  delivered as ordinary conversation content, not as enforcement — and an overstuffed
  one is documented to REDUCE rule-following rather than increase it, which is the
  whole reason Phase 3's gates exist. Confirm the version's current documented size
  target and its context-inspection command (at authoring time: a couple hundred lines
  per memory file, and a `/context`-class command reporting what actually loaded),
  record both in the run report, then route by layer: a repeated multi-step procedure
  becomes a skill (Phase 4 — loads on demand); a rule a script can check becomes a
  hook or permission rule (Phase 3); only always-true cross-project conventions stay
  in the file. Run the harness's trim diagnostic (`/doctor` proposes cuts of content
  derivable from the codebase at authoring time) and show me its proposed cuts as a
  diff — trims are MY lines, so they need my approval like any other. Record the
  loader properties too, because they decide what is safe to put where — at
  authoring time: the
  project-root file is re-read and re-injected after a compaction, while nested files
  and path-scoped rules reload only when a matching file is touched (so anything that
  must survive a compaction belongs in the root file or a gate); import directives
  expand at load and organize text without saving context; `.claude/rules/` and
  `~/.claude/rules/` hold topic files, path-scoped via `paths:` frontmatter;
  block-level HTML comments are stripped before injection; and an
  instructions-loaded hook event can log exactly what loaded and why. Verify each
  against the installed version.

## Phase 3 — Permissions, hooks, sandbox — mechanical gates

Mindset (shared with the system prompts): a gate that blocks a failure beats a
paragraph asking for care; every gate cites its failure mode; the set stays small.

- **Default mode (SPEC: no per-edit prompts):** two harness modes satisfy the SPEC's
  posture at authoring time, and which one I run is a recorded decision, not a
  default you pick. `acceptEdits` auto-approves in-scope file edits and a small set
  of filesystem commands and prompts for everything else unless allowlisted —
  deterministic. `auto` adds a classifier that reviews shell and network actions
  instead of me; deny and ask rules, protected paths and critical paths still bind;
  it is the harness's built-in starting mode on Pro, Max and Team plans, it takes
  effect only from user or managed settings, and the harness offers once to switch
  a non-auto default to it. Ask me once, record the choice and its reason in the run
  report, and default to `acceptEdits` unless I opt in. Either way, state the
  boundaries that still prompt — they are the reason the posture is acceptable at
  all. Record `dontAsk` as the mode for unattended drivers the project prompts
  build: it auto-denies anything that would prompt, including the ask-the-user
  tool, which is the mechanical form of "never stop for permission".
- **Plan mode is the no-prompt posture's counterweight, and it is a permission mode
  rather than a habit:** with per-edit prompts off, the cheap way to stop a
  non-trivial change starting in the wrong direction is a read-only planning pass
  that produces a
  reviewable plan before anything is written — and, where the version persists plans
  to a file, an artifact that survives a context clear so the work can be executed
  against it rather than against my memory of the conversation. Record its current
  invocations (at authoring time: the mode cycle, a `/plan` prompt prefix, and
  `--permission-mode plan`; approving a plan exits to the mode the approve option
  names; plans persist under `plansDirectory` — verify) in the run report, along
  with the documented advice NOT to use it for one-line diffs, where it is pure
  overhead. Verify the gate in the *headless* form
  too, if anything here will drive one: probe whether a non-interactive session can
  leave plan mode without a human answering — an open-source harness integration
  reports that headless plan mode self-approved its own exit on the version it
  tested, and had to force an `ask` through a PreToolUse hook routed to a
  permission-prompt tool. Record what the installed version does; a plan gate that
  holds only interactively is a comment. A headless run answers prompts only through
  `--permission-prompt-tool`; without one, blocked actions are dropped and the run
  continues.
- **Permissions:** with per-edit prompts off, the rule lists are the control
  surface, so they get engineering attention first. Allowlist from observed
  friction, not speculation — the read-only operations I approve constantly
  (status/log/diff-class VCS reads, file listing and reading, package-manifest
  queries), in the current rule syntax (`Bash(git status *)`-style at authoring
  time; the `:*` suffix is still accepted at the end of a rule, and wrappers such as
  `timeout` and safe env assignments are stripped before matching — verify).
  Deny-or-ask: the destructive classes from my interview answers (history rewrites,
  recursive deletes outside a repo, credential-file reads, force pushes) — these
  still bind in either no-prompt mode, which is exactly why they must be explicit
  rules rather than left to per-action prompts. A Bash deny does not match a program
  invoked by path or inside `sh -c`, so credential reads get `Read(./.env)`-style
  rules plus the sandbox's credential entries, network denies pair with the sandbox
  domain allowlist, and `permissions.blockReadsOutsideWorkingDirectories` fences the
  file tools in every mode.
- **Hooks:** propose only hooks traceable to a real failure mode I've named —
  e.g. a PreToolUse guard refusing force-push/history-rewrite on shared branches;
  a PostToolUse formatter only if my stack has exactly one canonical formatter; a
  Stop hook that refuses to end a turn while a project ledger has open steps (the
  premature-end gate the project prompts want); a PreCompact hook that persists
  state; a PreModelSwitch hook that blocks a downgrade below the SPEC model. The
  event list is long at authoring time (session, prompt, tool, permission,
  compaction, model-switch, subagent, worktree and config events) and a handler can
  be a command, an HTTP call, an MCP tool, a prompt, or an agent, with an inline
  `if` matcher and exit code 2 as the block. Each hook ships with the failure it
  blocks, a positive test (it fires) and a negative test (it doesn't over-fire).
  Validate hook config against the current events list before writing — broken
  hook config can wedge every session.
- **Sandbox:** prefer it on — a mechanical boundary underneath the permission
  prompts. At authoring time: `sandbox.enabled`; `allowUnsandboxedCommands: false`
  is strict mode (otherwise the harness may retry a blocked command outside the
  sandbox through the regular permission flow — note the escape hatch either way);
  `failIfUnavailable` for a hard failure; `network.allowedDomains`, `deniedDomains`
  and `strictAllowlist`; `credentials.files` and `credentials.envVars` with `deny`
  or `mask` entries, which is where credential protection actually binds. macOS
  needs nothing installed; Linux and WSL2 need `bubblewrap` and `socat` plus an
  optional seccomp filter, provisioned by the machine prompt — `/sandbox` shows
  what is missing; native Windows has no sandbox.

## Phase 4 — Subagents, skills, plugins

- **Reviewer subagent (SPEC):** ensure a global read-only code-reviewer exists
  under `~/.claude/agents/` — read-only tools (`tools: Read, Grep, Glob` at
  authoring time), strongest model (`model: fable` or `inherit`), an explicit
  "never edits, never runs jobs" charter, frontmatter per the current agent
  format. Worth setting deliberately at authoring time: `memory: user` so it
  accumulates patterns across projects, `maxTurns` as a cost cap, and
  `isolation: worktree` when a review must not see uncommitted edits; a subagent
  never inherits the parent transcript or auto memory but does load CLAUDE.md.
  Projects built by the system prompts generate their own tailored reviewers; the
  global one is the floor for everything else. (A user-global reviewer may already
  exist under a name of mine — e.g. the legacy `scientific-code-reviewer`; keep the
  name and ask before renaming.)
- **Skills:** the SPEC's standing skills plus the interview's repeated workflows —
  nothing speculative. Interview-derived skills that never fire are pruned at
  re-runs; standing skills are SPEC-fixed — report disuse, never prune them.
  Personal skills at `~/.claude/skills/<name>/SKILL.md` per the current format
  (arguments via `$ARGUMENTS` / `$0` / named `arguments` at authoring time, verify;
  set `argument-hint` for discoverability — it is UI-only, not parsing; `effort:`
  and `model:` override per turn; `context: fork` with `agent:` runs the skill in
  a history-free subagent, which is the harness form of the blind review the
  project prompts ask for), each with a concrete trigger description. Personal
  skills do not load in cloud or Cowork sessions unless synced from the claude.ai
  account — record which surfaces each standing skill actually reaches.
- **Reconcile existing commands — never duplicate, never bulldoze.** Inventory
  every existing custom command and skill — personal skills, legacy commands,
  plugin-shipped skills, and the harness's own **bundled** skills and built-in
  commands, which is the layer that actually collides: plugin skills are
  namespaced and cannot conflict, while a same-named personal or project skill
  silently overrides a bundled one, and a built-in command may win outright. Include
  any legacy commands directory the installed version still honors (at authoring
  time `.claude/commands/*.md` and its user-scope equivalent still work, and a
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
  fixture); the user-global instruction file is within the version's documented size
  guidance and the context-inspection command shows it loading with nothing unexpected
  beside it; `/sandbox` reports no missing dependency on Linux/WSL2; one allowed
  read-only op runs without a prompt; an in-scope edit proceeds without a prompt
  (the chosen no-prompt mode active); one denied destructive op is blocked despite
  the no-prompt mode; each hook's positive and negative test passes; the
  fallback-model setting is present with the chosen value (config presence is the
  check — real failover can't be live-tested); agents, skills, and plugins are
  listed and loadable; each SPEC standing skill resolves under its final name as
  recorded in the run report's migration entry, with exactly one implementation
  answering that name across personal skills, legacy commands, plugin-shipped
  skills, and the harness's bundled skills and built-in commands (record which
  native, if any, a kept name shadows); the deep-research skill body contains the
  current orchestration trigger (or defers to the official capability); every MCP
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

(The choices are mine and fixed; the mechanisms were verified 2026-09-12 and must
be re-verified at run time.)

- **Model:** the strongest model available to this account, as the persistent
  default. Evergreen alias preferred once its semantics are confirmed (at
  authoring time `best` = Fable when the account has it, else Opus).
- **Context:** the largest window the default model supports — at authoring time
  Fable, Sonnet 5, and Opus 4.7 and later run 1M natively; older models take the
  `[1m]` suffix, plan-gated. On any strongest-vs-longest divergence: surface it, ask,
  and configure the non-default as a named switch.
- **Fallback:** an ordered fallback chain (the `fallbackModel` array) to the
  next-strongest.
- **Auto-memory:** ON at user scope; re-runs flag any scope that disables it.
- **Statusline:** always displays the active model — a wrong-model session must
  be visible at a glance.
- **Posture (no per-edit prompts):** sessions default to a mode with per-edit
  prompts off — `acceptEdits` unless I opt into the harness's classifier-reviewed
  `auto` mode at the Phase 3 decision, recorded either way; a read-only allowlist
  broad within its classes, every entry still cited; destructive classes explicitly
  deny/ask — they must bind in either mode; sandbox on where supported. With
  per-edit prompts off, gates and hooks are the primary defense and get first-class
  tests. Full-bypass mode comes only from me launching with it deliberately, never
  from configuration; unattended drivers built by the project prompts run in
  `dontAsk`.
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
    capability, prefer it — a same-named personal skill *overrides* the bundled
    one rather than wrapping it, so keeping my name means the run report records
    which bundled capability it shadows and why the local version is better. When
    self-authoring, the skill runs under the harness's workflow orchestration —
    at authoring time skill frontmatter `effort:` stops at `max`, ultracode is a
    settings key and a keyword the orchestration looks for in the prompt, and the
    skill BODY carries the keyword and orchestration instructions. Verify the
    current mechanism.
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
