# Changelog

All notable changes to this project are documented here. This project follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Versioning policy for this toolkit specifically:

- **patch**: fixes and clarifications, no behaviour change
- **minor**: new commands, agents, skills, modules, or CLI capability
- **major**: a change to the core operating rules or to the installer contract

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
