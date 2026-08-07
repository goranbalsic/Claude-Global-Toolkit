# Plan template

Use with `prompts/planning.md`.

```markdown
# Plan: <task>

## Objective
<Restated from the spec/requirements.>

## Files affected
| File | Change | Why |
|---|---|---|
| <path> | create / edit / delete | <reason> |

## Steps
1. <Step> — verify: `<command>` — rollback: `<how to undo>`
2. <Step> — verify: `<command>` — rollback: `<how to undo>`

## Dependencies / ordering
<Which steps must happen before others, and why.>

## Checkpoints
<Natural pause points to report progress and get confirmation, especially
before anything in the approval matrix.>

## Non-required components considered and rejected
<Anything that could have been added but wasn't, to head off silent scope
expansion — see chapters/01-daily-operating-loop.md.>
```
