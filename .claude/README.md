# Claude Code extensions

This directory contains on-demand Claude Code capability, not mandatory
session history.

| Path | Purpose |
|---|---|
| `commands/ctk/` | Slash commands: `/ctk:resume`, `/ctk:checkpoint`, `/ctk:decide`, `/ctk:plan`, `/ctk:verify`, `/ctk:review`, `/ctk:ship`, `/ctk:goal`, `/ctk:refine`. |
| `agents/` | Isolated investigators, reviewers, and verifier agents that return compact evidence digests. |
| `skills/` | Progressive-disclosure guidance for bounded continuity, evidence, safe changes, and task-scoped context routing. |
| `settings.json` | Session orientation, edit safety, and file-local formatter hooks. |
| `../hooks/` | POSIX hook implementations referenced by `settings.json`. |

Invoke a command in Claude Code, for example:

```text
/ctk:resume
/ctk:checkpoint added parser; tests passed; next run integration test
/ctk:verify payment flow
/ctk:goal set objective: ship the parser; acceptance: tests pass
```

Hooks use `$CLAUDE_PROJECT_DIR`, make no network calls, and silently no-op
when an optional formatter is unavailable. The edit guard blocks common
credential and Android signing paths before Write or Edit can touch them.
