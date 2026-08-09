# Changelog

All notable changes to this project are documented here. This project follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Versioning policy for this toolkit specifically:

- **patch**: fixes and clarifications, no behaviour change
- **minor**: new commands, agents, skills, modules, or CLI capability
- **major**: a change to the core operating rules or to the installer contract

## [3.4.0] - 2026-08-09

One real bug: `/ctk:resume`, `/ctk:checkpoint`, `/ctk:goal`, and `/ctk:refine`
each had two command definitions in a bootstrapped, CTK-managed project — a
project-local one (`.claude/commands/ctk/<name>.md`, staged by `ctk
install`/`update`) and a global one (`~/.claude/commands/ctk/<name>.md`,
staged by `ctk bootstrap`) — so Claude Code's slash-command picker showed two
entries per name with different descriptions, and Tab-completion into either
one was ambiguous. No change to the core operating rules or the managed-block
installer contract.

### Fixed

- **Four `/ctk:*` commands were staged in two scopes at once.** The global
  versions (added in 3.2.0) already resolve the CTK root from
  `registration.txt` and work with zero project-local dependency; the
  project-local versions predate them (3.0.0/3.1.0) and, for `checkpoint`,
  `goal`, and `refine`, only ever worked when `$CLAUDE_PROJECT_DIR/bin/ctk`
  existed — true for this checkout's own dogfood install, not for a real
  downstream project. `resume.md`, `checkpoint.md`, `goal.md`, and
  `refine.md` are removed from the project-local `.claude/commands/ctk/`
  template; the global command is now the sole source for each. The five
  commands with no global counterpart (`decide`, `plan`, `verify`, `review`,
  `ship`) are unaffected and still stage into every CTK-managed project.
- **Existing installs converge automatically, never silently.** `ctk
  update` and the automatic session-sync path now remove any of the four
  legacy project-local files that still match what CTK last staged there,
  and report the removal. A copy a user has locally edited is left in place
  untouched and dropped from the manifest instead — CTK stops asserting an
  opinion about a file it no longer intends to manage, but never discards a
  local change. Verified for both `bin/ctk` and `bin/ctk.ps1` against a
  simulated pre-3.4.0 layout, including through the real, non-interactive
  session-sync router.
- **The tradeoff, stated plainly**: those four commands now require
  `ctk bootstrap` to have run once on the current machine — a project handed
  to someone who has never bootstrapped will not have them until they do.
  `docs/zero-manual-sync.md` documents this and the exact supported
  inline-instruction interaction (`/ctk:resume <text>`, typed in the same
  message right after normal autocomplete, once — Claude Code's own
  `$ARGUMENTS` substitution, not new CTK scripting).

## [3.3.0] - 2026-08-09

Polish and hardening pass. One real bug (stale global slash commands), and the
CI gaps that let a series of Windows-only defects reach a real machine instead
of a build. No change to the core operating rules or the installer contract.

### Fixed

- **Global slash commands went stale after a checkout update.** `ctk bootstrap`
  copies `global-commands/*.md` and `router/global-router.sh` into
  `~/.claude/`, so pulling a new CTK commit left the *old* copies running.
  That is exactly how a fixed `/ctk:update` template sat in the checkout while
  the broken one kept failing on a real machine. `ctk update --session-sync`
  (the automatic session-start path) now refreshes any CTK-owned global file
  that has drifted from its source, backs up what it replaces, and reports one
  extra clause such as `Refreshed 1 global command file(s); restart Claude Code
  once to load them.` It refreshes only files that already exist — `bootstrap`
  still owns first installation and `disable` stays final — and it refuses to
  act unless the running checkout is the registered one, so a second clone can
  never rewrite the machine's globals behind the registered checkout's back.
- **CRLF checkouts broke the test suite on Windows.** The repo had no
  `.gitattributes`, so a Windows checkout with `core.autocrlf=true` rewrote
  shell scripts and hash-compared fixtures, failing 4 tests on the primary
  development machine while CI stayed green. Line endings are now pinned to LF
  in the working tree on every platform.
- **`router/` was never linted.** CI's `shellcheck` step searched only
  `bin hooks modules`, which excluded the two scripts that run on every Claude
  Code session on every machine — the highest blast radius in the repo. It now
  covers `bin hooks modules router tests`.

### Added

- **Windows CI coverage that matches how the toolkit is actually used.** The
  `windows-latest` job now parse-checks *every* `.ps1` in the tree (not just
  `bin/ctk.ps1`), runs the full test suite under Git Bash, and runs an advisory
  end-to-end PowerShell lifecycle smoke test (`install --dry-run`, `install`,
  `status`, `doctor`, `uninstall`) that asserts user content survives byte for
  byte. Every Windows-only defect to date — the `StrictMode` failure, the
  `Save-Backup` path-separator bug, the empty `LiteralPath` crash — was caught
  by hand on one machine and never by a build; this closes that.
- Frontmatter validation now also covers `global-commands/`, which ships
  user-visible slash commands and was previously unchecked.
- Five regression tests for the refresh path (drift is repaired, repeat runs
  are silent, missing files are never created, an unregistered checkout is
  ignored) plus one asserting the LF pin. 53 tests total, all passing.

### Changed

- `README.md` and `CONTRIBUTING.md` lint examples now include `router/*.sh` and
  `tests/run.sh`, matching CI.
- `HANDOFF.md` rewritten: it still described the 3.0.0 state, three feature
  releases later.

## [3.2.0] - 2026-08-08

Corrective follow-up to 3.1.0: closes the gap between updating the CTK
checkout and a project actually receiving that update. `ctk install`/`ctk
update` were, and remain, manual commands; nothing previously told a second
project, or a later Claude Code session, that the toolkit had changed. See
`docs/CTKV4_DESIGN.md`'s "Follow-up: zero-manual project sync" section for the
design record and `docs/zero-manual-sync.md` for the user-facing explanation.

### Added

- **`ctk bootstrap` / `ctk disable`**, in `bin/ctk` and `bin/ctk.ps1`. A
  one-time, per-machine, reversible setup that records the toolkit's root path
  in a small registration file and adds one `SessionStart` hook to the
  user-level (not project-level) Claude Code settings. Idempotent; preserves
  any unrelated existing hooks. On POSIX, the settings merge uses `jq` when
  present and otherwise only ever performs a provably-safe operation (writing
  a fresh file, or removing content it can prove it wrote in full) — it never
  text-splices JSON it cannot parse. On Windows, PowerShell's own
  `ConvertFrom-Json`/`ConvertTo-Json` are always available, so the merge is
  always a real parse rather than a fallback.
- **`ctk update --session-sync`**, a non-interactive counterpart to `ctk
  update` for the router below. Reuses `update`'s own block-replace and
  profile-staging code; the only new logic is a conflict pre-flight that
  fails closed (exit `11`) before writing anything if any CTK-managed file was
  locally modified, plus a post-sync health check (exit `14` on failure) and
  the machine-readable exit codes `0`/`10`/`11`/`12`/`14` documented in `ctk
  help`.
- **`router/session-sync-router.sh` and `.ps1`**, the script the global hook
  points at by absolute path. On every session start it resolves the
  registered CTK root, decides whether the active project is unmanaged
  (silent), already current, safely syncable, or in a state that needs a
  human, and defers entirely to `ctk update --session-sync`/`ctk install` for
  every write. It never stages a file itself and is not staged into any
  project (`router/` is outside every profile manifest, specifically so it
  is never copied into a consumer project by `ctk install`).

### Fixed

- **`STATE.md` was silently reset on every `ctk update`.** `stage_state_file`
  compared the file against a hardcoded pristine-boilerplate hash rather than
  treating "the file already exists" as sufficient; any content added by `ctk
  state add` (including everything `/ctk:checkpoint` writes) was overwritten
  back to empty on the very next `install` or `update`, and `ctk doctor`
  reported it as a false "locally modified" failure. Both are pre-existing
  defects in 3.0.0/3.1.0, found while building the conflict-detection path
  above; fixed in `bin/ctk` and `bin/ctk.ps1` by treating an existing
  `STATE.md` as data the tooling itself owns rather than a template to
  compare against, and excluding it from the manifest hash-conflict check
  used by `doctor` and `update --session-sync` for the same reason.

## [3.1.0] - 2026-08-08

Closes the CTKv4 core/lean-feature gap: a versioned install manifest, a bounded
active-goal record, a reviewable-refinement command, deterministic task-context
routing, and a Flutter/Android planning skill pair. Everything that already
worked in 3.0.0 (`install`, `update`, `doctor`, bounded state, the subagent
convention) is reused unchanged; nothing was added to the always-loaded core.
See `docs/CTKV4_DESIGN.md` for the baseline this was measured against and what
was deliberately deferred (repository presentation, SEO, and funding setup are
a separate follow-up).

### Added

- **Versioned install manifest.** `.claude/ctk/installed.txt` gains a
  `schema` line. A pre-3.1.0 manifest (no `schema` line) is detected by
  `ctk doctor` (`WARN`, non-fatal) and migrates automatically the next time
  `ctk update` or `ctk install` runs, since the manifest is always rewritten
  with current metadata.
- **`ctk goal`**, in `bin/ctk` and `bin/ctk.ps1`: `set`, `show`, `pause`,
  `complete --evidence`, `cancel`, `clear` for a single bounded active goal in
  `.claude/ctk/GOAL.md` (~300-token cap, rejected outright if oversized).
  Deliberately **not** wired into `hooks/session-start.sh` or `ctk budget`, so
  it adds zero always-loaded cost and never continues work on its own.
  `complete` requires a one-line `--evidence` value; a goal is never
  completed on a time or token budget alone. New `/ctk:goal` command.
- **`ctk refine`** (`/ctk:refine`, command-only, no new CLI surface): proposes
  one evidence-based edit to a project-local skill, checklist, or routing
  rule, shows the diff/benefit/token-cost/rollback, edits only after explicit
  approval, and records the change through the existing `ctk state add`
  instead of a new history file. Refuses `core/CLAUDE.core.md` and anything
  inside a managed block.
- **`task-context-loader` skill**: a deterministic routing index mapping a
  stated task category to the smallest existing command, skill, agent, or
  module asset, so a task does not trigger broad exploratory reading.
- **Two Flutter/Android planning skills**, `flutter-recon` and
  `flutter-ui-checklist`, filling the reconnaissance/checklist gap the
  existing build/verify scripts (`analyze`, `test`, `preflight`, `release`,
  `doctor`) don't cover. Module skills are a new optional `skills/`
  subdirectory in the module contract, staged the same way as `commands/`
  and `scripts/`.
- **`docs/CTKV4_DESIGN.md`** and **`docs/FUNDING_SETUP.md`** (the latter has
  no funding link or `FUNDING.yml`; it documents what a verified destination
  requires, since none exists yet).

### Fixed

- `prepare_stage_records` in `bin/ctk` had no exclusion filter for its manifest
  header keys, so a second `install` or any `update` after one duplicated the
  `version`/`profile` lines in `installed.txt` (the PowerShell implementation
  already excluded them correctly). Fixed alongside the new `schema` key;
  covered by `test_legacy_manifest_migrates_on_update`.
- `modules/README.md` documented the module command-staging path as
  `.claude/commands/ctk/<command>.md` and the flutter-android module's "Adds"
  list named its commands `/ctk:*`; both were stale. The installer has always
  staged module commands to `.claude/commands/<module-name>/`, invoked as
  `/<module-name>:<command>`.

## [3.0.0] - 2026-08-08

A rewrite from a documentation project into working software. Version 2 described
how an agent should behave; version 3 implements it, measures its own cost, and can
be removed cleanly.

The full v2 tree is preserved as the `v2.2.0` tag and is one `git checkout v2.2.0`
away. Nothing was lost.

### Added

- **Token budget, measured and enforced.** `ctk budget` measures the always-loaded
  surface and exits nonzero on a breach. Caps: 1,200 tokens for the core, 400 for
  bounded state. CI runs it on Linux, macOS, and Windows, so the v2 cost regression
  cannot recur silently. Current measurement: 394 tokens.
- **`bin/ctk`**, a POSIX `sh` CLI with no runtime dependencies, and `bin/ctk.ps1`
  with an identical surface for PowerShell 5.1+. Subcommands: `install`, `update`,
  `uninstall`, `restore`, `status`, `doctor`, `budget`, `state`, `version`, `help`.
- **Non-destructive managed-block injection.** Installation appends a delimited
  block; update replaces only the block body; uninstall removes only the block.
  Content outside the markers is preserved byte for byte, which is verified by test.
- **`ctk uninstall`.** Version 2 declined to ship an uninstaller. Staged files that
  were modified locally are reported and kept rather than deleted.
- **Two injection modes.** `--link` writes a single `@`-import, costing roughly
  fifteen tokens per project and sharing one core across every repository.
  `--embed` inlines the core for a self-contained project.
- **Three profiles**, `minimal`, `standard`, and `full`, that stage genuinely
  different asset sets, recorded in `.claude/ctk/installed.txt` with hashes.
- **7 slash commands**: `resume`, `checkpoint`, `decide`, `plan`, `verify`,
  `review`, `ship`. `verify` detects the project toolchain (Flutter, Node, Python,
  Go, Rust, Make) and runs its real checks.
- **4 subagents** running in isolated context windows and returning digests:
  `investigator`, `code-reviewer`, `verifier`, `security-reviewer`.
- **3 skills**: session continuity, evidence and uncertainty, safe changes.
- **3 hooks**: a `SessionStart` orientation digest, `PostToolUse` formatting of only
  the edited file, and a `PreToolUse` guard that blocks writes to keystores,
  certificates, `.env*`, and service-account files.
- **Bounded state with an archive.** `.claude/ctk/STATE.md` is capped and rotates
  aged entries into `.claude/ctk/archive/`, which is never read automatically.
- **Opt-in Flutter/Android module** with 8 commands and real scripts: `analyze`,
  `test`, `apk`, `bundle`, `version`, `preflight`, `release`, `doctor`. Preflight
  fails if any keystore, `key.properties`, or `.env` file is tracked by git, and no
  script prints a secret.
- **Automated tests** with fixtures, covering install idempotence, user-content
  preservation, block-scoped update, uninstall behaviour, restore, dry-run,
  profile staging, module detection, budget enforcement, and drift detection.
- **CI** on Linux, macOS, and Windows: tests, token budget, `shellcheck -s sh`,
  `settings.json` validation, YAML frontmatter validation, and a PowerShell parse
  check.
- **Open-source scaffolding**: MIT license, contribution guide, security policy
  with a stated threat model, code of conduct, and issue templates.

### Changed

- The core operating rules were tightened from `GLOBAL_CLAUDE.md` into
  `core/CLAUDE.core.md`. The substance of the ten rules is retained; padding and
  toolkit-specific references are gone. Rule 9 now points at bounded state and
  explicitly tells the agent not to read archives unprompted.
- `prompts/`, `checklists/`, and `templates/` became commands, skills, and the
  commands that write them, rather than prose to be read.
- `chapters/` was distilled into `docs/`.
- `DECISIONS.md` remains an append-only record but is no longer in any mandatory
  read path. This was the largest single contributor to the v2 session cost.

### Removed

All of the following remain available in the `v2.2.0` tag.

- `exports/`: a 428 KB PDF, a 49 KB DOCX, and a 78 KB Markdown merge. Generated
  artifacts do not belong in a distributed repository.
- `sources/`: 470 KB of input material, including PDFs.
- The toolkit's own build diary, which every adopter previously had to separate from
  the product: `session_logs/`, `summaries/`, `reviews/`, `PROJECT_STATUS.md`,
  `ROADMAP.md`, `IDEAS.md`, `OPEN_QUESTIONS.md`, `SOURCE_REGISTER.md`,
  `PROMPTS.md`, `PROJECT_CONTEXT.md`, `PROJECT_RULES.md`,
  `PROJECT_CONSTITUTION.md`, `HOW_TO_BUILD.md`, and `memory/`.
- `scripts/install.sh` and `scripts/install.ps1`, superseded by `bin/ctk`. The old
  scripts overwrote the target's entire `CLAUDE.md`.
- `scripts/health-check.sh` and `scripts/health-check.ps1`, superseded by
  `ctk doctor`.
- Hardcoded `C:\Claude-Global-Toolkit` paths in documentation.

### Fixed

- Installation no longer destroys project-specific instructions in a target
  `CLAUDE.md`.
- Updating the baseline no longer requires manually re-applying local rules.
- Session-start cost is bounded and cannot grow without a CI failure.

## [2.2.0] - 2026-08-07

Preserved as the `v2.2.0` tag. The documentation-era toolkit: `GLOBAL_CLAUDE.md`
with ten universal rules, 8 handbook chapters, 12 prompts, 10 checklists, 13
templates, install and health-check scripts for PowerShell and POSIX shell, and the
project's own governance and decision records.
