# Uninstall and revert

Reversal is a designed feature, not an afterthought. There are four independent
levels, and none of them requires trusting that the toolkit did the right thing:
each one can be previewed first.

## 1. Remove the toolkit from one project

```sh
cd /path/to/your/project

ctk uninstall --dry-run    # list exactly what would be removed, write nothing
ctk uninstall
```

What it removes:

- the managed block, delimited by `<!-- ctk:begin ... -->` and `<!-- ctk:end -->`
- the files it staged, as recorded in `.claude/ctk/installed.txt`
- the host file itself, but only if removing the block leaves it empty

What it never removes:

- anything outside the managed block, which is preserved byte for byte
- a staged file you have since modified locally. Modification is detected by
  comparing the recorded hash. Modified files are reported as kept, not silently
  deleted.
- your `.ctk-backup/` directory, so you can still restore afterwards
- anything the toolkit did not create

Because the block is delimited, you can always do this by hand instead: open the
file, delete the lines from `ctk:begin` to `ctk:end` inclusive, and you are done.
Nothing is hidden, and nothing depends on the CLI still working.

## 2. Restore a file the toolkit modified

Every mutating command takes a timestamped backup into `.ctk-backup/` before
writing.

```sh
ctk restore              # newest backup of the managed file
ls -la .ctk-backup/      # every backup, timestamped in UTC
```

Backups are plain files. Copying one back with `cp` works just as well if you would
rather not use the CLI.

## 3. Remove a global installation

Global installation only happens if you explicitly asked for it with
`--global`, and it is the only case where the toolkit writes outside a target
directory.

```sh
ctk uninstall --global --dry-run
ctk uninstall --global
```

This edits `~/.claude/CLAUDE.md`, removing only the managed block. Any other global
instructions you wrote yourself are left alone.

## 4. Go back to version 2.2.0

The previous version of this toolkit is preserved as a git tag, permanently.

```sh
cd /path/to/Claude-Global-Toolkit
git checkout v2.2.0
```

That restores the entire v2 tree: `GLOBAL_CLAUDE.md`, the 8 handbook chapters, 12
prompts, 10 checklists, 13 templates, the original install scripts, and the full
build history.

To read or recover individual v2 files without moving your checkout:

```sh
git show v2.2.0:HOW_TO_USE.md
git ls-tree -r --name-only v2.2.0
git checkout v2.2.0 -- chapters/01-daily-operating-loop.md
```

To go forward again:

```sh
git checkout main
```

The two levels are independent. A project's v3 managed block can be removed with
`ctk uninstall` whether or not the toolkit itself is rolled back, and rolling the
toolkit back does not touch any project that adopted it.

## Verifying a clean removal

```sh
git status                                  # expect no unexpected changes
grep -rn 'ctk:begin' . 2>/dev/null          # expect no matches
ls .claude/ctk 2>/dev/null                  # expect absent, or only what you kept
```

If `grep` still finds a marker, an orphaned block exists somewhere the CLI did not
look, usually because the file was moved after installation. `ctk doctor` reports
orphaned markers, and deleting the marked lines by hand is safe.

## If you deleted the toolkit checkout first

Link-mode installs point at the toolkit's path on disk. Deleting the checkout leaves
a dangling `@`-import, which is harmless but useless: Claude Code simply finds
nothing to import.

To clean it up without the CLI, delete the block from `ctk:begin` to `ctk:end` in
the project's `CLAUDE.md`, then remove `.claude/ctk/`. Or re-clone the toolkit and
run `ctk uninstall` properly.

This is the main tradeoff of link mode. If you expect to move or delete the
checkout, use `ctk install --embed`, which inlines the core and leaves the project
self-contained.
