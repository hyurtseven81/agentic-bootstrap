# Setup Prompt — Dev Machine Provisioning

> **Prompt version: v2 (2026-06-10)** — bump on every amendment. Phase A proposes
> amendments to this file; after approval, backport them to the canonical copy in
> the prompts repo.

**How to use:** open an agent session on the target machine (strongest available
model) and paste this entire prompt. Approvals stay ON by design — the agent plans,
asks, then acts.

You are provisioning MY dev environment. Target may be:
- macOS (local desktop)
- Linux (local desktop OR a remote Amazon dev-dsk: headless, behind a corporate egress proxy)
- Windows (native), OR Windows running this inside WSL2 (treat WSL2 as Linux)

Works on a FRESH machine or one already partly set up — detect, then install-or-update.

## Source of truth
This command file IS the source of truth. Do NOT depend on any external dotfiles repo,
remote, or sync service. The SPEC below defines my fixed choices and required outcomes.
Author each config to satisfy the spec using CURRENT best practice at run time; do not
freeze a specific implementation if a better current mechanism exists (raise it in Phase A).
When a config already exists, back it up and reconcile it toward the spec, preserving my
intentional local additions — if a conflict is ambiguous, show me the diff and ask.
Never push anything to any remote.

## Hard rules
- IDEMPOTENT and re-runnable. Detect current state before changing anything.
- BACK UP before overwriting any config (timestamped .bak). NEVER delete my files.
- Show me a PLAN and wait for confirmation before the first mutating step.
- NO sudo / admin / system-package changes without showing the exact command and asking.
  (I keep approvals ON by design. If I want hands-off I'll launch you with skip-permissions.)
- MANAGED BLOCKS: every config section you author lives between marked sentinels —
  `# >>> devsetup:<unit> >>>` … `# <<< devsetup:<unit> <<<` (comment syntax per file
  format). Re-runs replace the block content in place; everything outside the blocks is
  MINE and is preserved untouched. Never raw-append (`>>`); if you find a prior
  hand-applied append that a block supersedes, absorb it into the block and remove the
  duplicate (with my approval on the diff).
- DURABLE RUN STATE: every run writes a report to `~/.devsetup/runs/<UTC-timestamp>.md`
  (plan, inventory before/after with versions, every file created/changed with its unit
  name, every backup with its path, every substitution, every deferred/failed item) and
  appends to `~/.devsetup/backups.manifest`. Phase 0 reads prior reports if present —
  don't re-derive what a previous run already established, but re-verify it.
- SUPPLY CHAIN: prefer the platform package manager (or mise) over vendor install
  scripts. Never execute a piped `curl | sh` blind — download the script, tell me what
  it does and where it's from, run only after approval; verify checksums/signatures
  where the project publishes them. Record the install source per tool in the run
  report.
- Respect the corporate proxy. If a download is blocked, DO NOT work around it silently —
  report the exact tool + error and propose options (set http(s)_proxy, or install via
  system/internal mirrors and point configs at the existing binary). If you hit TLS
  errors behind the proxy, that is usually a corporate MITM root CA — the fix is adding
  the corporate CA to the relevant trust stores (npm `cafile`, pip/uv cert config, git
  `http.sslCAInfo`, curl `CURL_CA_BUNDLE`). NEVER disable TLS verification anywhere,
  even "temporarily."
- Detect HEADLESS vs GUI. GUI apps install on local desktops ONLY; skip on headless remotes
  (there, the VS Code server auto-installs on connect — nothing to do).
- No secrets in any file you write. If you encounter a live credential, warn me.
- "Author to satisfy the spec, then VERIFY." Never assume an outcome — prove each one
  with the stated check before reporting success. Report failures as failures, with
  output — never round a partial result up to success.
- FAILURE BEHAVIOR: if a step fails mid-phase, stop that unit, leave the machine in a
  consistent state (block fully written or fully untouched — no half-edits), record the
  failure + exact error in the run report, and continue with independent units. The end
  report separates DONE / FAILED / DEFERRED; a re-run picks up the failed units.
- UPSTREAM-BUG WORKAROUNDS: when a config exists only to route around a known upstream bug
  (terminal, multiplexer, LSP, etc.), you MUST:
  (1) prefer the upstream FIX first — upgrade the tool to a release where it's resolved —
      and fall back to a workaround ONLY if the installed/available version is still
      affected;
  (2) GATE the workaround on a detected version/condition so it becomes a no-op once the
      bug is gone (never an unconditional append);
  (3) ANNOTATE it inline with the upstream issue URL, the affected version range, and an
      explicit "remove when ..." condition;
  (4) keep it IDEMPOTENT and de-duplicated — author it into a managed block, never a raw
      `>>` append.

## Phase 0 — Detect & inventory (READ-ONLY)
Report: OS + distro/version, arch, GUI-vs-headless, native-Windows-vs-WSL2, shell, and
proxy status (test reachability to github.com, registry.npmjs.org, pypi.org; note TLS
interception if certificates don't chain to public roots). Read `~/.devsetup/runs/` if
it exists and summarize the last run's end state. Inventory every tool below with
current version + a desired-vs-current action column.

## Phase A — Best-practice review & SELF-EVOLVE (every run, BEFORE the plan)
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
Ensure the current STABLE nvim (minimum 0.10; prefer latest stable — LazyVim's floor
moves, check it). Install LazyVim (starter) if absent; respect lazy-lock.json if my
config exists. Apply my VS Code-like defaults via LazyVim's lua/plugins/ override pattern
(NEVER edit core files) — see LazyVim SPEC, including the SINGLE-EXPLORER requirement.

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
  are installed and runnable (report versions).
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

## SPEC — author configs to satisfy this (current best practice; verify each)

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
  version (mouse-reporting behavior shifted across 1.2 -> 1.3.x). Mouse reporting over
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
