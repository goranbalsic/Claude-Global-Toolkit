# Token budget

## Why there is a budget at all

Anything an agent loads on every session is paid for on every session. A rule that
is 200 tokens long and genuinely changes behaviour is a bargain. A history file
that is 26,000 tokens long and is read out of habit is not, and it gets worse every
week because history only grows.

The measured cost of the previous version of this toolkit, as it was actually
installed in a real project, was about 45,000 tokens of preamble before any work
began, spread across four files that grew every session:

| File | Size | Approx. tokens |
|---|---|---|
| `DECISIONS.md` | 104 KB | ~26,000 |
| `PROJECT_CONTEXT.md` | 28 KB | ~7,000 |
| `PROMPTS.md` | 25 KB | ~6,400 |
| `OPEN_QUESTIONS.md` | 17 KB | ~4,300 |

None of it was capped, and nothing measured it. That is the failure this budget
exists to make impossible.

## The budget

| Surface | File | Cap |
|---|---|---|
| Core rules | `core/CLAUDE.core.md` | 1,200 tokens |
| Session state | `.claude/ctk/STATE.md` | 400 tokens |

```sh
ctk budget
```

It prints bytes and estimated tokens per file plus a total, compares against the
caps, and exits nonzero on a breach. CI runs it on every push and pull request, on
Linux, macOS, and Windows. A change that pushes the core over budget fails the
build.

Token counts are estimated at four bytes per token. That is an approximation, not a
tokenizer, and it is deliberately conservative: the point is to catch order-of-
magnitude regressions, and a cheap estimate that runs everywhere with no
dependencies does that better than an exact count that needs a Python package.

## What the budget buys

Because the always-loaded surface is capped, the rest of the toolkit can be as
large as it needs to be. The cost model is what changed, not the volume of
material.

| Asset | Cost when unused | Cost when used |
|---|---|---|
| Slash command | 0 | the command file, once |
| Subagent | 0 | runs in its own context; the main thread pays only for the returned digest |
| Skill | 0 | its `SKILL.md`, then referenced files only if needed |
| Module | 0 | the invoked command only |
| Archived state | 0 | only when explicitly queried |

The subagent case is the one worth understanding. Repository reconnaissance is
expensive: reading a dozen files to work out how a project is laid out can cost
tens of thousands of tokens, and all of it stays in the main context for the rest
of the session. Delegating that to the `investigator` subagent moves the cost into
a throwaway context window and returns a structured summary. The work still
happens; the main thread just does not carry the raw material afterwards.

## Bounded state, unbounded archive

`.claude/ctk/STATE.md` is the working set: enough to resume a session, and nothing
more. When `ctk state add` would push it over the cap, the oldest entries rotate
into `.claude/ctk/archive/`.

Nothing is lost. The archive is never read automatically, which is the entire
point. History remains available to a question that needs it, without being
recited at the start of every session that does not.

## Keeping the core small

When a rule feels like it belongs in the core, it usually belongs somewhere
cheaper:

| The rule is... | Put it in |
|---|---|
| true in every repository, every language, every task | the core |
| true for one stack | a module |
| true for one kind of task | a skill |
| a procedure with steps to run | a slash command |
| true for one repository | that repository's own `CLAUDE.md`, outside the managed block |

The budget is the forcing function for that triage. It is easier to justify a
1,200-token cap than to argue case by case about whether one more paragraph is
worth it.
