# Claude Global Toolkit

**A token-budgeted engineering toolkit for Claude Code: slash commands, subagents, skills, and safety hooks that install into any repository without overwriting your `CLAUDE.md`, and uninstall with one command.**

[![CI](https://github.com/goranbalsic/Claude-Global-Toolkit/actions/workflows/ci.yml/badge.svg)](https://github.com/goranbalsic/Claude-Global-Toolkit/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
![Always-loaded cost](https://img.shields.io/badge/always--loaded-394%20tokens-brightgreen)
![Dependencies](https://img.shields.io/badge/runtime%20dependencies-none-brightgreen)
![Platforms](https://img.shields.io/badge/platforms-Linux%20%7C%20macOS%20%7C%20Windows-blue)

Most AI coding setups get slower and more expensive the longer you use them. They
accumulate rules, checklists, and decision logs, then load all of it at the start
of every session. The context window fills with preamble before any work begins.

This toolkit is built the other way around. The part that loads every session is
capped at **1,200 tokens and measured in CI**. It currently sits at **394**.
Everything else costs nothing until you invoke it.

---

## Contents

- [Why this exists](#why-this-exists)
- [Who it is for](#who-it-is-for)
- [What you get](#what-you-get)
- [Install](#install)
- [Per-project injection without token cost](#per-project-injection-without-token-cost)
- [Usage](#usage)
- [Uninstall and revert](#uninstall-and-revert)
- [Scope](#scope)
- [How it works](#how-it-works)
- [Repository layout](#repository-layout)
- [Requirements](#requirements)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

---

## Why this exists

Version 2 of this toolkit was a handbook: 87 files, roughly 338 KB of Markdown,
describing how an AI agent should behave. The reasoning was sound. Measured in a
real project, the result was not.

The session-start read order it installed pulled in four files before any work
could begin:

| File | Size | Approx. tokens |
|---|---:|---:|
| `DECISIONS.md` | 104 KB | ~26,000 |
| `PROJECT_CONTEXT.md` | 28 KB | ~7,000 |
| `PROMPTS.md` | 25 KB | ~6,400 |
| `OPEN_QUESTIONS.md` | 17 KB | ~4,300 |
| **Total, every session** | **174 KB** | **~45,000** |

Those files only grew. Nothing capped them, and nothing measured them. Meanwhile
the toolkit implemented none of Claude Code's actual extension points. It gave the
agent advice where it could have given the agent tools.

Version 3 fixes both problems:

| | v2.2.0 | v3.0.0 |
|---|---|---|
| Always-loaded cost | ~45,000 tokens, unbounded | **394 tokens, capped and CI-enforced** |
| Executable capability | none | 7 slash commands, 4 subagents, 3 skills, 3 hooks |
| Install behaviour | overwrites the target `CLAUDE.md` | appends a delimited block, preserves your content byte for byte |
| Uninstall | none, by policy | `ctk uninstall` |
| Session history | read in full, every session | capped working set, archive queried on demand |
| Stack support | none | opt-in Flutter/Android release module |
| Tests | manual | 10+ automated, CI on Linux, macOS, Windows |

Nothing from v2 was lost. It is preserved in full as the `v2.2.0` tag.

## Who it is for

- **Developers using Claude Code daily** who have noticed sessions getting slower
  and more expensive as their instruction files grow.
- **Anyone whose `CLAUDE.md` has become a dumping ground** and who wants a
  baseline that can be updated without hand-merging local rules back in.
- **Teams** that need agent behaviour to be reviewable. The managed block shows up
  as a clean, self-describing diff in pull requests.
- **Flutter and Android developers** shipping APKs and app bundles who want
  analyze, test, build, signing, and pre-release checks as commands rather than
  remembered incantations.
- **People who distrust AI tooling that cannot prove its own claims.** Every
  safety property here has a test, the token budget is measured rather than
  asserted, and there is no telemetry, no network access, and no install step that
  touches anything outside the directory you name.

It is probably not for you if you want an opinionated framework that restructures
your repository, or if you are looking for a prompt collection to read rather than
software to run.

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

**4 subagents** that exist for token economics. Each runs in its own context window
and returns a compact digest, so expensive work does not stay in your main thread:

`investigator` (repository reconnaissance), `code-reviewer`, `verifier`,
`security-reviewer`.

**4 skills** loaded progressively when relevant: session continuity,
evidence and uncertainty labelling, safe reversible changes, and task-scoped
context routing (naming the smallest existing command, skill, agent, or
module asset for a stated task category instead of reading broadly).

**3 hooks** that provide real automation, not advice:

- `SessionStart` prints a cheap deterministic orientation digest, so the model
  starts oriented without reading anything large.
- `PostToolUse` formats only the file just edited, dispatching on extension, and
  no-ops silently when the formatter is absent.
- `PreToolUse` **blocks** writes to `*.keystore`, `*.jks`, `*.p12`, `*.pem`,
  `key.properties`, `.env*`, `google-services.json`, and service-account JSON.
  Verified by test: a keystore payload exits 2 and is refused, a Dart payload
  passes.

**An opt-in Flutter/Android module** with 8 commands and real scripts: `analyze`,
`test` (configurable concurrency, defaulting to `-j 1`, with the reason
documented), `apk` (debug and release, `--split-per-abi`, flavors, size
reporting), `bundle`, `version` (safe semver and build-number bumping in
`pubspec.yaml`), `preflight`, `release`, `doctor`. The preflight gate fails if any
keystore, `key.properties`, or `.env` file is tracked by git, and no script ever
prints a secret. It also adds two on-demand skills for the planning side of
Flutter work the commands above don't cover: `flutter-recon` (project
reconnaissance and scoped change planning) and `flutter-ui-checklist` (a
UI/feature implementation checklist).

## Install

No package manager, no build step, no dependencies.

```sh
git clone https://github.com/goranbalsic/Claude-Global-Toolkit.git
cd Claude-Global-Toolkit
chmod +x bin/ctk
```

Optionally put it on your `PATH`:

```sh
ln -s "$PWD/bin/ctk" ~/.local/bin/ctk
```

On Windows use `bin\ctk.ps1`, which has an identical command surface.

Verify the checkout before trusting it:

```sh
sh tests/run.sh     # 10+ tests, expect all pass
bin/ctk budget      # expect PASS with the measured always-loaded cost
```

### Adopt it in a project

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

## Per-project injection without token cost

Global installation is **optional and not the default**. There are two injection
modes, and the cheap one is what you get unless you ask otherwise.

**Link mode (default).** The managed block is a single `@`-import pointing at the
toolkit on disk. Claude Code resolves the import natively, so your project's
instruction file carries roughly fifteen tokens. One core is shared by every
project, and editing the toolkit updates all of them at once with no reinstall.

```sh
ctk install --link             # default
```

**Embed mode.** The core is inlined, so the project is self-contained and works on
a machine that does not have the toolkit checked out. The cost is duplication and
a per-project `ctk update`.

```sh
ctk install --embed
```

**Global mode, if you want it.** This is the only operation that writes outside the
target directory, and it is explicit in the command name.

```sh
ctk install --global           # writes ~/.claude/CLAUDE.md
```

Whatever mode you choose, your existing file is never overwritten. The toolkit
manages a delimited block and leaves everything outside it untouched:

```markdown
# My project's own instructions
Deploy only from main. Never touch the migrations directory without review.

<!-- ctk:begin v=3.1.0 profile=standard hash=a1b2c3d4e5f6 sep=0 -->
@/home/you/Claude-Global-Toolkit/core/CLAUDE.core.md
<!-- ctk:end -->
```

`install` appends the block. `update` replaces the block body only. `uninstall`
deletes the block only. Your rules above it survive byte for byte, which is
verified by test.

## Usage

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
```

Then work normally in Claude Code and reach for the commands:

```
/ctk:resume
/ctk:plan add offline exchange-rate caching
/ctk:verify
/ctk:review
/ctk:checkpoint
/ctk:goal set objective: offline exchange-rate caching; acceptance: tests pass
/ctk:ship
```

Every mutating command accepts `--dry-run` and `--yes`, takes a timestamped backup
into `.ctk-backup/` first, and is reversible.

## Uninstall and revert

Reversal is a first-class feature, at three levels.

**Remove the toolkit from one project.** Deletes only the managed block and only
the files it staged. A staged file you edited locally is reported and kept, never
silently deleted.

```sh
ctk uninstall --dry-run        # show precisely what would be removed
ctk uninstall
```

**Restore the previous state of a modified file** from the automatic backup:

```sh
ctk restore
```

**Go back to v2.2.0 entirely.** The previous version is preserved as a tag, so it
is always one command away:

```sh
git checkout v2.2.0
```

Reading or recovering individual v2 files without changing your checkout:

```sh
git show v2.2.0:HOW_TO_USE.md
git checkout v2.2.0 -- chapters/01-daily-operating-loop.md
```

See [docs/migrating-from-v2.md](docs/migrating-from-v2.md) for upgrading a project
that already adopted v2, including how to remove the expensive read order.

## Scope

**In scope.** Universal engineering rules that hold in any repository. Session
continuity that stays bounded. Non-destructive installation, update, drift
detection, and removal. Slash commands, subagents, skills, and hooks that run real
tooling. Opt-in per-stack modules. A measured, CI-enforced token budget.

**Out of scope, deliberately.** Restructuring your repository or imposing a
directory layout. Any runtime dependency, package installation, network call, or
telemetry. Writing outside the target directory, except the explicit `--global`
case. Automating destructive or outbound actions without approval. Prompt
collections meant to be read rather than run. Support for editors other than
Claude Code, for now.

**Known limits, stated plainly.** Token counts are estimated at four bytes per
token, which is deliberately approximate: the budget exists to catch
order-of-magnitude regressions, not to replace a tokenizer. Link mode requires the
toolkit to stay at the path recorded at install time, and `ctk doctor` will tell
you when it has moved. The Flutter module's scripts are verified for their argument
handling, failure paths, and secret hygiene, but the Flutter SDK itself is not
available in CI, so build commands are exercised as dry runs there.

## How it works

Three layers, and only the first and third are ever always present:

| Layer | Contents | Loaded | Budget |
|---|---|---|---|
| L1 Core | `core/CLAUDE.core.md`, the operating rules | every session | **1,200 tokens, enforced** |
| L2 On-demand | commands, subagents, skills, modules | on invocation only | not needed |
| L3 State | `.claude/ctk/STATE.md`, session continuity | every session | **400 tokens, enforced** |

`ctk budget` measures L1 plus L3 and exits nonzero on a breach. CI runs it on every
push, so the toolkit cannot quietly regress into the v2 failure mode. The budget is
a build constraint, not a guideline.

The subagent design is the other half of the cost story. Repository reconnaissance
can cost tens of thousands of tokens, and in a normal session all of it stays in
context afterwards. Delegating it to `investigator` moves that cost into a
throwaway context window and returns a structured summary. The work still happens;
the main thread just does not carry the raw material for the rest of the session.

History is handled the same way. `STATE.md` is the capped working set. Entries that
age out rotate into `.claude/ctk/archive/`, which is never read automatically.
Nothing is lost. History becomes something you query when a question needs it,
rather than something recited at the start of every session that does not.

Full detail in [docs/architecture.md](docs/architecture.md) and
[docs/token-budget.md](docs/token-budget.md).

## Repository layout

```
core/CLAUDE.core.md          the always-loaded rules, budget-enforced
core/profiles/               which assets each profile installs
bin/ctk                      POSIX sh CLI, zero dependencies
bin/ctk.ps1                  PowerShell 5.1+, identical surface
.claude/commands/ctk/        slash commands
.claude/agents/              subagents, isolated context
.claude/skills/              progressively disclosed skills
.claude/settings.json        hook wiring
hooks/                       session-start, pre-edit guard, post-edit format
modules/flutter-android/     opt-in Flutter and Android release workflows
tests/run.sh                 test harness with fixtures
docs/                        architecture, install, uninstall, budget, modules
```

## Requirements

- **Claude Code.** The commands, subagents, skills, and hooks target its
  extension points.
- **A POSIX shell** (`sh`, `dash`, `bash`, `zsh`) on Linux, macOS, or WSL, **or**
  PowerShell 5.1 or later on Windows.
- **`git`** for drift and secret checks, and for the revert path.
- Nothing else at runtime. `shellcheck` and `PyYAML` are needed only to run the
  full CI checks locally.
- The Flutter module additionally needs the Flutter SDK, a JDK, and the Android
  SDK, and reports them as unavailable rather than failing confusingly when they
  are absent.

## Documentation

| Document | Contents |
|---|---|
| [docs/architecture.md](docs/architecture.md) | Layer model, managed-block injection, design rationale |
| [docs/token-budget.md](docs/token-budget.md) | What is measured, why, and how to keep the core small |
| [docs/install.md](docs/install.md) | Full installation and profile reference |
| [docs/uninstall.md](docs/uninstall.md) | Every reversal path |
| [docs/writing-modules.md](docs/writing-modules.md) | The module contract |
| [docs/migrating-from-v2.md](docs/migrating-from-v2.md) | v2 to v3 mapping and upgrade steps |
| [modules/flutter-android/README.md](modules/flutter-android/README.md) | Flutter and Android release workflows |
| [SECURITY.md](SECURITY.md) | Threat model, secret handling, disclosure |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Constraints, checks, how to add commands and modules |

## Contributing

Issues and pull requests are welcome. The constraints in
[CONTRIBUTING.md](CONTRIBUTING.md) are what keep the toolkit useful, and the token
budget is the one that gets enforced automatically. Before opening a pull request:

```sh
sh tests/run.sh
bin/ctk budget
shellcheck -s sh bin/ctk hooks/*.sh modules/*/scripts/*.sh
```

## License

MIT. See [LICENSE](LICENSE).
