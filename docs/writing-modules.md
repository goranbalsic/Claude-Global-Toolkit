# Writing a module

A module packages stack-specific workflows so they can be added to a project that
needs them and stay entirely absent from a project that does not. The
Flutter/Android module is the reference implementation; read
[`modules/flutter-android/`](../modules/flutter-android/) alongside this document.

The authoritative contract lives in [`modules/README.md`](../modules/README.md).
This document covers the reasoning behind it and the parts that are easy to get
wrong.

## The three rules that matter

**A module is opt-in, and the core never depends on it.** Nothing in
`core/CLAUDE.core.md` or in `.claude/commands/ctk/` may reference a module. A
project that installs no modules must still have the complete core surface. If a
core command needs module behaviour, the design is wrong.

**A module costs zero tokens until one of its commands is invoked.** Nothing a
module ships may end up in the always-loaded surface. This is what makes it
acceptable for a module to be as large as its stack requires.

**Detection is conservative.** A module declares how to tell whether it applies. A
false negative means someone types one extra flag. A false positive means
stack-specific commands appear in a repository where they are wrong, which is worse.
The Flutter module requires a `pubspec.yaml` that contains `flutter:`, not merely a
`pubspec.yaml`.

## Layout

```
modules/<name>/
  module.md       declaration: name, version, profiles, detection, token-cost
  README.md       operator documentation
  commands/       slash-command definitions with YAML frontmatter
  scripts/        POSIX sh helpers that do the actual work
```

## Commands are dispatchers, not documents

The failure mode this toolkit was rewritten to escape is prose that describes work
instead of performing it. A module command should be short, call a script, and
report the result. If a command file is growing past sixty lines of instruction,
the logic belongs in the script.

Put deterministic context into the command with the `!`-prefixed bash injection
syntax rather than asking the model to go and discover it. Handing the model a
`git status` costs a few tokens; making it work out the state itself costs
thousands.

## Scripts carry the weight

Requirements, all of which are enforced by CI:

```sh
#!/bin/sh
set -eu
```

- POSIX `sh` only. No arrays, no `[[ ]]`, no `local` without a guard.
- `shellcheck -s sh` clean.
- `--help` and `--dry-run` on everything. `--dry-run` must not mutate.
- Validate that the script is in the right kind of project and fail with a clear
  message and a nonzero status if not.
- Detect a missing tool and report it as unavailable rather than crashing. A
  contributor without your SDK installed must still be able to run the test suite.
- Print exactly what was run and the honest result: passed, failed, skipped, or
  unavailable.
- Quote every path. Assume directory names contain spaces.

## Never carry a workaround as universal truth

A quirk from one project is not a fact about the stack. The Flutter module defaults
test concurrency to `-j 1` because a real project hit a test-runner concurrency bug,
but it exposes `--jobs N` and `CTK_FLUTTER_TEST_JOBS` and documents why the default
is what it is. Someone else's project should not inherit a slow default with no
explanation and no way out.

## Secrets

If a module touches credentials, signing, publishing, or deployment:

- Never print, echo, or log a secret value, not even in `--dry-run` output.
- Never write a secret to a file the module creates.
- Actively check that secret-bearing paths are not tracked by git, using
  `git ls-files`, and fail if they are. The Flutter module's `preflight.sh` does
  this for `*.keystore`, `*.jks`, `*.p12`, `key.properties`, and `.env*`.
- Document the correct pattern in the module README: a gitignored local file or
  environment variables, referenced from the build configuration, with CI supplying
  values from its own secret store.

A guard needs a test that proves it fires, not a comment claiming it does.

## Checklist before proposing a module

```sh
sh -n modules/<name>/scripts/*.sh
shellcheck -s sh modules/<name>/scripts/*.sh
for s in modules/<name>/scripts/*.sh; do sh "$s" --help >/dev/null || echo "no --help: $s"; done
( cd /tmp && sh /path/to/modules/<name>/scripts/<script>.sh; echo "exit=$?" )  # expect a clear message, nonzero
sh tests/run.sh
bin/ctk budget
```

The fourth line is the one contributors skip. Running a module's script from a
directory where the module does not apply is the most common way a user meets it,
and it should produce one clear sentence rather than a stack trace.

Then add the module to a profile manifest in `core/profiles/`, but only after its
standalone checks pass.
