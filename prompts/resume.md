---
title: Resume
use_when: Continuing work in a repository that already has this toolkit's governance files
related: chapters/01-daily-operating-loop.md, chapters/07-compatibility-and-persistence.md
---

# Prompt: Resume

```
Resume work in this repository using the safe resume instruction:

1. Read CLAUDE.md, PROJECT_CONSTITUTION.md (if present), PROJECT_STATUS.md,
   DECISIONS.md, ROADMAP.md, and the latest file under summaries/ (or the
   latest handoff you were given).
2. Inspect current Git status, branch, and diff against the last known
   state.
3. Run the repository health check (chapters/05-repository-health-check.md)
   at a level proportionate to how long it's been since the last session.
4. Identify the first incomplete deliverable from PROJECT_STATUS.md. Do not
   redo work already marked complete and verified there.
5. State what you're resuming, any discrepancies you found between
   PROJECT_STATUS.md and actual repository state, and how you'll proceed.

Do not begin implementation until steps 1-5 are done and reported.
```
