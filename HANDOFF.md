# Checkpoint and handoff: v3.0.0 shipped

Date: 2026-08-08
Repo: https://github.com/goranbalsic/Claude-Global-Toolkit
Released: `v3.0.0` on `main`. CI green on Linux, macOS, Windows.
Revert point: `v2.2.0` tag, complete v2 tree, pushed before any v3 change landed.

## What was wrong with v2.2.0 (measured, not guessed)

1. **~45,000 tokens of preamble per session.** The read order v2 installed into
   `salary-currency-pro` required reading `DECISIONS.md` (104 KB),
   `PROJECT_CONTEXT.md` (28 KB), `PROMPTS.md` (25 KB), `OPEN_QUESTIONS.md`
   (17 KB) before any work. All four grew every session. Nothing capped or
   measured them. This was the slowness and cost.
2. **No executable capability.** 87 files, ~338 KB of prose. Claude Code extends
   through `.claude/commands/`, `.claude/agents/`, `.claude/skills/` and hooks.
   v2 described these in `chapters/` and implemented none. It gave the agent
   advice where it could have given the agent tools. This was the placebo part.
3. **Destructive install.** `scripts/install.sh` copied `GLOBAL_CLAUDE.md` over
   the target's entire `CLAUDE.md`. Project-specific rules were replaced, and
   updating the baseline meant hand-merging local edits back in.
4. **No uninstall**, by explicit policy.
5. **No OSS hygiene.** No license, description, topics, CI, contribution guide,
   security policy, issue templates.
6. **530 KB of committed artifacts and inputs** in `exports/` and `sources/`.
7. **Own build diary shipped as the product.** Every adopter cloned
   `session_logs/`, `summaries/`, `reviews/`, `PROJECT_STATUS.md`, `ROADMAP.md`,
   `IDEAS.md`, `OPEN_QUESTIONS.md` and had to work out what was product.
8. **Nothing for the stack actually being shipped** (Flutter Android APKs).

## What v3.0.0 is

Organising rule: **cost scales with use, not with size.**

| | v2.2.0 | v3.0.0 |
|---|---|---|
| Always-loaded | ~45,000 tokens, unbounded | **394 tokens, capped at 1,200, CI-enforced** |
| Capability | none | 7 commands, 4 subagents, 3 skills, 3 hooks |
| Install | overwrites `CLAUDE.md` | appends a delimited block, preserves your content byte for byte |
| Uninstall | none | `ctk uninstall`, keeps locally modified files |
| History | read in full every session | capped working set, archive never auto-read |
| Tests | manual | 19 automated, CI on 3 platforms |
| Files | 87 (product + diary) | 64, all product |

Three layers: L1 core (always, 1,200-token cap), L2 on-demand (commands,
subagents, skills, modules; zero cost until invoked), L3 bounded state
(`.claude/ctk/STATE.md`, 400-token cap, auto-rotates to an archive that is never
read automatically). `ctk budget` measures L1+L3 and CI fails on a breach, so the
v2 regression cannot recur silently.

Injection is a managed block:

```
<!-- ctk:begin v=3.0.0 profile=standard hash=<sha256-12> -->
@/path/to/Claude-Global-Toolkit/core/CLAUDE.core.md
<!-- ctk:end -->
```

`install` appends, `update` rewrites only the body, `uninstall` removes only the
block. `--link` (default) costs ~15 tokens per project and shares one core;
`--embed` inlines it for a self-contained repo. `--global` is optional and never
the default. Backups go to `.ctk-backup/`; `ctk restore` reverses.

## Verification actually run

- `sh tests/run.sh`: **19 passed, 0 failed**. Covers install idempotence,
  byte-for-byte user-content preservation, block-scoped update, uninstall
  restoring the original, uninstall keeping a locally modified staged file,
  restore, dry-run writing nothing, profile staging differences, module detection
  positive and negative, manifest accuracy, budget rejection of a padded core,
  drift detection.
- `shellcheck -s sh` on `bin/ctk`, `tests/run.sh`, `hooks/*.sh`,
  `modules/*/scripts/*.sh`: **clean**.
- `bin/ctk budget`: **PASS**, 394/1200 core, 0/400 state.
- `settings.json` valid JSON; all command/agent/skill/module frontmatter valid YAML.
- Hook payload tests: `.keystore` write payload **blocked, exit 2**; `.dart` edit
  payload **allowed, exit 0**.
- Flutter module: every script `--help` exits 0; run from a non-Flutter dir each
  exits nonzero with `not a Flutter project root: pubspec.yaml is missing`; with
  Flutter absent each reports `Unavailable: flutter command was not found` rather
  than crashing; `version.sh --bump patch --dry-run` reported `1.0.0+1 -> 1.0.1+2`
  without writing.
- End-to-end smoke test on a fake Flutter project: `install --profile full`
  staged 35 files, original `CLAUDE.md` content preserved byte for byte,
  `uninstall` returned the tree to its original state.
- **GitHub Actions CI: success on first run**, Linux + macOS + Windows.

## Known gaps, stated honestly

1. **`bin/ctk.ps1` has never been executed.** PowerShell is not available in the
   build environment. Its logic mirrors `bin/ctk` and CI parse-checks it and runs
   `ctk.ps1 budget` on `windows-latest`, but the staging, uninstall and restore
   paths are unproven on Windows. **This is the highest-priority next task**, and
   it matters because the primary machine is Windows.
2. **Flutter build commands were never run against a real SDK.** Flutter is not
   installed in CI. Argument handling, failure paths and secret hygiene are
   verified; actual `flutter build apk` behaviour is not.
3. **Token counts are estimated at 4 bytes/token**, deliberately. Good enough to
   catch order-of-magnitude regressions without a tokenizer dependency.
4. **Link mode breaks if the toolkit checkout moves.** `ctk doctor` reports it.
   `--embed` avoids it.
5. **v2's 8 chapters were distilled, not migrated line by line.** Some prose is
   only in the `v2.2.0` tag now. Intentional, but worth a read-through if
   something feels missing.
6. **Not yet dogfooded on `salary-currency-pro`.** See next actions.

## Next actions, in order

1. **Run `bin\ctk.ps1` on Windows.** From the toolkit checkout:
   `.\bin\ctk.ps1 budget`, then in a disposable copy of a project:
   `.\bin\ctk.ps1 install --profile full --dry-run`, then without `--dry-run`,
   then `status`, `doctor`, `uninstall`. Fix what breaks. Gap 1.
2. **Adopt v3 in `salary-currency-pro`** following `docs/migrating-from-v2.md`:
   `ctk install --profile full` (the Flutter module auto-detects), then **delete
   the v2 session-start read order from its `CLAUDE.md`**. That block is the
   45,000-token cost. Replace it with `/ctk:resume`. This is the change that
   actually makes sessions fast.
3. **Verify the Flutter module against the real SDK**: `/flutter-android:doctor`,
   `:analyze`, `:test`, `:preflight`, `:apk --release --split-per-abi`. Gap 2.
4. Optionally add a `README` screenshot or a short asciinema of
   `ctk install --dry-run` and `ctk budget`, which is what makes a repo like this
   get starred.
5. Optionally cut a GitHub Release from the `v3.0.0` tag using the `CHANGELOG.md`
   3.0.0 section as the body.

## Reverting

```sh
ctk uninstall              # remove from one project; --dry-run first
ctk restore                # undo a modification from .ctk-backup/
git checkout v2.2.0        # the entire v2 toolkit back
git show v2.2.0:HOW_TO_USE.md          # read a v2 file without switching
git checkout v2.2.0 -- chapters/       # recover part of v2
```

The two levels are independent: a project's v3 block can be removed whether or
not the toolkit itself is rolled back.

## Repo state

Public, MIT, default branch `main`, 64 files, issues on, wiki off. Description
and 20 topics set for discoverability (`claude-code`, `agent-skills`,
`slash-commands`, `subagents`, `hooks`, `claude-md`, `context-engineering`,
`token-optimization`, `flutter`, `android`, `apk`, and others). Tags: `v2.2.0`,
`v3.0.0`.
