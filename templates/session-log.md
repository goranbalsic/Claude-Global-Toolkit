# session_logs/ entry template

Part of the optional memory-system bundle (see `HOW_TO_USE.md` → "Optional:
memory and decision continuity"). Copy into a target repository's
`session_logs/` directory (create it if needed) as
`YYYY-MM-DD-session-NN.md` at the end of a meaningful session. Distinct
from `templates/handoff.md`: a handoff/batch summary is milestone-level and
goes in `summaries/`; a session log is finer-grained, dated, and written
every meaningful session, not just at the end of a batch.

```markdown
# Session Log

## Date

## Session Objective

## Context Read

Files and documents reviewed.

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

Which memory files were updated?

## Next Recommended Action
```

Read the latest entry in `session_logs/` at the start of a session, and
write a new one at the end of every meaningful session — see
`PROJECT_RULES.md`'s "Memory Maintenance" section if that file is present.
