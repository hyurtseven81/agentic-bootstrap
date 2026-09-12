# Setup Prompt — Workstation: Dev Machine and Claude Code Harness

> **Prompt version: v9 (2026-09-12)** — bump on every amendment; cite the lesson or
> incident that motivated it in the commit message. Numbering continues from
> `setup-claude-code.md` (v8), which this file absorbs together with
> `setup-dev-machine.md` (v3). Phase A re-evaluates this file every run and proposes
> amendments when stale; after approval, backport them to the canonical copy in the
> prompts repo.

**How to use:** open an agent session (Claude Code or equivalent, strongest available
model) on the target machine, in any directory, and paste this entire prompt. It has
two parts that share one inventory, one self-evolution pass, and one run report:
**Part I** provisions the OS and toolchain (Phases 1–9); **Part II** configures the
Claude Code harness at user scope (Phases H0–H6). Both are idempotent, so re-running
the whole prompt after only the harness changed reports zero machine changes and
moves on. Approvals stay ON by design for this run — the agent inventories, plans,
asks, then acts; the no-prompt posture Part II *configures* is for later sessions,
and regardless of when a written mode change takes effect, this run keeps asking
before every mutating unit.

You are provisioning MY dev environment. Target may be:
- macOS (local desktop)
- Linux (local desktop OR a remote Amazon dev-dsk: headless, behind a corporate egress proxy)
- Windows (native), OR Windows running this inside WSL2 (treat WSL2 as Linux)

Works on a FRESH machine or one already partly set up — detect, then install-or-update.

## Source of truth

This command file IS the source of truth. Do NOT depend on any external dotfiles
repo, remote, or sync service. The two SPEC sections at the bottom define my fixed
choices and required outcomes — the machine SPEC and the harness SPEC. Author each
config to satisfy its SPEC using CURRENT best practice and the harness's CURRENT
documented mechanisms at run time; do not freeze a specific implementation if a
better current mechanism exists (raise it in Phase A). The harness specifics in Part
II were verified against the official docs on 2026-09-12, and the harness ships
frequently — on any mismatch the current docs win, and Phase A reports the drift.
Never write a settings key, model name, or feature flag you have not confirmed
against the installed version's docs or `--help` output. When a config already
exists, back it up and reconcile it toward the spec, preserving my intentional local
additions — if a conflict is ambiguous, show me the diff and ask. Never push anything
to any remote.

## Hard rules

- IDEMPOTENT and re-runnable. Detect current state before changing anything; a
  second run immediately after a successful one must report zero changes needed.
- BACK UP before overwriting any config (timestamped `.bak`). NEVER delete my files;
  never touch managed/enterprise scope.
- Show me a PLAN — per unit; for settings files per file, per key, with scope — and
  wait for confirmation before the first mutating step.
- NO sudo / admin / system-package changes without showing the exact command and
  asking. (I keep approvals ON by design. If I want hands-off I'll launch you with
  skip-permissions.)
- MANAGED BLOCKS: every config section you author in a shell or tool config lives
  between marked sentinels — `# >>> devsetup:<unit> >>>` … `# <<< devsetup:<unit> <<<`
  (comment syntax per file format) — and in Markdown artifacts (`~/.claude/CLAUDE.md`)
  between HTML-comment sentinels, one block per unit. Re-runs replace the block
  content in place; everything outside the blocks is MINE and is preserved untouched;
  changes to MY lines happen only through a diff I approve. Never raw-append (`>>`);
  if you find a prior hand-applied append that a block supersedes, absorb it into the
  block and remove the duplicate (with my approval on the diff).
- JSON DISCIPLINE: settings files are parsed, not templated. Validate every write
  (`jq` or equivalent) before and after; PRESERVE every key you don't manage —
  reconcile, never regenerate a file wholesale. JSON carries no comments, so the run
  report (not the file) records each key this setup owns, its value, and why.
- NARROWEST SCOPE: personal defaults at user scope (`~/.claude/settings.json`);
  project scope only when I name a project; `settings.local.json` for experiments.
- DURABLE RUN STATE: every run writes a report to `~/.devsetup/runs/<UTC-timestamp>.md`
  covering both parts (plan, inventory before/after with versions, every file created
  or changed with its unit name, every settings key changed and the owned-keys table,
  every backup with its path, every substitution, every deferred/failed item) and
  appends to `~/.devsetup/backups.manifest`. Phase 0 reads prior reports if present —
  don't re-derive what a previous run already established, but re-verify it.
- SUPPLY CHAIN: prefer the platform package manager (or mise) over vendor install
  scripts. Never execute a piped `curl | sh` blind — download the script, tell me what
  it does and where it's from, run only after approval; verify checksums/signatures
  where the project publishes them. Plugins, marketplaces, MCP servers, and hooks are
  code that runs with my permissions: before installing any, name the source, the
  author, what it executes, and what data it can see; no blind installs; prefer
  official / first-party sources; pin where the mechanism allows. Record the install
  source per tool in the run report. Secrets only via env expansion (`${VAR}`) — never
  literal in any config file.
- Respect the corporate proxy. If a download is blocked, DO NOT work around it
  silently — report the exact tool + error and propose options (set http(s)_proxy, or
  install via system/internal mirrors and point configs at the existing binary). If
  you hit TLS errors behind the proxy, that is usually a corporate MITM root CA — the
  fix is adding the corporate CA to the relevant trust stores (npm `cafile`, pip/uv
  cert config, git `http.sslCAInfo`, curl `CURL_CA_BUNDLE`). NEVER disable TLS
  verification anywhere, even "temporarily."
- Detect HEADLESS vs GUI. GUI apps install on local desktops ONLY; skip on headless
  remotes (there, the VS Code server auto-installs on connect — nothing to do).
- No secrets in any file you write. If you encounter a live credential, warn me.
- "Author to satisfy the spec, then VERIFY." Never assume an outcome — prove each one
  with the stated check (for the harness, in a fresh probe session) before reporting
  success. Report failures as failures, with output — never round a partial result
  up to success.
- FAILURE BEHAVIOR: if a step fails mid-phase, stop that unit, leave the machine in a
  consistent state (block fully written or fully untouched, config valid — no
  half-edits), record the failure + exact error in the run report, and continue with
  independent units. The end report separates DONE / FAILED / DEFERRED; a re-run picks
  up the failed units.
- UPSTREAM-BUG WORKAROUNDS: when a config exists only to route around a known upstream
  bug (terminal, multiplexer, LSP, harness, etc.), you MUST:
  (1) prefer the upstream FIX first — upgrade the tool to a release where it's
      resolved — and fall back to a workaround ONLY if the installed/available
      version is still affected;
  (2) GATE the workaround on a detected version/condition so it becomes a no-op once
      the bug is gone (never an unconditional append);
  (3) ANNOTATE it inline with the upstream issue URL, the affected version range, and
      an explicit "remove when ..." condition;
  (4) keep it IDEMPOTENT and de-duplicated — author it into a managed block, never a
      raw `>>` append.
- RULE BUDGET: every artifact this setup creates (hook, skill, agent, allowlist
  entry, CLAUDE.md line, shell alias, workaround) cites the failure mode it blocks or
  the repeated workflow it serves. No speculative scaffolding — an unused mechanism
  is debt, not value.

## Phase 0 — Detect & inventory (READ-ONLY)

Machine: ## Phase 0 — Detect & inventory (READ-ONLY)
Report: OS + distro/version, arch, GUI-vs-headless, native-Windows-vs-WSL2, shell, and
proxy status (test reachability to github.com, registry.npmjs.org, pypi.org; note TLS
interception if certificates don't chain to public roots). Read `~/.devsetup/runs/` if
it exists and summarize the last run's end state. Inventory every tool below with
current version + a desired-vs-current action column.

Harness: ## Phase 0 — Detect & inventory (READ-ONLY)

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

Machine: ## Phase A — Best-practice review & SELF-EVOLVE (every run, BEFORE the plan)
Critically evaluate whether anything in THIS command is now outdated or has a better
option for my profile (senior ML/eng, Python-heavy, heavy remote-SSH work). Consult
current release notes / docs / web search where available — do not rely on training
data for version claims. Review categories, explicitly including: core CLI/shell/editor
tooling; data/ML/notebook workflow tooling; repo-hygiene & secret-scanning tooling; and
a cleaner mechanism for any "required outcome." Look for deprecated tools, superseded
defaults, better-maintained alternatives, renamed config keys, and new must-have tools.
Standing re-evaluation candidates (check, don't assume): basedpyright vs newer Python
type checkers (e.g. Astral's `ty` once stable), oh-my-zsh plugin maintenance status,
whether any SPEC workaround's upstream bug is now fixed.
If you find improvements:
1) STOP before mutating anything.
2) Explain each change and WHY, with tradeoffs.
3) Propose an updated version of THIS command file (bump the Prompt version header) for
   my approval.
4) Only after I approve the command changes do you proceed.
If nothing is stale, say so in one line and continue.

Harness: ## Phase A — Best-practice review & SELF-EVOLVE (every run, BEFORE the plan)

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

---

# Part I — Dev machine

## Phase 1 — Package base + BUILD TOOLCHAIN (per platform)
- macOS: Homebrew (install if missing). Ensure Xcode Command Line Tools (clang/make).
- Linux (incl. WSL2): NATIVE package manager (detect apt/dnf/yum/pacman/zypper). Avoid
  Linuxbrew on a managed corporate box unless already present.
- Windows (native): prefer scoop for CLI dev tools (no-admin, brew-like) and winget for
  apps; choco as fallback. Choose per tool availability.
- Prefer mise for language runtimes/CLI where it has solid support on the platform.

CRITICAL — C toolchain prerequisite (Linux/macOS/WSL2): a working C compiler + make +
headers MUST exist before Phase 5, because nvim-treesitter compiles grammars from source
and FAILS without them (this bites on Amazon Linux specifically). Detect gcc/cc/clang and
make; if absent, install the toolchain (e.g. `gcc`, `make`, `glibc`/dev headers — on
Amazon Linux/dnf typically `gcc make`, or the distro's build-essential equivalent). Show
the exact (likely sudo) command and ASK before running. If sudo/egress is blocked, note it
and carry the constraint into Phase 5's fallback logic.

Also the Claude Code sandbox prerequisites, where the platform needs them (the harness
setup prompt VERIFIES them; this prompt installs them): on Linux/WSL2, `bubblewrap` and
`socat` from the native package manager, plus the optional seccomp filter
(`npm install -g @anthropic-ai/sandbox-runtime`) once node exists in Phase 2; on Ubuntu
24.04+ the default AppArmor policy blocks bubblewrap's user namespaces — apply the fix
the sandbox docs describe, and ASK before any sudo. macOS needs nothing (Seatbelt is
built in); native Windows has no sandbox — say so rather than faking it.

## Phase 2 — Runtimes (mise) + uv + direnv
Install/activate mise; install python, node (required for Mason/LSPs), rust. Also install
uv (Astral) as my Python project/dependency/venv manager.
Division of labor (configure to coexist, don't let them fight):
- mise owns base language RUNTIMES.
- uv owns per-project VIRTUALENVS + dependencies.
- direnv (.envrc) is in use — ensure mise + uv + direnv don't clobber each other's env or
  produce double prompts; flag any conflict in the active-Python resolution. State the
  resolution order explicitly in the run report (which tool wins for `python` in a
  project dir vs outside one).
(Windows native: mise/uv support is generally good; for anything mise can't provide, fall
back to scoop/winget and report it.)

## Phase 3 — Shell layer
FIXED CHOICES (preserve behavior across platforms):
- Prompt: starship.
- Modern CLI everywhere it has a native build: fzf, zoxide, eza, bat, fd, ripgrep, delta,
  atuin.
- atuin runs LOCAL-ONLY: no sync login, no remote history upload, unless I explicitly opt
  in. The never-push-to-a-remote rule applies to shell history too.
Platform implementation:
- macOS/Linux/WSL2: zsh + oh-my-zsh. Plugins: git, zsh-autosuggestions,
  fast-syntax-highlighting (sourced LAST), fzf. Set ZSH_THEME="" (starship owns the
  prompt). Keep the TERM-fallback guard (SPEC). Respect oh-my-zsh load order. Edit
  .zshrc via managed blocks.
- Windows (native): NO zsh/oh-my-zsh exist — substitute the best-practice Windows stack:
  PowerShell 7+, PSReadLine (predictive history), Terminal-Icons, zoxide, fzf, and
  starship in the PowerShell profile. Tell me explicitly that this is a substitution,
  not parity.

## Phase 4 — Multiplexer (tmux)
- macOS/Linux/WSL2: require tmux >= 3.2 (spec uses modern features); if the distro ships
  older, install a newer tmux (mise/brew/build) — flag before building. Author config to
  the tmux SPEC, install TPM, run plugin install.
- NOTE the cross-host mouse path (local emulator <-> remote tmux) and the mouse
  Required-outcomes in the tmux SPEC; verify gestures per Phase 9.
- Windows (native): tmux has no native port — SKIP it, and inform me that Windows Terminal
  panes are the local substitute (no session-persistence), and that WSL2 is the route to
  real tmux if I want it. Do not silently fake it.

## Phase 5 — Neovim / LazyVim (all platforms)
Ensure the current STABLE nvim (LazyVim required >= 0.11.2 at authoring time and its
floor moves — check it; prefer latest stable). Install LazyVim (starter) if absent;
respect lazy-lock.json if my config exists. Apply my VS Code-like defaults via
LazyVim's lua/plugins/ override pattern (NEVER edit core files) — see LazyVim SPEC, including the SINGLE-EXPLORER requirement.

Mason LSP/tools: python (basedpyright + ruff), typescript (vtsls + eslint), rust
(rust-analyzer), lua, json, yaml, bash, toml, docker, markdown. Mason pulls from
GitHub/npm/PyPI and may be proxy-blocked — if so, list exactly what failed and propose
proxy/mirror options.

nvim-treesitter (compiles grammars from C source — depends on the Phase 1 toolchain):
- After install, run :TSInstall for my core languages (python, lua, bash, json, yaml,
  toml, markdown, rust, typescript) and require :checkhealth nvim-treesitter to be clean.
- If grammar compilation throws compiler errors (common on Amazon Linux), fix in this
  order, stopping at the first that works:
  1) Ensure the Phase 1 C toolchain is present (gcc/clang + make + headers); retry.
  2) If sudo/egress blocked the toolchain: point nvim-treesitter at whatever compiler IS
     on the box (set require('nvim-treesitter.install').compilers accordingly, e.g.
     clang); retry.
  3) Last resort: configure grammars to avoid local compilation (prebuilt/wasm, or pin to
     grammars that don't need building) so checkhealth is clean.
- Surface any sudo/proxy blocker rather than working around it silently.

Bootstrap headlessly; report installed vs failed; confirm zero Lua errors on startup.

## Phase 5.5 — Data/ML workflow & repo hygiene (headless-safe; all platforms)
These fetch from GitHub releases / PyPI and may be proxy-blocked — surface failures per
the hard rules. All are headless-safe (no GUI).
- duckdb (CLI): SQL over local Parquet/CSV and directly off S3, without spinning up a
  notebook — install the CLI binary.
- jupytext: pair notebooks with plain .py so notebooks version-control cleanly (I keep a
  notebooks/ dir and commit code). Install it and tell me the pairing workflow; do NOT
  modify or re-pair any existing notebooks without asking.
- gitleaks + pre-commit (repo hygiene — directly prevents the kind of token leak I want
  to avoid):
  - Install both as machine-level tools.
  - pre-commit is per-repo: do NOT auto-install hooks into my existing repos. Instead,
    provide a recommended .pre-commit-config.yaml template (ruff lint+format, gitleaks
    secret scan) that I can drop into a repo and `pre-commit install` myself. Offer to
    add it to a specific repo only if I name one.
  - Confirm gitleaks runs standalone (e.g. `gitleaks detect`) as well.

## Phase 6 — git (all platforms)
delta as pager + sensible defaults. Ask for user.name/user.email rather than guessing if
unset.

## Phase 7 — lazygit (all platforms)
Install; confirm it picks up delta/diff config.

## Phase 8 — GUI (LOCAL DESKTOP ONLY — skip if headless)
- macOS/Linux: Ghostty — author config to the Ghostty SPEC (ssh-terminfo, truecolor,
  undercurl, ligatures). A Nerd Font for LazyVim/lualine/neo-tree icons.
- Windows: Ghostty has no native build — install Windows Terminal (baseline) and offer
  WezTerm (cross-platform, GPU-accelerated, closest to Ghostty). Configure truecolor +
  a Nerd Font. Tell me this is the substitution.
- All desktops: VS Code app + Remote-SSH + the Neovim extension.

## Phase 9 — Verify & report
- Re-run inventory; nvim :checkhealth clean (incl. nvim-treesitter, no compiler errors);
  EXACTLY ONE file-explorer sidebar opens; multiplexer loads (where applicable); shell
  starts with no errors; truecolor test passes; uv/duckdb/jupytext/gitleaks/pre-commit
  are installed and runnable (report versions); on Linux/WSL2 the Claude Code sandbox
  prerequisites (bubblewrap, socat) are present.
- EMIT A DOCTOR SCRIPT: write every check above into `~/.devsetup/verify.sh` (or .ps1 on
  native Windows) so the whole verification suite re-runs on demand later — environment
  health must be checkable without re-running this prompt. Run it once; it must pass.
- CONVERGENCE CHECK: simulate (dry-run) an immediate second run of this command. It must
  report ZERO changes needed. Any non-converged unit is an idempotency bug — fix it now,
  don't hand it to the next run.
- Write the run report per the DURABLE RUN STATE rule. List every file created/changed,
  every backup, and what was SUBSTITUTED per platform. Concise final state report,
  separated DONE / FAILED / DEFERRED. No remote push.
- INTERACTIVE mouse smoke test in tmux through the real outer terminal:
  select-pane-by-click, resize-by-border-drag, switch-window-by-status-click. Report
  pass/fail PER GESTURE. This runs from the LOCAL desktop session only — on a headless
  remote, note that the mouse path is local-emulator -> SSH -> remote-tmux and cannot be
  exercised headlessly; defer the gesture check to the next attached local session
  (record it as DEFERRED in the run report) and say so.

---

# Part II — Claude Code harness

## Phase H0 — Interview (one batch, short)

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

## Phase H1 — Model, context, reasoning

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
  in the run report) so Phase H6 can verify it. Never silently pick either.
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
  every Phase H1 choice in the run report.

VERIFY: a fresh probe session reports the intended model (and its context window
per the docs) via `/status` or equivalent, and the statusline shows it. Verifying
the configured identifier is sufficient — do not burn a >200K-token workload just
to prove the window.

## Phase H2 — Memory & instruction files

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
  whole reason Phase H3's gates exist. Confirm the version's current documented size
  target and its context-inspection command (at authoring time: a couple hundred lines
  per memory file, and a `/context`-class command reporting what actually loaded),
  record both in the run report, then route by layer: a repeated multi-step procedure
  becomes a skill (Phase H4 — loads on demand); a rule a script can check becomes a
  hook or permission rule (Phase H3); only always-true cross-project conventions stay
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

## Phase H3 — Permissions, hooks, sandbox — mechanical gates

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

## Phase H4 — Subagents, skills, plugins

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

## Phase H5 — MCP servers

Only the integrations I named in the interview. Add at the right scope (`user`
for personal; project scopes belong to the project prompts) via the current
mechanism (`claude mcp add` / config file at authoring time). Secrets via
`${VAR}` env expansion; OAuth where offered; read-only tokens where the provider
supports them. A remote server sees whatever the session sends it, and its tool
output enters my context — treat third-party MCP content as untrusted input,
prefer official servers, and record each server's data exposure in the run
report.

## Phase H6 — Verify & report

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
  DONE / FAILED / DEFERRED, including the owned-keys table and Phase H1's cost
  notes.

---

## SPEC (machine) — author configs to satisfy this (current best practice; verify each)

### tmux (macOS/Linux/WSL2)
Fixed choices (preserve exact values/behaviors):
- vi copy-mode; `v` begins selection
- mouse on; history-limit 50000; escape-time 0
- base-index 1, pane-base-index 1, renumber-windows on
- focus-events on; report extended keys to TUIs
- allow-passthrough on (kitty graphics / image.nvim over SSH)
- `prefix + r` reloads config with a confirmation message
- TPM plugins: tmux-sensible, resurrect, continuum, yank, fcsonline/tmux-thumbs
- thumbs: hint key `prefix + space`; copy hint to tmux buffer; upcase variant also pastes
- resurrect: capture pane contents = on
- continuum: restore on boot = on; autosave every 15 min
Required outcomes (choose mechanism; VERIFY):
- RGB truecolor passes through for outer TERM = xterm-ghostty AND xterm-256color
  (verify: printf '\x1b[38;2;255;120;0mok\x1b[0m' shows orange inside tmux)
- Colored undercurl reaches nvim diagnostics as a SQUIGGLE, not a flat underline (verify
  in nvim)
- default-terminal resolves to a 256-color tmux entry even AFTER tmux-sensible/TPM load
  (re-assert if a plugin overrides it; verify: tmux show -gv default-terminal)
- MOUSE works end-to-end THROUGH the outer terminal, verified by gesture (these break
  independently of color):
  * click selects a pane
  * drag on a pane border resizes
  * click on the status line switches window
- The mouse path is CROSS-HOST: the terminal emulator runs on the LOCAL desktop, tmux
  runs on the (possibly remote) box. A terminal-emulator mouse regression is therefore
  addressed by (a) upgrading the LOCAL emulator and/or (b) a version-gated workaround in
  the REMOTE ~/.tmux.conf. Detect both sides; do not assume same-host.
- If the outer terminal reports mouse-UP / drag-END but not a usable mouse-DOWN on a
  region (a known class of emulator regression — e.g. Ghostty 1.3.x status-line clicks;
  cf. ghostty #9018, fixed 1.3.0, and the mouse-reporting changes in #8430), handle the
  affected actions on the up/drag-end edge in the root key-table rather than disabling
  mouse support. Apply per the UPSTREAM-BUG WORKAROUNDS hard rule: gated on detected
  emulator+version, cited, removable, idempotent.

### Ghostty (macOS/Linux desktop)
Fixed choices: shell-integration-features includes ssh-terminfo; my font/theme/ligatures
(ask me if unset).
- Pin/refresh to the latest STABLE Ghostty before configuring, and RECORD the installed
  version (mouse-reporting behavior shifted across 1.2 -> 1.3.x; 1.3.1 was current at
  authoring time). Mouse reporting over
  SSH -> tmux is a VERIFIED outcome (see tmux SPEC), not assumed.
Required outcomes (verify over SSH): truecolor renders; undercurl renders; remote
terminfo resolves so `clear` and TUIs work without errors.

### zsh TERM-fallback guard (macOS/Linux/WSL2) — place BEFORE `source $ZSH/oh-my-zsh.sh`
Required outcome: if the current $TERM has no terminfo entry on this host, fall back to
xterm-256color so line-editing and `clear` never break. Verify on a host lacking the
entry.

### LazyVim VS Code-like defaults (all platforms)
Fixed choices (via lua/plugins/ overrides, never core files):
- SINGLE EXPLORER: there must be EXACTLY ONE file-explorer sidebar. The VS Code-style
  explorer is canonical. If both the default LazyVim neo-tree AND a VS Code-style
  extra/second explorer are active, KEEP the VS Code-style one and disable the duplicate
  at the plugin-spec level (enabled=false / remove the extra) — never via a runtime hack.
  All behaviors below attach to the surviving explorer only.
- Explorer opens on startup, INCLUDING when opening a single file; focus stays on the
  file
- hidden + gitignored files shown by default, with a toggle keybind; tree on the left
Required outcome: nvim starts with zero Lua errors, exactly ONE sidebar opens, and the
above behaviors hold (verify headlessly).

---

## SPEC (harness) — fixed choices and required outcomes

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
  `auto` mode at the Phase H3 decision, recorded either way; a read-only allowlist
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
  and reconcile any existing same-purpose command per Phase H4, preserving my
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
