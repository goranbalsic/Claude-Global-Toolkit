# session_logs/

Dated, per-session logs, per SRC-002 (`sources/update.txt`). Distinct from
`summaries/`: `summaries/` holds per-*batch*, milestone-level summaries;
this directory holds per-*session*, dated logs — finer-grained and written
at the end of every meaningful session, not just at the end of a batch.

## Naming convention

```text
YYYY-MM-DD-session-01.md
YYYY-MM-DD-session-02.md
```

Number sequentially within a date if more than one meaningful session
happens the same day.

## Contents

Each session log follows this structure (see any existing log in this
directory for a filled-in example):

```markdown
# Session Log

## Date

## Session Objective

## Context Read

## Work Completed

## Decisions Made

## Alternatives Considered

## Files Changed

## Verification

- Tests:
- Build:
- Manual checks:
- Other validation:

## Incomplete or Blocked Work

## New Ideas

## Context Updates

## Next Recommended Action
```

Read the latest entry here at the start of a session (per `CLAUDE.md`'s
"Start or resume" order), and write a new one at the end of every
meaningful session (per `PROJECT_RULES.md`'s "Memory maintenance" section).
