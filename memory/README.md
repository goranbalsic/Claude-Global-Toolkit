# memory/

Required by SRC-002 (`sources/update.txt`), but SRC-002 never defines what
this directory should actually contain — unlike `summaries/` and
`session_logs/`, which both get explicit instructions in that source. See
`OPEN_QUESTIONS.md` QUESTION-001; this is a stated inference, not a
confirmed requirement.

## Working interpretation (until QUESTION-001 is resolved)

A place for structured memory extracts too detailed to inline elsewhere:
long prompt-summary write-ups that don't fit `PROMPTS.md`'s "Prompt
Summaries" section comfortably, or other structured context artifacts that
don't match `PROJECT_CONTEXT.md`, `PROJECT_RULES.md`, `DECISIONS.md`,
`IDEAS.md`, or `OPEN_QUESTIONS.md`'s stated scope.

## Current status

Empty as of 2026-08-07. Per the recommended default in `OPEN_QUESTIONS.md`
QUESTION-001, nothing is being added here speculatively — a file goes here
only when a concrete case arises that genuinely doesn't fit any of the
named root files.
