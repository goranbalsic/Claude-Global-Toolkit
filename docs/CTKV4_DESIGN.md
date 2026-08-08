# CTKv4 design: baseline, what's new, what's deferred

"CTKv4" is this initiative's name, not the toolkit's SemVer major. Every
change in this pass is additive and non-breaking, so the toolkit's own
`VERSION` moved `3.0.0` → `3.1.0`, consistent with `CHANGELOG.md`'s stated
policy ("minor: new commands, agents, skills, modules, or CLI capability").

## Baseline: what CTK3 already had

Before writing any code, this pass inspected `bin/ctk`, `bin/ctk.ps1`,
`.claude/commands|agents|skills`, `modules/`, `tests/run.sh`, and `docs/`.
Most of a much larger "CTKv4" spec turned out to already exist:

| Spec asked for | Already exists as |
|---|---|
| Versioned lifecycle commands (`install`, `update`, `doctor`) | `bin/ctk` / `bin/ctk.ps1`, dual-implemented, 19 tests before this pass |
| Compact task handoff | `.claude/ctk/STATE.md` + `bin/ctk state add\|show\|rotate`, bounded, auto-rotating, read only via a tailed hook and `/ctk:resume` |
| Bounded, non-recursive "specialist" subagents | `.claude/agents/*` — 4 read-only, single-level agents returning a compact digest |
| Deterministic, non-LLM project detection | Module `detect:` rules (`"<file> contains <text>"` / `"<file> exists"`) |

This pass therefore **reuses all of the above unchanged** and builds only
the pieces that were genuinely missing.

## What's new, and its cost

Every addition below states its token cost, when it loads, and where it's
stored, per the "memory budget first" principle: nothing here was added to
`core/CLAUDE.core.md` or `hooks/session-start.sh`. Measured always-loaded
cost is unchanged: `ctk budget` reports 397 tokens for the core (was 394;
+3 for the `goal` line in `--help` text pulled into no always-loaded
surface — the core file itself was not touched), 0 for state when absent,
same as before this pass.

| Addition | Cost when unused | Cost when used | Storage | Loaded by |
|---|---|---|---|---|
| Manifest `schema` field | 0 (one more line in an already-on-demand file) | negligible | `.claude/ctk/installed.txt` | `ctk doctor`/`uninstall`/`status` only |
| `ctk goal` | 0 | the command output, once | `.claude/ctk/GOAL.md`, capped ~300 tokens | only `ctk goal show` or `/ctk:goal`; **not** `hooks/session-start.sh`, **not** `ctk budget` |
| `ctk refine` | 0 | the command file, once | no new storage; edits go through git, history through existing `ctk state add` | `/ctk:refine` only |
| `task-context-loader` skill | 0 | `SKILL.md`, once | `.claude/skills/task-context-loader/` | invoked on demand like any skill |
| `flutter-recon`, `flutter-ui-checklist` skills | 0 | `SKILL.md`, once | `modules/flutter-android/skills/*`, staged to `.claude/skills/flutter-android/*` only when the module is selected | invoked on demand |

## Manifest schema

`.claude/ctk/installed.txt` is a flat, tab-separated, POSIX-`awk`-parseable
file (no JSON/YAML dependency, consistent with the "no runtime dependencies"
constraint in `CONTRIBUTING.md`). It now starts:

```text
# ctk installed assets
schema	1
version	3.1.0
profile	standard
<staged-relative-path>	<sha256-hex>
...
```

There is no separate migration function. `write_installed_manifest` (bash)
/ `Write-InstalledManifest` (PowerShell) already unconditionally rewrote
`version`/`profile` on every successful `install`/`update`; `schema` now
rides along the same path. A manifest with no `schema` line is legacy
(implicit schema 0): `ctk doctor` reports it with a non-fatal `WARN`
naming the fix (`ctk update`), and the very next `update` rewrites the file
with `schema 1`, which is what "idempotent, independently identifiable
migration" means at this scale — there has only ever been one migration to
perform. `mode` and core `hash` were deliberately **not** duplicated into
the manifest: they already have one authoritative source, the
`<!-- ctk:begin -->` header in the target's own `CLAUDE.md`, and duplicating
them would add a second source of truth to keep in sync for no
correctness benefit `doctor`'s existing hash-drift check doesn't already
provide.

**Bug found and fixed while touching this code**: `prepare_stage_records` in
`bin/ctk` (bash) had no exclusion filter for header keys at all — every
`install`/`update` after the first one copied the *previous* `version` and
`profile` lines into the new manifest unchanged, so a second run would have
produced duplicate `version`/`profile` lines (the `count` fields used by
`doctor`/`uninstall`/`status` filter these out by key name, so the bug was
silent — it inflated the file without changing observable behavior).
`bin/ctk.ps1`'s `Prepare-StageRecords` already excluded them correctly; the
two implementations had diverged. Fixed by excluding
`version`/`profile`/`schema` in both, and covered by
`test_legacy_manifest_migrates_on_update`, which asserts exactly one of each
key survives an `update`.

## Goal schema

`.claude/ctk/GOAL.md`, plain `key: value` lines, one active goal:

```text
objective: <text>
acceptance: <text>
phase: <text>
next_action: <text>
status: active|paused|completed|cancelled
evidence: <text>            # present only after `complete`
updated: <UTC timestamp>
```

`set` requires `--objective` and `--acceptance`; `complete` requires
`--evidence` and refuses without it — a goal is never marked complete
because a step or token budget ran out, only because named evidence was
recorded. `set` always replaces the record (no partial merge); `pause` and
`cancel` carry the existing objective/acceptance/phase/next forward and only
change `status`. The whole file is size-checked against a ~300-token cap
*before* writing; an oversized goal is rejected with the byte/token counts
in the error, not silently truncated. It is a data record only — nothing in
this toolkit reads `GOAL.md` and continues work unattended.

## Module `skills/` contract

`modules/<name>/skills/` is now a recognized, optional module subdirectory,
staged to `.claude/skills/<name>/` alongside `commands/` and `scripts/`
whenever the module itself is selected (auto-detected under `--profile
full`, or forced via `--module <name>` regardless of profile — same rule
that already governed `commands/`/`scripts/`). Because staging flows through
the existing `stage_one_file`/`installed.txt` machinery, `doctor` and
`uninstall` needed **no** additional code: they already operate generically
over whatever paths are recorded in the manifest.

**Docs fixed alongside this**: `modules/README.md` documented the required
`module.md` field as `detection` when the parser and the only real module
both use `detect`, and described module commands as staging to
`.claude/commands/ctk/<command>.md` when the installer has always staged
them to `.claude/commands/<module-name>/<command>.md` (invoked as
`/<module-name>:<command>`, not `/ctk:<command>`). `flutter-android/module.md`'s
"Adds" list repeated the same wrong `/ctk:*` naming. All three corrected.

## Deliberately deferred, with reason

- **Module-scoped agents / a Flutter-specific "specialist" agent.** The
  existing `investigator`/`verifier` agents already satisfy the bounded,
  non-recursive specialist pattern in general. A Flutter-specific instance
  would need a second module-staging generalization (agents, not just
  skills) and no acceptance criterion in this pass required it. Revisit only
  if a real Flutter diagnosis task proves the generic agents insufficient.
- **Repository presentation, SEO, GitHub metadata, README redesign,
  community-health audit.** Explicit follow-up workstream per direction for
  this pass; only the command-list lines in `README.md` needed for the two
  new commands were touched here.
- **Funding.** No verified destination exists. `docs/FUNDING_SETUP.md`
  documents the owner steps; no `.github/FUNDING.yml` and no link were
  added, and none should be until a real, verified destination is provided.

## Verification performed

- `sh tests/run.sh`: 24 tests (19 pre-existing + 5 new). All pass except
  four pre-existing, environment-specific failures on this Windows/Git-Bash
  checkout (`test_user_content_preserved`, `test_update_only_block_body`,
  `test_uninstall_restores_original`, `test_uninstall_removes_unmodified_staged_assets`),
  traced to `core.autocrlf=true` converting the checked-in LF test fixture
  to CRLF on checkout, combined with this environment's `awk` normalizing
  CRLF to LF on read — confirmed unrelated to this pass by diffing against
  `git show HEAD:bin/ctk`'s untouched `install_cmd` byte-copy path, and by
  reproducing the same byte diff with a minimal `cat`/`awk` probe outside
  `ctk` entirely. CI's Linux/macOS jobs (where this suite has always run)
  are not affected. Not fixed in this pass: it is a checkout/toolchain
  interaction, not a toolkit defect, and touching `.gitattributes` or CRLF
  policy is a separate decision outside this pass's scope.
- `bin/ctk.ps1` executed directly on Windows (closing the gap `HANDOFF.md`
  flagged as never having been run): `budget`, the full `goal` lifecycle,
  and `install --profile full` / `update` / `doctor` against disposable
  fixture directories, including a manifest-duplicate-line regression check.
- `sh -n bin/ctk` and PowerShell AST parse of `bin/ctk.ps1`: both clean.

## Follow-up: zero-manual project sync

Immediately after the pass above shipped, the actual UX gap it left was
named directly: updating the CTK checkout does not update any project, because
every `.claude/commands`, `.claude/skills`, `.claude/agents`, `hooks/`, and
`.claude/settings.json` file a project has is a byte copy made by `ctk
install`/`ctk update` — a manual command — never a live reference (`core/
CLAUDE.core.md` is the sole exception, via link mode's `@`-import). A
project-local `hooks/session-start.sh` cannot fix this either, because it does
not exist in a project until after that project's first manual install.

The fix is a **global** `SessionStart` router, registered once per machine by
`ctk bootstrap` into the user-level (not project-level) Claude Code settings,
which on every session start defers to the already-tested `ctk update
--session-sync` for an existing project, or prints a one-line approval signal
for a first-time one — never a second, parallel install implementation. Full
architecture, safety boundary, and recovery paths are in
`docs/zero-manual-sync.md`; this section records only what a plain reading of
3.1.0's own code did not already make obvious.

**Two defects found while building the conflict-detection path, fixed here
because they are the same safety property this pass exists to add** (never
silently destroy user data during a write CTK itself triggers), not scope
creep:

1. `stage_state_file` compared an existing `STATE.md` against a hardcoded
   pristine-boilerplate hash and overwrote it on mismatch — meaning any
   history `ctk state add` (and therefore `/ctk:checkpoint`) had written was
   silently erased by the very next `install` or `update`. Reproduced before
   touching any code: `ctk state add "x"; ctk update` left `STATE.md`
   containing only the boilerplate line. Fixed by treating "the file already
   exists" as sufficient — install/update never touch it again after first
   creation, only re-record its current hash.
2. The same hardcoded-hash comparison inside `doctor_installed_assets` meant
   `ctk doctor` reported a false `FAIL: staged asset was locally modified:
   .claude/ctk/STATE.md` after completely ordinary `ctk state add` use.
   Reproduced the same way. Fixed by excluding the one well-known
   `.claude/ctk/STATE.md` path from that hash comparison, and from the new
   `update --session-sync` conflict pre-flight for the same reason: it is
   data the tooling owns and mutates by design, not a template asset a user
   is expected to leave untouched.

**Why a new top-level `router/` directory instead of adding to `hooks/`:**
`core/profiles/standard.txt` and `full.txt` stage the entire `hooks/`
directory into every project. A router script placed there would have been
copied into every consumer project's `hooks/`, uninvoked and pointless there
— the router only ever runs from the authoritative checkout, addressed by the
absolute path `ctk bootstrap` recorded. `router/` is deliberately outside
every profile manifest.

**Why the settings.json merge differs by platform:** PowerShell 5.1+ ships
`ConvertFrom-Json`/`ConvertTo-Json`, a real parser guaranteed present on every
supported Windows target, so `bin/ctk.ps1` always merges safely. POSIX `sh`
has no such guarantee — `jq` is common but optional, consistent with this
toolkit's no-required-runtime-dependency stance — so `bin/ctk`'s merge uses
`jq` when present and otherwise only ever performs an operation it can prove
is safe without one: writing a fresh file when none exists, treating an
already-correct entry as a no-op, or (for `disable`) removing a file outright
only when a hash recorded at the moment `bootstrap` wrote it *entirely* still
matches. Any other existing content, without `jq`, fails closed with the
exact JSON to add or the exact marker to remove printed for the user to apply
by hand — never a `sed`/`awk` text splice against JSON.

**Verification performed:** `sh tests/run.sh` (19 new tests covering
bootstrap idempotency, disable's preservation of unrelated hooks, and every
`update --session-sync` exit code and its file-preservation guarantee);
`bin/ctk.ps1` and `router/session-sync-router.ps1` executed directly on
Windows through the equivalent matrix, including the real `ConvertTo-Json`
single-element-array collapse this pass found and worked around (`@()`
re-wrapping every filtered array before serializing); PowerShell AST parse and
`sh -n` on both new scripts.
