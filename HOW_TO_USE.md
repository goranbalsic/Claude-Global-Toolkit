# HOW_TO_USE.md

How to adopt this toolkit in another repository.

## 1. Install the universal baseline

From this toolkit's root:

```powershell
# PowerShell, targeting another repository
.\scripts\install.ps1 -TargetRepo "C:\path\to\other\repo"
```

```bash
# POSIX shell, targeting another repository
./scripts/install.sh --target-repo /path/to/other/repo
```

The script copies `GLOBAL_CLAUDE.md` into the target repository as
`CLAUDE.md`. It will:

- create the target repository's directory structure it needs without
  touching unrelated files,
- detect an existing `CLAUDE.md` and take a timestamped backup before
  changing it,
- show you a diff/proposal and ask for confirmation before writing,
- never install packages or alter anything outside the target repository,
- report exactly what changed.

See `chapters/04-reusable-project-structure.md` for what the script does and
does not do, and `checklists/startup.md` before your first session in the
newly-adopted repository.

## 2. Optionally adopt the full structure

If the target repository should also get the full reusable structure (not
just `CLAUDE.md`), create in the target repo's root:

```
README.md  PROJECT_CONSTITUTION.md  SOURCE_REGISTER.md  DECISIONS.md
CHANGELOG.md  ROADMAP.md  HOW_TO_USE.md  HOW_TO_BUILD.md  PROJECT_STATUS.md
sources/ chapters/ prompts/ templates/ checklists/ reviews/ scripts/
summaries/ exports/
```

Use the templates in `templates/` as starting points for that repository's
own `PROJECT_CONSTITUTION.md`, `DECISIONS.md`, etc. — do not copy this
toolkit's own `PROJECT_CONSTITUTION.md` verbatim, since it describes *this*
repository's purpose, not the target's.

## 3. Optional: memory and decision continuity

A second, independent opt-in on top of (or instead of) section 2's
structure: a small set of files for tracking project context, prompts,
ideas, and open questions across session restarts — originally built for
this toolkit's own repository (see `DECISIONS.md` D-005 through D-007) and
generalized here so any adopting repository can use it too.

Copy whichever of these the target repository needs from `templates/` into
its root, renaming as shown, and fill them in:

| Template | Copy to |
|---|---|
| `templates/project-context.md` | `PROJECT_CONTEXT.md` |
| `templates/project-rules.md` | `PROJECT_RULES.md` |
| `templates/prompt-library.md` | `PROMPTS.md` |
| `templates/ideas-backlog.md` | `IDEAS.md` |
| `templates/open-questions.md` | `OPEN_QUESTIONS.md` |
| `templates/session-log.md` | `session_logs/YYYY-MM-DD-session-NN.md` (per entry) |

Notes:

- `DECISIONS.md`, `CHANGELOG.md`, and `summaries/` are **not** duplicated by
  this bundle — if the target repository adopted section 2's full
  structure, those already exist and already serve this purpose. If it
  didn't, create them following `templates/decision.md` and the
  conventions in `chapters/03-phase0-investigation.md` instead of the files
  listed above.
- `PROMPTS.md` (project-specific prompt history) is deliberately distinct
  from `prompts/` (this toolkit's generic, reusable task prompts) — see
  `templates/prompt-library.md`'s own note. Don't confuse the two.
- `PROJECT_RULES.md` overlaps in places with `GLOBAL_CLAUDE.md`'s ten
  rules and `PROJECT_CONSTITUTION.md`'s authority hierarchy if either is
  also installed — `templates/project-rules.md` says which sections to
  trim in that case, so the repository doesn't end up with two versions of
  the same rule.
- `memory/` (a directory SRC-002 requires without ever defining its
  contents) is intentionally **not** templated — see this repository's own
  `memory/README.md` and `OPEN_QUESTIONS.md` QUESTION-001 for why. Create
  it empty, with a short README stating its purpose stays undefined until a
  concrete need arises, if you want to match this toolkit's own repository
  exactly.
- Update `CLAUDE.md`'s "Start or resume" section (or write one, if the
  target repository doesn't have a `CLAUDE.md` yet) to include whichever of
  these files were actually adopted, in read order — see this toolkit's own
  `CLAUDE.md` for a worked example, and `DECISIONS.md` D-006 for why a
  single canonical order matters more than which exact order is chosen.

## 4. Use the daily operating loop

Every session in an adopting repository should follow
`chapters/01-daily-operating-loop.md`: start/resume, investigate, clarify,
decide, plan, implement, verify, review and report.

## 5. Pull prompts, templates, and checklists on demand

These are reference material, not automatic behavior. Invoke the one you
need for the task at hand, e.g. `prompts/resume.md` at the start of a
session, `checklists/security.md` before shipping a security-relevant
change, `templates/decision.md` when logging a new entry in that
repository's `DECISIONS.md`.

## 6. Run the repository health check periodically

See `chapters/05-repository-health-check.md`. Run it before resuming after a
gap and periodically on long-running projects. It is diagnostic — it does
not authorize corrective changes on its own; those still need approval per
the target repository's own approval matrix.
