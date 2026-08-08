# Zero-manual project sync

`ctk install` and `ctk update` are terminal commands you run by hand. Nothing
about running them makes a *second* project, or a *later* Claude Code session,
know that the toolkit changed. This page covers the one-time machine bootstrap
that closes that gap, and exactly what happens automatically afterward.

## The distinction that matters

**Updating the CTK source checkout** (`git pull` in `Claude-Global-Toolkit`, or
however you keep it current) changes only that checkout. It does not touch any
project. **Project synchronization** is the separate act of copying the current
managed block, commands, hooks, agents, and skills into one target project's
`.claude/` directory and `CLAUDE.md`. `ctk update` does this by hand; the
bootstrap below does it automatically, only for projects that are already
CTK-managed, and only when it is safe to do so.

## One-time setup, once per machine

```sh
# POSIX (Linux, macOS, WSL)
/path/to/Claude-Global-Toolkit/bin/ctk bootstrap
```

```powershell
# Windows PowerShell
& "C:\path\to\Claude-Global-Toolkit\bin\ctk.ps1" bootstrap
```

This does two things, both reversible:

1. Writes a small registration record — the toolkit's own root path, version,
   and an automation policy — to `~/.claude/ctk/registration.txt` (POSIX) or
   `%USERPROFILE%\.claude\ctk\registration.txt` (Windows). Not a copy of any
   project file, not a copy of the toolkit itself.
2. Adds one `SessionStart` hook entry to your **user-level**
   `~/.claude/settings.json`, pointing at `router/session-sync-router.sh` (or
   `.ps1`) by absolute path. This fires in every Claude Code session, in every
   project, which is the only way a session can react automatically without a
   terminal command — but the router itself does nothing but decide and defer;
   see [Safety](#safety) below for exactly what it is and is not allowed to do.

Bootstrap never touches `ctk` on `PATH`; the router always calls the registered
script by its recorded absolute path. It is idempotent (running it again after
moving the checkout just re-registers the new location) and accepts `--yes` for
non-interactive use, `--dry-run` to preview, and `--auto-apply` to opt into
skipping even the first-install approval prompt (off by default).

To reverse it:

```sh
ctk disable        # POSIX
ctk.ps1 disable    # Windows
```

This removes only the registration record and the one hook entry it added.
Anything else in `~/.claude/settings.json` is left exactly as it was.

## Ordinary use after bootstrap

1. Update the CTK checkout however you normally do (`git pull`, etc.).
2. Restart or open Claude Code in a project that already has CTK installed.
3. Nothing else. The session-start router notices the checkout changed, checks
   that every CTK-managed file in the project still matches what was last
   staged, and if so replaces the managed block and re-stages the profile —
   silently, except for one line such as:

   ```text
   CTK: updated to 3.2.0 (standard profile); project state healthy.
   ```

   If nothing changed, the line is `CTK: current (...)` and nothing is written.

No terminal command, no `PATH` edit, no file editing. `.claude/ctk/STATE.md`
(and anything else `ctk state`/`ctk goal` manage) is preserved through every
sync; those files are data the tools own, not template copies that get reset.

## First time in a new project

The router never installs CTK into a project on its own. The first write to a
project's files always requires approval:

```text
CTK: setup available for this project (standard profile); approval required
before CTK-managed files are added.
```

Say yes in the chat, and the assistant runs the same `ctk install` you would
have typed, with the profile the router already detected (`full` when a
Flutter/Android marker is present, `standard` otherwise). One limitation worth
stating plainly: newly staged slash commands are not guaranteed to be visible
until the *next* session start, since Claude Code loads project commands at
session start, not mid-session. Restart once after an approved first install;
no restart is needed for ordinary synchronization of an already-managed
project.

If you explicitly set `--auto-apply` at bootstrap time, first installs into any
git-tracked project happen without that prompt. This is opt-in and off by
default; turning it on means you trust CTK to add its own files to any
recognized project without asking each time.

## Safety

- The router only ever writes files by calling the same tested
  `ctk install`/`ctk update` commands you could type yourself, in a
  non-interactive safe-sync mode (`--session-sync`); it never contains its own
  copy of install logic.
- If any CTK-managed file in a project was edited locally since it was staged,
  synchronization stops before writing anything and reports the conflict. Your
  edit is never overwritten by an automatic sync.
- Legacy or ambiguous CTK state (orphaned markers, a managed block with no
  install manifest) is left untouched; the router names `ctk doctor` as the one
  recovery command.
- A moved or deleted CTK checkout is detected before any project write; the
  router names `ctk bootstrap` (pointed at the new location) as the recovery
  step.
- A directory with no CTK block and no recognizable project marker (no `.git`)
  produces no output and creates no files.
- Application source, Gradle files, manifests, dependencies, and credentials
  are never touched by synchronization — only the files `ctk install` itself
  would ever stage.
- No network calls, no telemetry, no background process. The router runs once
  per session start and exits.

## Recovery quick reference

| Situation | What you see | What to do |
|---|---|---|
| CTK checkout moved or deleted | `CTK: registered checkout is missing or moved (...)` | Re-run `ctk bootstrap` from the new location |
| Local edit to a managed file | `CTK: locally modified managed file detected (...)` | Review the file; `ctk doctor` for detail; `ctk update` manually once you've decided |
| Orphaned or unrecorded CTK state | `CTK: unrecognized or legacy CTK state (...)` | `ctk doctor` in the project, then resolve manually |
| Post-sync health check failed | `CTK: sync applied but the health check failed (...)` | A backup is in `.ctk-backup/`; `ctk doctor` to inspect |
| Want automation off | — | `ctk disable` |

## Commands referenced here

`ctk bootstrap`, `ctk disable`, `ctk install`, `ctk update --session-sync`,
`ctk doctor` — all in `bin/ctk` / `bin/ctk.ps1`. In Claude Code itself, nothing
changes: `/ctk:resume`, `/ctk:checkpoint`, `/ctk:goal`, `/ctk:refine`, and the
rest of the `/ctk:*` commands work the same as before, once a project has been
synchronized.
