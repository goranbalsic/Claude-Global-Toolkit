# Handoff template

Use at the end of a session to write a completion report / batch summary
(`summaries/BATCH-<n>.md`) and update `PROJECT_STATUS.md`.

```markdown
# Handoff: <date> — <session focus>

## Files created and changed
- <path> — <what changed>

## Commands actually run
- `<command>` — <result summary>

## Verification results
<Pass/fail/skipped/unavailable per templates/verification.md, or a link to it.>

## Sources inspected / evidence gaps
<What was checked; what remains Low/Unknown confidence.>

## Toolkit installation status and backups
<If scripts/install.* was run: target, backup path if any, confirmation given.>

## Exports or build instructions
<If applicable.>

## Unresolved risks and approval decisions
<Anything still open, and what it's waiting on.>

## Exact resume instruction
<What the next session should read first and where to pick up — see
chapters/07-compatibility-and-persistence.md's safe resume instruction.>
```
