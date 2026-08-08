# Installation reference

## Get the toolkit

```sh
git clone https://github.com/goranbalsic/Claude-Global-Toolkit.git
cd Claude-Global-Toolkit
chmod +x bin/ctk
```

There is no build step and nothing to install. `bin/ctk` is POSIX `sh` and uses only
coreutils, `sed`, `awk`, and `grep`.

Optional, to call it from anywhere:

```sh
ln -s "$PWD/bin/ctk" ~/.local/bin/ctk
```

Windows uses `bin\ctk.ps1`, which has an identical command surface:

```powershell
git clone https://github.com/goranbalsic/Claude-Global-Toolkit.git
cd Claude-Global-Toolkit
.\bin\ctk.ps1 budget
```

## Verify the checkout before trusting it

```sh
sh tests/run.sh     # expect: all tests pass
bin/ctk budget      # expect: PASS, with the measured always-loaded cost
bin/ctk version
```

The toolkit's central claim is that its always-loaded cost is small and bounded.
`ctk budget` is how you check that claim rather than taking it on faith.

## Adopt it in a project

```sh
cd /path/to/your/project

ctk install --dry-run     # list every change, write nothing
ctk install               # standard profile, link mode
ctk status                # confirm what landed
```

## Profiles

```sh
ctk install --profile minimal
ctk install --profile standard    # default
ctk install --profile full
```

| Profile | Stages | Choose it when |
|---|---|---|
| `minimal` | the core rules only | you want the operating rules and nothing else |
| `standard` | core, bounded state, slash commands, hooks, `settings.json` | normal day-to-day work |
| `full` | standard, plus subagents, skills, and applicable modules | Flutter/Android work, or a larger project where delegation pays off |

Profiles are defined in `core/profiles/*.txt` as plain manifests. Read them to see
exactly what each one does; edit them if you want a different default.

## Injection modes

**Link mode**, the default and the cheapest:

```sh
ctk install --link
```

The managed block contains a single `@`-import pointing at the core on disk. Claude
Code resolves it natively, so the project's instruction file carries roughly fifteen
tokens. One core is shared by every project, and editing the toolkit updates all of
them immediately with no reinstall.

The tradeoff: the toolkit must stay at the path recorded at install time.
`ctk doctor` reports it if the path becomes invalid.

**Embed mode**, for a self-contained project:

```sh
ctk install --embed
```

The core is inlined into the block. The project works on a machine that has never
seen the toolkit, at the cost of duplicating the core and needing `ctk update` per
project. Use this for a repository you hand to someone else, or for CI images.

**Global mode**, optional and never the default:

```sh
ctk install --global
```

This is the only operation that writes outside a target directory. It manages a
block in `~/.claude/CLAUDE.md`, so the rules apply in every Claude Code session
without a per-project install. A project's own `CLAUDE.md` still takes precedence
where the two conflict.

Global and per-project installation are not mutually exclusive, but installing both
means the core is present twice. Pick one.

## Modules

```sh
ctk install --profile full                          # stage modules that apply
ctk install --profile full --module flutter-android # stage one explicitly
ctk install --profile standard --no-modules         # never stage modules
```

A module declares a detection rule and is staged only when it applies. The
Flutter/Android module applies when the target has a `pubspec.yaml` containing
`flutter:`. Detection is deliberately conservative: a false negative is safer than
offering a stack-specific command in the wrong repository.

## What installation actually writes

Into the target's `CLAUDE.md`, appended, never overwriting:

```markdown
<!-- ctk:begin v=3.0.0 profile=standard hash=a1b2c3d4e5f6 sep=0 -->
@/home/you/Claude-Global-Toolkit/core/CLAUDE.core.md
<!-- ctk:end -->
```

Alongside it, depending on profile:

```
.claude/commands/ctk/       slash commands
.claude/agents/             subagents          (full)
.claude/skills/             skills             (full)
.claude/settings.json       hook wiring
.claude/ctk/STATE.md        bounded state scaffold
.claude/ctk/installed.txt   manifest of staged paths and hashes
.ctk-backup/                timestamped backups of anything modified
```

`installed.txt` records a hash for every staged file, which is what lets `uninstall`
remove exactly what it installed and keep anything you edited afterwards.

## Global flags

| Flag | Effect |
|---|---|
| `--target DIR` | operate on `DIR` instead of the current directory |
| `--dry-run` | describe the operation, write nothing |
| `--yes` | do not prompt, for scripted or CI use |
| `--profile NAME` | `minimal`, `standard`, or `full` |
| `--link` / `--embed` | injection mode |
| `--global` | target `~/.claude` |
| `--module NAME` | stage a module explicitly, repeatable |
| `--no-modules` | never stage modules |

## After installing

```sh
ctk status      # installed profile, version, staged file count
ctk doctor      # drift, orphaned markers, budget, missing or modified assets
ctk budget      # measured always-loaded cost
```

Then, in Claude Code, `/ctk:resume` to orient and `/ctk:verify` to confirm the
project's own checks still pass.

## Updating

```sh
ctk update --dry-run
ctk update
```

Replaces the managed block body in place. Everything outside the markers is
untouched, so local rules survive. In link mode there is usually nothing to update,
because the import is resolved live; `ctk doctor` will tell you when the recorded
hash no longer matches.

## Zero-manual sync after the first install

`ctk update` above is the manual path. If you'd rather never type `ctk install`,
`ctk update`, or `ctk doctor` again after the first time, run the one-time machine
bootstrap once:

```sh
ctk bootstrap --yes
```

After that, restarting Claude Code inside any already-managed project
automatically synchronizes safe CTK-managed changes; a brand-new project gets one
approval prompt instead of a terminal command hunt. See
[zero-manual-sync.md](zero-manual-sync.md) for the full explanation, safety
guarantees, and recovery steps.

## Removing

See [uninstall.md](uninstall.md).
