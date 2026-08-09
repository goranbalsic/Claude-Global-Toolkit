# Checkpoint and handoff: 3.4.0

Date: 2026-08-09
Repo: https://github.com/goranbalsic/Claude-Global-Toolkit
Branch: `main`. Latest release line: `3.4.0`.
Revert points: `v3.0.0` tag (first lean release), `v2.2.0` tag (entire v2 tree).

This file replaces the 3.3.0-era handoff. Read `CHANGELOG.md` for the full
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
<!-- ctk:begin v=3.4.0 profile=standard hash=<sha256-12> -->
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
| 3.4.0 | Fixed real bug: `resume`/`checkpoint`/`goal`/`refine` existed as both a project-local and a global command, so Claude Code's picker showed two entries per name. The four are global-only now; `update`/session-sync converge any pre-3.4.0 project automatically. |

The intended user experience, end to end:

1. **Once per machine:** `ctk bootstrap` (on Windows,
   `powershell -NoProfile -ExecutionPolicy Bypass -File "<CTK>\bin\ctk.ps1" bootstrap`).
2. **Forever after:** open Claude Code in any project and use `/ctk:install`,
   `/ctk:update`, `/ctk:doctor`, `/ctk:status`, `/ctk:resume`,
   `/ctk:checkpoint`, `/ctk:goal`, `/ctk:refine`. The last four need bootstrap
   to have run at least once; they are no longer staged into the project.

No `PATH` setup, no permanent execution-policy change, no editing
`settings.json`, no terminal lifecycle commands. `docs/zero-manual-sync.md` is
the user-facing explanation.

## Verification actually run for 3.4.0

- `sh tests/run.sh`: **58 passed, 4 failed** on this machine (Windows, Git
  Bash) — the 4 failures are the pre-existing CRLF-fixture issue tracked
  since 3.1.0 (`test_user_content_preserved`, `test_update_only_block_body`,
  `test_uninstall_restores_original`, `test_uninstall_removes_unmodified_staged_assets`),
  unrelated to this release; CI's Linux job is unaffected by it.
- 9 new regression tests added for the duplicate-command fix specifically:
  the argument-placeholder/no-duplication contract for every global command
  template, byte-identity between the installed and source global command
  files, shell-metacharacter safety for `state add`/`goal set`, that a fresh
  install never recreates the four now-global-only project-local files, that
  the discovered project-scope and user-scope command inventories never
  share a name, and that a simulated pre-3.4.0 duplicate layout converges
  correctly on `ctk update` (both the unmodified-file-removed and the
  locally-modified-file-kept cases) and through the real, non-interactive
  session-sync router.
- `shellcheck -s sh` over `bin hooks modules router tests`: clean.
- **`bin/ctk.ps1` was actually executed this time**, on a real Windows
  machine with PowerShell available — not just parsed. The fresh-install,
  update-with-unmodified-duplicate, update-with-modified-duplicate, and
  `--dry-run` migration scenarios were run directly against `bin/ctk.ps1`
  and matched `bin/ctk`'s behavior exactly. This closes 3.3.0's Gap 1 for
  this specific change; it is not a claim that every `ctk.ps1` code path has
  now been exercised outside CI.

## Known gaps, stated honestly

1. **`bin/ctk.ps1` is usually not executed outside CI, but was for 3.4.0.**
   This session ran on a real Windows machine with PowerShell available and
   exercised the new migration logic directly against `bin/ctk.ps1` (fresh
   install, unmodified-duplicate update, modified-duplicate update, dry-run),
   matching `bin/ctk`'s behavior in every case. That is real verification of
   this specific change, not of the whole `ctk.ps1` surface — most of the
   file (bootstrap, modules, goal/state lifecycle, session-sync edge cases)
   is still covered only by CI's parse check plus the advisory
   `windows-latest` lifecycle smoke test. Treat any *other* PowerShell change
   the way 3.3.0 did: CI's Windows job is still the source of truth for it.
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
   3.4.0 because none of it broke the core rules or the installer contract.
   A `4.0.0` tag would be cosmetic; do it only alongside a real contract change.
10. **The four now-global-only commands need a bootstrapped machine.**
    Before 3.4.0, a CTK-managed project handed to someone who had never
    bootstrapped still had working (if duplicated) `resume`/`checkpoint`/
    `goal`/`refine` commands, staged locally. Now those four are simply
    absent until that person runs `ctk bootstrap` once. This is the accepted
    tradeoff for fixing the duplicate-picker-entry bug; `docs/zero-manual-sync.md`
    states it plainly.

## Next actions, in order

1. **Check the first `windows-latest` CI run on 3.4.0.** Fix anything the
   parse check, Git Bash test run, or lifecycle smoke test reports, then drop
   `continue-on-error` from the smoke test. Gap 2 (still open — this session's
   manual PowerShell run covers only the 3.4.0 migration logic, not the whole
   smoke-test surface).
2. **In a real Claude Code session on a bootstrapped machine**, confirm what
   this session could only prove at the CLI level: opening a project that
   still has the old duplicate `resume.md`/etc. shows one `/ctk:resume` in
   the picker (not two) after the next session-start sync, and typing
   `/ctk:resume <text>` after autocomplete runs as one message with no
   duplicated instruction.
3. **Verify the Flutter module against the real SDK**: `/flutter-android:doctor`,
   `:analyze`, `:test`, `:preflight`, `:apk --release --split-per-abi`. Gap 6.
4. Optional: a README asciinema of `ctk install --dry-run` and `ctk budget`.
5. Optional: cut a GitHub Release from the `CHANGELOG.md` 3.4.0 section.

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
