# Claude Global Toolkit

**A lightweight, token-budgeted Claude Code toolkit: global `/ctk:*` slash
commands, safe project synchronization, practical guardrails, compact project
continuity, and an optional Flutter/Android workflow.**

[![CI](https://github.com/goranbalsic/Claude-Global-Toolkit/actions/workflows/ci.yml/badge.svg)](https://github.com/goranbalsic/Claude-Global-Toolkit/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
![Always-loaded cost](https://img.shields.io/badge/always--loaded-397%20tokens-brightgreen)
![Dependencies](https://img.shields.io/badge/runtime%20dependencies-none-brightgreen)
![Platforms](https://img.shields.io/badge/platforms-Linux%20%7C%20macOS%20%7C%20Windows-blue)

CTK bootstraps once per machine, then lives entirely inside Claude Code as
`/ctk:*` slash commands — no terminal required for day-to-day use. It installs
into a project as a delimited, non-destructive block: your `CLAUDE.md` is
never overwritten, and everything CTK stages is tracked so it can be updated
or removed cleanly. The part it loads on every session is capped at **1,200
tokens and measured in CI**; it currently measures **397**. Everything else —
commands, subagents, skills, the Flutter/Android module — costs nothing until
you invoke it.

It's for developers using Claude Code who want reviewable, reversible
tooling instead of an instructions file that only grows, and for Flutter/Android
developers who want analyze, test, build, and release checks as commands
rather than remembered incantations. It is not an opinionated framework that
restructures your repository, and it does not read or send your code
anywhere: no network calls, no telemetry, no writes outside the directory you
target.

---

## Contents

- [What you get](#what-you-get)
- [Quick start](#quick-start)
- [How it works](#how-it-works)
- [Core workflows](#core-workflows)
- [Safety and token discipline](#safety-and-token-discipline)
- [Flutter and Android](#flutter-and-android)
- [Scope and known limits](#scope-and-known-limits)
- [Documentation](#documentation)
- [Trust and contribution](#trust-and-contribution)
- [License](#license)

---

## What you get

**9 slash commands** that run real tooling rather than restating procedure:

| Command | What it does |
|---|---|
| `/ctk:resume` | Reconstructs the exact resume point from capped state plus git evidence. Does not read large history files. |
| `/ctk:checkpoint` | Writes a one-line dated state entry and auto-rotates when it would exceed budget. |
| `/ctk:decide` | Appends a terse decision record: context, options, choice, reversibility, confidence. |
| `/ctk:plan` | Produces a bounded, file-level plan with verification steps and a rollback path. |
| `/ctk:verify` | Detects your toolchain (Flutter, Node, Python, Go, Rust, Make) and runs its real analyze, lint, typecheck, and test commands. Reports pass, fail, skip, or unavailable honestly. |
| `/ctk:review` | Adversarial review of the current diff, delegated to an isolated subagent. |
| `/ctk:ship` | Pre-release gate: verification, version bump, changelog entry, clean tree, no staged secrets. |
| `/ctk:goal` | Creates, inspects, pauses, completes, cancels, or clears one bounded active goal in `.claude/ctk/GOAL.md`. Never auto-loaded and never continues work on its own; `complete` requires stated evidence. |
| `/ctk:refine` | Proposes one evidence-based improvement to a project-local skill, checklist, or routing rule, with a diff and rollback path, and applies it only after explicit approval. |

Plus **eight global commands** — `/ctk:install`, `/ctk:update`, `/ctk:doctor`,
`/ctk:status`, `/ctk:resume`, `/ctk:checkpoint`, `/ctk:goal`, and
`/ctk:refine` — available in *any* project once you bootstrap once per
machine. See [Quick start](#quick-start). The last four exist only as global
commands: no project-local copy is staged, so they need a bootstrapped
machine. The other five commands above (`decide`, `plan`, `verify`, `review`,
`ship`) are staged into every CTK-managed project regardless of bootstrap.

**4 subagents** that exist for token economics. Each runs in its own context
window and returns a compact digest, so expensive work does not stay in your
main thread: `investigator` (repository reconnaissance), `code-reviewer`,
`verifier`, `security-reviewer`.

**4 skills** loaded progressively when relevant: session continuity, evidence
and uncertainty labelling, safe reversible changes, and task-scoped context
routing (naming the smallest existing command, skill, agent, or module asset
for a stated task category instead of reading broadly).

**3 hooks** that provide real automation, not advice:

- `SessionStart` prints a cheap deterministic orientation digest, so the
  model starts oriented without reading anything large.
- `PostToolUse` formats only the file just edited, dispatching on extension,
  and no-ops silently when the formatter is absent.
- `PreToolUse` **blocks** writes to `*.keystore`, `*.jks`, `*.p12`, `*.pem`,
  `key.properties`, `.env*`, `google-services.json`, and service-account
  JSON. Verified by test: a keystore payload exits 2 and is refused, a Dart
  payload passes.

**An opt-in Flutter/Android module** — see [Flutter and Android](#flutter-and-android).

## Quick start

No package manager, no build step, no dependencies.

```sh
git clone https://github.com/goranbalsic/Claude-Global-Toolkit.git
cd Claude-Global-Toolkit
chmod +x bin/ctk
```

Verify the checkout before trusting it:

```sh
sh tests/run.sh     # 53+ tests, expect all pass
bin/ctk budget      # expect PASS with the measured always-loaded cost
```

On Windows use `bin\ctk.ps1`, which has an identical command surface.

**One time, per machine**, so CTK never needs a terminal again:

```sh
ctk bootstrap --yes        # POSIX
```

```powershell
& .\bin\ctk.ps1 bootstrap --yes   # Windows
```

This registers the checkout, adds one `SessionStart` hook to your
user-level Claude Code settings (not the project's), and installs the eight
global `/ctk:*` commands into `~/.claude/commands/ctk/`. Both steps are
reversible with `ctk disable`.

**Then, in any project, inside Claude Code:**

```
/ctk:install     # new project — asks for approval before writing anything
/ctk:status      # what is installed here
/ctk:resume      # reconstruct the resume point and get to work
```

`/ctk:resume`, `/ctk:checkpoint`, `/ctk:goal`, and `/ctk:refine` also take one
optional instruction typed in the same message, right after autocomplete:

```
/ctk:resume Review the authentication flow and fix duplicate files first.
```

Prefer the terminal, or want to script it? The same operations are a normal
CLI:

```sh
cd /path/to/your/project
ctk install --dry-run          # see exactly what would change, write nothing
ctk install                    # standard profile, link mode
```

Three profiles, so you pay only for what you use:

| Profile | Installs | Use when |
|---|---|---|
| `minimal` | core rules only | you want the rules and nothing else |
| `standard` (default) | core, bounded state, slash commands, hooks | normal day-to-day work |
| `full` | standard plus subagents, skills, and applicable modules | Flutter/Android work, or larger projects |

```sh
ctk install --profile full
ctk install --profile full --module flutter-android
ctk install --profile standard --no-modules
```

## How it works

**Ownership.** Every file CTK stages is tracked in
`.claude/ctk/installed.txt`, and the only file it edits in place is your
`CLAUDE.md`, where it manages one delimited block:

```markdown
# My project's own instructions
Deploy only from main. Never touch the migrations directory without review.

<!-- ctk:begin v=3.4.0 profile=standard hash=a1b2c3d4e5f6 sep=0 -->
@/home/you/Claude-Global-Toolkit/core/CLAUDE.core.md
<!-- ctk:end -->
```

`install` appends the block. `update` replaces the block body only.
`uninstall` deletes the block only. Everything outside the markers — your own
rules — survives byte for byte, which is verified by test. A staged file you
edit locally is detected by hash and reported as kept, never silently
overwritten.

**Global command resolution.** The eight commands `ctk bootstrap` installs
into `~/.claude/commands/ctk/` are thin routers: each one reads the CTK root
recorded at bootstrap time and calls the real `ctk` CLI at that absolute
path. That is what lets `/ctk:install` work in a brand-new project with zero
project-local CTK files, before any project-local install exists, and
without ever touching `PATH`.

**Three layers**, and only the first and third are ever always loaded:

| Layer | Contents | Loaded | Budget |
|---|---|---|---|
| L1 Core | `core/CLAUDE.core.md`, the operating rules | every session | **1,200 tokens, enforced** |
| L2 On-demand | commands, subagents, skills, modules | on invocation only | not needed |
| L3 State | `.claude/ctk/STATE.md`, session continuity | every session | **400 tokens, enforced** |

`ctk budget` measures L1 plus L3 and exits nonzero on a breach; CI runs it on
every push. History (`STATE.md`) is a capped working set — entries that age
out rotate into `.claude/ctk/archive/`, which is never read automatically —
so nothing is lost, but nothing is recited by default either.

Full detail in [docs/architecture.md](docs/architecture.md).

## Core workflows

```sh
ctk status      # what is installed here: profile, version, staged file count
ctk doctor      # drift, orphaned markers, budget, missing or modified assets
ctk budget      # measured always-loaded cost, with pass/fail against the caps
ctk update      # refresh the managed block in place
ctk state show  # the capped working set
ctk state add "Finished currency parser. Next: wire the rate cache."
ctk goal show   # the single bounded active goal, never auto-loaded
ctk goal set --objective "ship v3.1" --acceptance "tests pass"
ctk goal complete --evidence "sh tests/run.sh: 0 failed"
ctk uninstall --dry-run   # show precisely what would be removed
ctk uninstall
ctk restore     # undo the newest change to a CTK-managed file, from backup
```

From inside Claude Code, once bootstrapped, the equivalents work in any
project without a terminal:

```
/ctk:install
/ctk:update
/ctk:doctor
/ctk:status
/ctk:resume
/ctk:checkpoint
/ctk:goal set objective: offline exchange-rate caching; acceptance: tests pass
/ctk:refine
```

Every mutating command accepts `--dry-run` and `--yes`, takes a timestamped
backup into `.ctk-backup/` first, and is reversible.

**Removing CTK entirely from a project:**

```sh
ctk uninstall --dry-run
ctk uninstall
```

Deletes only the managed block and only the files it staged. A staged file
you edited locally is reported and kept, never silently deleted. See
[docs/uninstall.md](docs/uninstall.md) for every reversal path, including how
to disable machine-level bootstrap (`ctk disable`) independently of any
project.

## Safety and token discipline

- **Non-destructive by construction.** `ctk` never overwrites a target file;
  it manages a delimited block and refuses to act on any CTK-managed file it
  finds locally modified, whether run by hand or through the automatic
  session-start sync.
- **Backed up before every write.** Every mutating command takes a
  timestamped backup into `.ctk-backup/` first; `ctk restore` reverses the
  newest one.
- **A measured budget, not an assertion.** `ctk budget` prints the actual
  byte/token count for the always-loaded core and state, compares it to the
  1,200/400-token caps, and CI fails the build on a breach — currently **397
  / 1,200** for the core.
- **Secret paths are actively blocked**, not just documented: a `PreToolUse`
  hook refuses writes to keystores, `.env*`, `key.properties`, and
  service-account JSON, verified by test.
- **No network calls, no telemetry, no background process.** The toolkit
  reads and writes files in the directory you target, and nowhere else,
  except the explicit `--global` case.

Zero-manual sync (the automatic session-start refresh described in [How it
works](#how-it-works)) follows the same rules: it only ever calls the same
`ctk install`/`ctk update` you could type yourself, stops before writing
anything if a conflict is detected, and reports one clause instead of acting
silently. Full detail in [docs/zero-manual-sync.md](docs/zero-manual-sync.md)
and [docs/token-budget.md](docs/token-budget.md).

## Flutter and Android

An opt-in module — staged only with `--profile full` or an explicit
`--module flutter-android`, and only detected automatically when the target
has a `pubspec.yaml` containing `flutter:`. It contributes zero tokens to a
project that doesn't use it.

8 commands with real scripts behind them: `analyze`, `test` (configurable
concurrency, defaulting to `-j 1`, with the reason documented), `apk` (debug
and release, `--split-per-abi`, flavors, size reporting), `bundle`, `version`
(safe semver and build-number bumping in `pubspec.yaml`), `preflight`,
`release`, `doctor`. The preflight gate fails if any keystore,
`key.properties`, or `.env` file is tracked by git, and no script ever prints
a secret.

Two on-demand skills cover the planning side the commands above don't:
`flutter-recon` (project reconnaissance and scoped change planning) and
`flutter-ui-checklist` (a UI/feature implementation checklist).

Argument handling, failure paths, and secret hygiene are covered by CI; the
Flutter SDK itself is not available in CI, so build commands are exercised as
dry runs there rather than against a real toolchain. See
[modules/flutter-android/README.md](modules/flutter-android/README.md).

## Scope and known limits

**In scope.** Universal engineering rules that hold in any repository.
Session continuity that stays bounded. Non-destructive installation, update,
drift detection, and removal. Slash commands, subagents, skills, and hooks
that run real tooling. Opt-in per-stack modules. A measured, CI-enforced
token budget.

**Out of scope, deliberately.** Restructuring your repository or imposing a
directory layout. Any runtime dependency, package installation, network
call, or telemetry. Writing outside the target directory, except the
explicit `--global` case. Automating destructive or outbound actions without
approval. Support for editors other than Claude Code, for now.

**Stated plainly:**

- Token counts are estimated at four bytes per token — approximate by
  design, enough to catch order-of-magnitude regressions rather than replace
  a tokenizer.
- Link mode (the default injection mode) requires the toolkit to stay at the
  path recorded at install time; `ctk doctor` reports it if that path moves.
  `ctk install --embed` avoids this at the cost of per-project duplication.
- A newly bootstrapped or newly installed slash command needs one Claude
  Code restart to appear — a Claude Code loading behavior, not something CTK
  can avoid.

## Documentation

| Document | Contents |
|---|---|
| [docs/architecture.md](docs/architecture.md) | Layer model, managed-block injection, design rationale |
| [docs/token-budget.md](docs/token-budget.md) | What is measured, why, and how to keep the core small |
| [docs/install.md](docs/install.md) | Full installation and profile reference |
| [docs/zero-manual-sync.md](docs/zero-manual-sync.md) | One-time bootstrap, automatic project sync, safety and recovery |
| [docs/uninstall.md](docs/uninstall.md) | Every reversal path |
| [docs/writing-modules.md](docs/writing-modules.md) | The module contract |
| [modules/flutter-android/README.md](modules/flutter-android/README.md) | Flutter and Android release workflows |
| [CHANGELOG.md](CHANGELOG.md) | Full release history |
| [docs/migrating-from-v2.md](docs/migrating-from-v2.md) | Upgrading a project still on the retired v2 handbook |
| [SECURITY.md](SECURITY.md) | Threat model, secret handling, disclosure |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Constraints, checks, how to add commands and modules |

## Trust and contribution

**Requirements:** Claude Code; a POSIX shell (`sh`, `dash`, `bash`, `zsh`) on
Linux, macOS, or WSL, or PowerShell 5.1+ on Windows; `git`. Nothing else at
runtime. CI runs on Linux, macOS, and Windows.

Issues and pull requests are welcome. The constraints in
[CONTRIBUTING.md](CONTRIBUTING.md) are what keep the toolkit useful, and the
token budget is the one that gets enforced automatically. Before opening a
pull request:

```sh
sh tests/run.sh
bin/ctk budget
shellcheck -s sh bin/ctk tests/run.sh hooks/*.sh modules/*/scripts/*.sh router/*.sh
```

Repository layout, for orientation:

```
core/CLAUDE.core.md          the always-loaded rules, budget-enforced
core/profiles/               which assets each profile installs
bin/ctk                      POSIX sh CLI, zero dependencies
bin/ctk.ps1                  PowerShell 5.1+, identical surface
.claude/commands/ctk/        slash commands (project-local install)
.claude/agents/              subagents, isolated context
.claude/skills/              progressively disclosed skills
.claude/settings.json        hook wiring
global-commands/             global /ctk:* slash-command templates, installed by `ctk bootstrap`
hooks/                       session-start, pre-edit guard, post-edit format
router/                      global SessionStart router + global command router, registered by `ctk bootstrap`
modules/flutter-android/     opt-in Flutter and Android release workflows
tests/run.sh                 test harness with fixtures
docs/                        architecture, install, uninstall, budget, modules
```

## License

MIT. See [LICENSE](LICENSE).
