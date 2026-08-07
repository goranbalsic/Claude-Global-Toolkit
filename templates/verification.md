# Verification template

Use with `prompts/verification.md`.

```markdown
# Verification: <task>

| Check | Command | Result | Notes |
|---|---|---|---|
| Tests | `<command>` | Passed / Failed / Skipped / Unavailable | |
| Types | `<command>` | Passed / Failed / Skipped / Unavailable | |
| Lint | `<command>` | Passed / Failed / Skipped / Unavailable | |
| Build | `<command>` | Passed / Failed / Skipped / Unavailable | |
| Links | `<command/tool>` | Passed / Failed / Skipped / Unavailable | |
| Security | `<command/tool>` | Passed / Failed / Skipped / Unavailable | |
| Manual check | <what was actually exercised, e.g. UI flow> | Passed / Failed / Skipped / Unavailable | |

## Impact of failed/skipped checks
<State explicitly whether any failure or skip blocks calling this done.>

## Conclusion
<Done / not done, with reasoning.>
```
