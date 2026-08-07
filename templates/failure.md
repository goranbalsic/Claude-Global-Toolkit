# Failure template

Use to record a bug, a failed approach, or a verification failure worth
remembering so it isn't repeated.

```markdown
# Failure: <short title>

## What was attempted
<The approach, command, or change that failed.>

## Failure scenario
<Concrete: input/state → wrong output/crash/error message.>

## Root cause
<If known. If unknown, say Unknown — do not guess and present it as known.>

## Impact
<What this blocks or breaks, and severity.>

## Resolution
<Fix applied, or status if still open — link the DECISIONS.md entry or
commit if resolved.>

## Prevention
<Regression test added? Process change? Note it, or state none was added and why.>
```
