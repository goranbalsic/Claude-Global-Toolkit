# Contributing

Contributions are welcome. This document is short on purpose; the constraints
below are the ones that keep the toolkit useful.

## Non-negotiable constraints

1. **The token budget is a build constraint.** The always-loaded surface is
   capped: 1,200 tokens for `core/CLAUDE.core.md`, 400 for
   `.claude/ctk/STATE.md`. `ctk budget` measures it and CI fails on a breach. A
   change that needs more room in the core almost always belongs in a skill, a
   command, or a module instead.
2. **No runtime dependencies.** `bin/ctk` is POSIX `sh`. `bin/ctk.ps1` is
   PowerShell 5.1. Scripts may use coreutils, `sed`, `awk`, `grep`. Anything
   else must be optional and degrade cleanly when absent, including `jq`.
3. **No network calls, no package installs, no telemetry** at runtime, ever.
4. **Never write outside the target directory.** The one exception is
   `--global`, which is explicit in the command name and documented.
5. **Every mutating operation needs `--dry-run`, a backup, and a documented
   reversal.** Non-destructive editing of managed blocks is the core safety
   property; do not add a code path that rewrites a whole user file.
6. **Do not claim something was tested unless it was run.** This applies to
   commit messages, pull request descriptions, and any documentation you add.
7. **Cross-platform.** Linux, macOS, and Windows. If you change `bin/ctk`,
   make the matching change in `bin/ctk.ps1`, and keep the CLI surface identical.

## Before opening a pull request

```sh
sh tests/run.sh                       # must pass
bin/ctk budget                        # must pass
shellcheck -s sh bin/ctk hooks/*.sh modules/*/scripts/*.sh
python3 -m json.tool .claude/settings.json >/dev/null
```

CI runs the same checks on Linux, macOS, and Windows.

## Adding a slash command

Commands live in `.claude/commands/ctk/`. Keep one to 20-60 lines. A command
should invoke real tooling and report honest results, not restate a procedure in
prose. Use the `!`-prefixed bash injection syntax for cheap deterministic context
so the model does not spend tokens rediscovering state it could be handed.

## Adding a subagent

Subagents live in `.claude/agents/`. Their purpose is token economics: they run in
a separate context window and return a digest. A subagent that dumps raw file
contents back into the main thread defeats its own reason for existing. Set
`model` to the cheapest one that does the job.

## Adding a module

See `modules/README.md` for the contract. The rules that matter:

- A module must be opt-in, and the core must never depend on it.
- A module must contribute zero tokens to a project that does not use it.
- A module must declare a detection rule so it can tell whether it applies.
- A module must not hardcode a workaround as universal truth. If you carry a
  project-specific quirk, make it configurable and document why it exists.

## Security-relevant changes

Anything touching secret handling, file deletion, or global configuration needs a
test that proves the guard works, not an assertion that it does. See
`SECURITY.md`.

## Commit messages

Imperative mood, one logical change per commit, and a body that explains why when
the reason is not obvious from the diff.
