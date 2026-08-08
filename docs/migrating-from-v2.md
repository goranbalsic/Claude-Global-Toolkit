# Migrating from v2.2.0

## What happened to v2

Version 2.2.0 is preserved in full as the `v2.2.0` git tag. Nothing was deleted
from history. To read it, browse it, or go back to it:

```sh
# read the old tree without changing your checkout
git show v2.2.0:HOW_TO_USE.md
git ls-tree -r --name-only v2.2.0

# recover a single file from v2
git checkout v2.2.0 -- chapters/01-daily-operating-loop.md

# put your whole working tree back on v2.2.0
git checkout v2.2.0
```

## Why it changed

Version 2 was a handbook: 87 files describing how an agent should behave. It was
carefully reasoned, and its own final audit was honest about the gap that
mattered, namely that the toolkit had never been exercised end to end.

Two concrete problems came out of using it on a real project:

1. **Session-start cost.** The read order it installed pulled in `DECISIONS.md`
   (104 KB), `PROJECT_CONTEXT.md` (28 KB), `PROMPTS.md` (25 KB) and
   `OPEN_QUESTIONS.md` (17 KB) before any work started, and those files only
   grew. That is roughly 45,000 tokens of preamble per session.
2. **No executable capability.** Claude Code extends through slash commands,
   subagents, skills, and hooks. Version 2 described these in its chapters but
   implemented none of them. It gave the agent advice where it could have given
   the agent tools.

Version 3 keeps the reasoning that was good, enforces a token budget in CI, and
implements the extension points.

## Mapping

| v2 | v3 |
|---|---|
| `GLOBAL_CLAUDE.md` | `core/CLAUDE.core.md`, tightened and budget-enforced |
| `scripts/install.sh` / `.ps1` | `bin/ctk install`, non-destructive, plus `update`, `uninstall`, `restore`, `status`, `doctor`, `budget`, `state` |
| `prompts/*.md` | `.claude/commands/ctk/*.md`, invokable slash commands |
| `checklists/*.md` | folded into the commands that enforce them (`/ctk:verify`, `/ctk:ship`, `/ctk:review`) |
| `templates/*.md` | folded into the commands that write them (`/ctk:decide`, `/ctk:plan`, `/ctk:checkpoint`) |
| `chapters/*.md` | distilled into `docs/` and into `.claude/skills/` |
| `DECISIONS.md` as a mandatory read | `.claude/ctk/STATE.md`, capped and rotated; `DECISIONS.md` remains an append-only record but is no longer in the read path |
| `PROJECT_STATUS.md`, `ROADMAP.md`, `IDEAS.md`, `OPEN_QUESTIONS.md`, `SOURCE_REGISTER.md`, `PROMPTS.md`, `session_logs/`, `summaries/`, `reviews/` | removed from the product; these were the toolkit's own build diary, and they live in the `v2.2.0` tag |
| `sources/`, `exports/` | removed; input material and generated artifacts do not belong in a distributed repository |
| no uninstall, by policy | `ctk uninstall`, which removes only the managed block |

## Upgrading a project that already adopted v2

A v2 adoption is a `CLAUDE.md` whose contents came from `GLOBAL_CLAUDE.md`,
sometimes with a project-specific section appended below it.

```sh
cd /path/to/your/project

# 1. See what v3 would do, without writing anything.
/path/to/Claude-Global-Toolkit/bin/ctk install --dry-run --profile standard

# 2. Keep a copy of the v2 file. ctk backs up automatically, but an explicit
#    copy makes the diff easy to reason about afterwards.
cp CLAUDE.md CLAUDE.md.v2

# 3. Install. Your existing content is preserved; v3 only adds its block.
/path/to/Claude-Global-Toolkit/bin/ctk install --profile standard

# 4. Remove the old inlined v2 rules by hand, keeping any project-specific
#    rules you wrote yourself. The v3 block now supplies the universal rules,
#    so leaving the v2 copy in place would duplicate them.
```

Then delete the v2 session-start read order if you had one. That block is the
source of the per-session cost. Replace it with `/ctk:resume`, which reads the
capped state file instead.

If the project adopted v2's memory bundle (`PROJECT_CONTEXT.md`,
`PROJECT_RULES.md`, `PROMPTS.md`, `IDEAS.md`, `OPEN_QUESTIONS.md`), you do not
have to delete those files. Just stop requiring them to be read on every session.
Move the few facts that genuinely need to be present at session start into
`.claude/ctk/STATE.md` and let the rest be consulted on demand.

## Verifying the improvement

```sh
ctk budget          # always-loaded surface, measured, with pass/fail
ctk doctor          # drift, orphaned markers, budget, missing assets
ctk status          # what is installed here, which profile, which version
```

`ctk budget` is the number that matters. Compare it against the size of whatever
your v2 read order actually loaded.

## Rolling back to v2 entirely

```sh
cd /path/to/Claude-Global-Toolkit
git checkout v2.2.0
./scripts/install.sh --target-repo /path/to/your/project
```

The v3 managed block in a project can be removed independently at any time with
`ctk uninstall`, whether or not you roll the toolkit itself back.
