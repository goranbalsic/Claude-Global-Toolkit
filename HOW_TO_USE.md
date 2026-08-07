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

## 6. Check for drift, update, recover, or remove

Added by UPDATE-02 (`PROMPTS.md` PROMPT-003) to complete the adoption
lifecycle that install-only left unfinished.

**Drift check** — is the target's `CLAUDE.md` still current?

```powershell
# PowerShell
fc.exe "C:\path\to\other\repo\CLAUDE.md" GLOBAL_CLAUDE.md
```

```bash
# POSIX
diff /path/to/other/repo/CLAUDE.md GLOBAL_CLAUDE.md
```

No output / exit 0 means no drift. Any output means the target has either
been customized (a repository-specific addition appended below the
universal section, as documented in that repository's own `CLAUDE.md` —
see `checklists/adoption-validation.md`'s preflight step for how to tell
the two apart) or is behind this toolkit's current version. Either script
also states the *source* file's frontmatter `version:` in its own output
header as a quick anchor — compare it against the target's own frontmatter
`version:` line (if the target kept one) to tell "behind" from
"intentionally diverged."

**Update path** — the existing install scripts' backup-then-overwrite
branch *is* the update mechanism; there is no separate update script. Run
the same command as section 1 again: if the target's `CLAUDE.md` differs
from the current `GLOBAL_CLAUDE.md`, the script backs it up
(`CLAUDE.md.bak.<timestamp>`) and shows a diff before overwriting, exactly
as it does for a first install onto a pre-existing file. If the target has
a repository-specific addition appended below the universal section (per
section 3's guidance), re-apply that addition after updating — the backup
file has the previous combined content if you need to diff it back in.

**Recovery path** — restore from the timestamped backup the install
script already made:

```powershell
Copy-Item "C:\path\to\other\repo\CLAUDE.md.bak.<timestamp>" "C:\path\to\other\repo\CLAUDE.md" -Force
```

```bash
cp /path/to/other/repo/CLAUDE.md.bak.<timestamp> /path/to/other/repo/CLAUDE.md
```

If no `.bak.*` file exists, the target never had a prior `CLAUDE.md` at
install time (a first-install create, not an overwrite) — there is nothing
to restore to; delete the file manually if removing.

**Removal** — manual only, never automated (this toolkit has no
uninstall script and will not gain one — removal is a repository owner's
call, not something to script unattended). Delete the target's
`CLAUDE.md` (and, if adopted, section 2's structure files or section 3's
memory-bundle files) directly; nothing else in the target repository is
touched by having adopted this toolkit, so nothing else needs cleanup.

## 7. Load the toolkit automatically in every session (optional, global)

Added by SRC-004 (`sources/update2addition.txt`, `PROMPTS.md` PROMPT-004,
`DECISIONS.md` D-013). Instead of installing `GLOBAL_CLAUDE.md` into each
repository individually (sections 1–2), you can make it load automatically
in *every* Claude Code session, in every project, via Claude Code's
user-level global instructions file.

**Install:** create `%USERPROFILE%\.claude\CLAUDE.md` (back it up first —
`Copy-Item` / `cp` to a timestamped `.bak.<date>` — if one already exists;
this step is manual, there is no script for this layer) containing:

```
# Global Claude Code instructions

@C:/Claude-Global-Toolkit/GLOBAL_CLAUDE.md

A project's own CLAUDE.md, if present, loads alongside this file and its
instructions take precedence over anything above wherever the two conflict.
```

Adjust the `@` path if this toolkit lives somewhere other than
`C:\Claude-Global-Toolkit` on your machine. Only `GLOBAL_CLAUDE.md` is
imported — not this repository's own `PROJECT_STATUS.md`/`DECISIONS.md`/
etc. — to keep global context footprint small and avoid leaking this
toolkit's own project history into unrelated repositories.

**Verify:** run `claude -p "list every CLAUDE.md file loaded into your
context this session, with full paths"` from any directory (a disposable
empty one is the cleanest test). You should see your new global file and,
imported from it, `GLOBAL_CLAUDE.md`. In a directory that also has its own
`CLAUDE.md`, all three should be listed, and a project-specific rule
should win over anything conflicting in the global layer. `/memory` or
`/context` inside an interactive session show the same information.

**Update:** nothing to do — the `@import` is live. Editing
`GLOBAL_CLAUDE.md` here (following `HOW_TO_BUILD.md`'s "Changing
GLOBAL_CLAUDE.md" procedure) takes effect in every session immediately,
with no per-repository reinstall.

**Recover:** restore your own backup of the previous
`%USERPROFILE%\.claude\CLAUDE.md`, taken before you created/edited this
one — same manual process as any file backup, since this layer isn't
managed by `scripts/install.*`.

**Remove:** delete `%USERPROFILE%\.claude\CLAUDE.md`, or delete just the
`@import` line if you want to keep other global instructions you've added
around it. Nothing else on the system is affected — this layer never
installs packages, alters other global config, or touches any project's
own files.

## 8. Run the repository health check periodically

See `chapters/05-repository-health-check.md`. Run it before resuming after a
gap and periodically on long-running projects. It is diagnostic — it does
not authorize corrective changes on its own; those still need approval per
the target repository's own approval matrix.
