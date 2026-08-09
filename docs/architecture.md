# Architecture

## The problem this design solves

An agent toolkit has one scarce resource: the context window. Every rule,
checklist, and history file that loads on every turn is paid for on every turn,
in latency and in tokens. Most toolkits grow by adding documents, so their cost
grows monotonically while their usefulness does not.

Version 2 of this toolkit had that shape. It shipped 87 files and roughly 338 KB
of Markdown, and the session-start read order it installed into a real project
pulled in four history files totalling about 175 KB, or roughly 45,000 tokens,
before any work began. Those files grew every session. Nothing capped them.

Version 3 is built around one rule:

> Cost scales with use, not with size.

## Three layers

| Layer | Contents | Loaded | Budget |
|---|---|---|---|
| L1 Core | `core/CLAUDE.core.md`, the operating rules | every session | 1,200 tokens, enforced |
| L2 On-demand | slash commands, subagents, skills, modules | on invocation only | none needed |
| L3 State | `.claude/ctk/STATE.md`, session continuity | every session | 400 tokens, enforced |

Only L1 and L3 are always present. Together they are the *always-loaded surface*,
and `ctk budget` measures it. CI fails if either layer exceeds its budget, so the
toolkit cannot silently regress into the v2 failure mode. The budget is a build
constraint, not a guideline.

L2 costs nothing until invoked. A slash command is read when the user types it. A
subagent runs in its own context window and returns a digest, so repository
reconnaissance that would cost tens of thousands of tokens in the main thread
costs the main thread only the summary. A module contributes zero tokens to a
project that does not use it.

## Bounded state instead of unbounded history

The v2 pattern was: append to `DECISIONS.md` forever, and read it at the start of
every session. That is correct for auditability and catastrophic for cost.

The v3 pattern separates the two needs:

- `.claude/ctk/STATE.md` is the working set. It is capped, and `ctk state add`
  rotates the oldest entries out when the cap is reached.
- `.claude/ctk/archive/` holds everything rotated out. It is never read
  automatically. It is there for when someone asks a question that needs it.

Nothing is lost. What changes is that history is queried on demand rather than
recited on arrival.

## Non-destructive injection

`ctk` never overwrites a target file. It manages a delimited block:

```
<!-- ctk:begin v=3.4.0 profile=standard hash=a1b2c3d4e5f6 sep=0 -->
...managed content...
<!-- ctk:end -->
```

Everything outside the markers belongs to the project and is preserved byte for
byte. This gives each lifecycle operation a precise definition:

| Operation | Effect |
|---|---|
| `install` | append the block if absent; no-op if already current |
| `update` | replace the block body only |
| `uninstall` | delete the block only; remove the file if nothing else remains |
| `doctor` | compare the recorded `hash=` against the current core to detect drift |

The `hash` field is the first 12 hex characters of the SHA-256 of the core file,
which makes drift detection a string comparison rather than a diff.

Every mutating command takes a timestamped backup into `.ctk-backup/` first, and
`ctk restore` reverses it. Every mutating command also accepts `--dry-run`.

Version 2 copied its baseline over the target's entire `CLAUDE.md`. Any
project-specific rules were replaced, and updating the baseline meant
re-applying local edits by hand. That is the single largest robustness change in
v3.

## Two injection modes

`--link` writes one `@`-import line pointing at the toolkit on disk. Claude Code
resolves the import natively, so the project's own instruction file carries about
fifteen tokens and the core is shared by every project. Updating the toolkit
updates every project at once, with no reinstall.

`--embed` inlines the core. The project becomes self-contained and works on a
machine without the toolkit installed, at the cost of duplicating the core and
needing `ctk update` per project.

`--link` is the default because it is cheaper and because a single shared core is
easier to keep honest.

## Why the core is small

The core contains rules that hold in every repository, in every language, on
every task. Anything narrower belongs in a module, a skill, or the project's own
instructions. This is what makes the core safe to inject into a repository the
toolkit knows nothing about, and it is why the 1,200-token budget is a feature
rather than a limitation: the budget is the mechanism that keeps the core
universal.

## Dependencies

None at runtime. `bin/ctk` is POSIX `sh`, `bin/ctk.ps1` is PowerShell 5.1. No
package installs, no network calls, no telemetry. The toolkit reads and writes
files in the target directory and nowhere else.
