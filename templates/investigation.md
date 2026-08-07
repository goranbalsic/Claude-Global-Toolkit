# Investigation template

Use with `prompts/investigation.md`.

```markdown
# Investigation: <topic>

## Question
<What this investigation is trying to establish.>

## Method
<What was inspected: files read, commands run, tests executed. Be specific —
file:line references, exact commands.>

## Findings
| Claim | Evidence | Confidence |
|---|---|---|
| <finding> | <file:line / command output / doc link> | Confirmed / High / Medium / Low / Unknown |

## Assumptions remaining
- <Anything not directly verifiable within this investigation's scope.>

## Related decisions / prior context
- <Links to DECISIONS.md entries or PROJECT_STATUS.md items this touches.>

## Conclusion
<What this investigation supports doing next — not the implementation itself.>
```
