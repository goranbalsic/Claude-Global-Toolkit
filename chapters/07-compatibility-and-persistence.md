---
chapter: 07
title: Compatibility, persistence, completion report, and safe resume
source: SRC-001, p.9
confidence: Confirmed
---

# 07 — Compatibility, persistence, completion report, safe resume

## Compatibility (source text)

- Claude Code versions: Unknown — verify installed version.
- Operating systems: verify shell and path behavior.
- Breaking changes: none recorded.
- Deprecated behavior: none recorded.

## Compatibility (verified)

- **Claude Code CLI version confirmed installed:** `2.1.224`, verified
  2026-08-07 via `claude --version` in this repository's environment.
  Confidence: Confirmed (direct command output).
- **OS/shell confirmed:** Windows 11 Pro (win32). Both PowerShell and a POSIX
  shell (Git Bash) are available in this environment; `scripts/install.ps1`
  and `scripts/install.sh` were both exercised successfully here (see
  `DECISIONS.md` D-003, `summaries/BATCH-01-initial-toolkit-build.md`).
- **Breaking changes / deprecated behavior against this toolkit's
  assumptions:** none observed. The toolkit's mechanisms (plain Markdown
  files, the `CLAUDE.md`-at-session-start convention, standard shell
  scripting) do not depend on Claude Code internals beyond reading files at
  session start and running shell commands — both confirmed working under
  `2.1.224`.
- **Scope of this verification:** this confirms compatibility with the one
  installed version checked, on one OS, on one date. It does not predict
  future versions. Re-verify (`claude --version`) after any Claude Code
  upgrade before treating this section as current — per
  `chapters/02-evidence-and-uncertainty.md`'s version-awareness rule.

## Persistence

The toolkit cannot give Claude permanent memory of every repository.
Persistent knowledge comes from repository source-of-truth files:
`CLAUDE.md`, `PROJECT_CONSTITUTION.md`, `DECISIONS.md`, `PROJECT_STATUS.md`,
source registers, summaries, and verified artifacts. Each session must read
the relevant current records.

## Completion report (source text)

- Files created and changed.
- Commands actually run.
- Verification results, including skipped or unavailable checks.
- Sources inspected and evidence gaps.
- Toolkit installation status and backups.
- Exports or build instructions.
- Unresolved risks and approval decisions.
- Exact resume instruction.

## Safe resume instruction (source text)

Read `CLAUDE.md`, `PROJECT_CONSTITUTION.md`, `PROJECT_STATUS.md`,
`DECISIONS.md`, `ROADMAP.md`, and the latest batch summary; inspect Git
status; run the repository health check; verify the first incomplete
deliverable; then continue without recreating verified work.

## Rationale

Since the model has no memory across sessions or repositories, every
persistence guarantee this toolkit offers has to be implemented as *files the
next session will actually read* — this is why the daily operating loop
(`chapters/01-daily-operating-loop.md`) opens with reading exactly this set
of files. The completion report exists so a human (or the next session) can
audit what happened without re-running everything.

## When to apply

Compatibility: whenever a claim depends on a specific Claude Code version or
OS/shell behavior — check `Unknown` status remains accurate or update it once
verified (see `ROADMAP.md`). Completion report and safe resume: end and start
of every non-trivial session, respectively.

## When not to apply literally

A single-turn trivial answer doesn't need a full completion report — but any
session that changed files does.

## Risks if ignored

Resuming without reading `PROJECT_STATUS.md`/`DECISIONS.md` risks redoing
completed work or contradicting a recorded decision — the exact failure mode
"persistence" in this chapter exists to prevent. An incomplete completion
report hides unresolved risk from the user.

## Evidence and confidence

Confirmed — quoted from SRC-001 (p.9). The compatibility fields
("Unknown"/"verify"/"none recorded") are explicitly unverified placeholders
in the source itself, not toolkit-side gaps — see `ROADMAP.md` for the open
item to verify them.

## Verification

Use `prompts/resume.md` at session start and `templates/handoff.md` at
session end to structure the completion report.
