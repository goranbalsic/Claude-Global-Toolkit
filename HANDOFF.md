# Checkpoint and handoff: 3.3.0

Date: 2026-08-09
Repo: https://github.com/goranbalsic/Claude-Global-Toolkit
Branch: `main`. Latest release line: `3.3.0`.
Revert points: `v3.0.0` tag (first lean release), `v2.2.0` tag (entire v2 tree).

This file replaces the 3.0.0-era handoff. Read `CHANGELOG.md` for the full
per-release record; this is the current state and what to do next.

## What the toolkit is now

Organising rule, unchanged since 3.0.0: **cost scales with use, not with size.**

Three layers:

- **L1 core** — always loaded, `core/CLAUDE.core.md`, **394 tokens, capped at
  1,200, CI-enforced** by `ctk budget`.
- **L2 on-demand** — commands, subagents, skills, modules. Zero cost until
  invoked.
- **L3 bounded state** — `.claude/ctk/STATE.md` (400-token cap, auto-rotates to
  an archive that is never read automatically) and the goal file (300-token
  cap, excluded from the core budget).

Injection is a managed block appended to a project's `CLAUDE.md`; the user's own
content is preserved byte for byte:

```
<!-- ctk:begin v=3.3.0 profile=standard hash=<sha256-12> -->
@/path/to/Claude-Global-Toolkit/core/CLAUDE.core.md
<!-- ctk:end -->
```

`install` appends, `update` rewrites only the block body, `uninstall` removes
only the block, `restore` reverses a modification from `.ctk-backup/`.

## What shipped after 3.0.0

| Release | What it added |
|---|---|
| 3.1.0 | CTKv4 lean workflow: manifest schema, `/ctk:goal`, `/ctk:refine`, bounded context loader |
| 3.2.0 | Zero-manual project sync: `ctk bootstrap` / `ctk disable`, `ctk update --session-sync`, global `SessionStart` router (`sh` + `ps1`), then 8 global `/ctk:*` slash commands installed into `~/.claude/commands/ctk/` |
| 3.3.0 | Polish pass: session sync also refreshes stale global command files; `.gitattributes` LF pin; `router/` added to lint; real Windows CI coverage |

The intended user experience, end to end:

1. **Once per machine:** `ctk bootstrap` (on Windows,
   `powershell -NoProfile -ExecutionPolicy Bypass -File "<CTK>\bin\ctk.ps1" bootstrap`).
2. **Forever after:** open Claude Code in any project and use `/ctk:install`,
   `/ctk:update`, `/ctk:doctor`, `/ctk:status`, `/ctk:resume`,
   `/ctk:checkpoint`, `/ctk:goal`, `/ctk:refine`.

No `PATH` setup, no permanent execution-policy change, no editing
`settings.json`, no terminal lifecycle commands. `docs/zero-manual-sync.md` is
the user-facing explanation.

## Verification actually run for 3.3.0

- `sh tests/run.sh`: **53 passed, 0 failed** on Linux.
- `shellcheck -s sh` over `bin hooks modules router tests`: **clean**.
- `./bin/ctk budget`: **PASS**, 394/1200 core, 0/400 state.
- Frontmatter/YAML validation over `.claude/commands`, `.claude/agents`,
  `.claude/skills`, `modules`, `global-commands`: clean.
- New regression tests prove the global-refresh path repairs drift, stays
  silent when nothing drifted, never creates a file `bootstrap` did not
  install, and refuses to act from an unregistered checkout.

## Known gaps, stated honestly

1. **`bin/ctk.ps1` is not executed in this build environment.** PowerShell is
   unavailable here, so the 3.3.0 PowerShell changes were written to mirror the
   verified `sh` behavior and are covered by CI's parse check plus an advisory
   `windows-latest` lifecycle smoke test — not by a local run. The Windows job
   is the source of truth for them.
2. **The advisory Windows steps are new.** `continue-on-error: true` is set on
   the lifecycle smoke test so a first-run false red cannot block an otherwise
   green build. **Next task: check the first Windows run, then promote that
   step to required.**
3. **The live Claude Code `SessionStart` → router path is proven only by
   running the router directly** with `CLAUDE_PROJECT_DIR` set, plus real-world
   confirmation that bootstrapped `/ctk:*` commands appear and work after a
   restart. Claude Code's own hook dispatch is not exercised by CI.
4. **New slash commands require one Claude Code restart** after first install.
   That is a Claude Code loading behavior, not something CTK can avoid.
5. **On POSIX without `jq`**, merging a `settings.json` that already has
   unrelated content fails closed with exact manual instructions rather than
   text-splicing JSON it cannot parse. Safe, not convenient. Windows merges
   natively via PowerShell's JSON support.
6. **Flutter build commands have never run against a real SDK.** Argument
   handling, failure paths, and secret hygiene are verified; actual
   `flutter build apk` behavior is not.
7. **Token counts are estimated at 4 bytes/token**, deliberately — enough to
   catch order-of-magnitude regressions without a tokenizer dependency.
8. **Link mode breaks if the toolkit checkout moves.** `ctk doctor` reports it;
   `--embed` avoids it.
9. **Version naming.** The work informally called "CTKv4" shipped as 3.1.0 →
   3.3.0 because none of it broke the core rules or the installer contract.
   A `4.0.0` tag would be cosmetic; do it only alongside a real contract change.

## Next actions, in order

1. **Check the first `windows-latest` CI run on 3.3.0.** Fix anything the
   parse check, Git Bash test run, or lifecycle smoke test reports, then drop
   `continue-on-error` from the smoke test. Gap 2.
2. **Confirm the refresh path on the real Windows machine**: `git pull` in the
   CTK checkout, restart Claude Code in a managed project, and check the status
   line mentions refreshed global command files without any `bootstrap` re-run.
3. **Verify the Flutter module against the real SDK**: `/flutter-android:doctor`,
   `:analyze`, `:test`, `:preflight`, `:apk --release --split-per-abi`. Gap 6.
4. Optional: a README asciinema of `ctk install --dry-run` and `ctk budget`.
5. Optional: cut a GitHub Release from the `CHANGELOG.md` 3.3.0 section.

## Reverting

```sh
ctk disable                # remove machine registration, router hook, global commands
ctk uninstall              # remove from one project; --dry-run first
ctk restore                # undo a modification from .ctk-backup/
git checkout v3.0.0        # the pre-bootstrap lean toolkit
git checkout v2.2.0        # the entire v2 toolkit
```

The levels are independent: a project's managed block, the machine-level
bootstrap, and the toolkit checkout itself can each be rolled back separately.

## Repo state

Public, MIT, default branch `main`, issues on, wiki off. CI runs on
`ubuntu-latest`, `macos-latest`, and `windows-latest`. Tags: `v2.2.0`,
`v3.0.0`.
