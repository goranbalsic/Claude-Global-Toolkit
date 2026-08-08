# Modules

A module is an opt-in extension for a specific stack. It adds executable
commands and supporting files without increasing the core toolkit's
always-loaded context. Modules are never a dependency of `core/`: a project
that does not install a module must retain the complete core command surface.

## Contract

Each module lives at `modules/<module-name>/` and contains:

```text
module.md       machine-readable declaration and scope
README.md       operator documentation
commands/       Claude Code slash-command definitions
scripts/        executable, dependency-light helpers called by commands
```

`module.md` starts with YAML frontmatter. Required fields are `name`,
`version`, `profiles`, `detection`, and `token-cost`. The body must state what
the module adds and what it deliberately does not do. `token-cost` must make
clear that the module is not loaded until one of its commands is invoked.

Commands must have YAML frontmatter with at least `description` and
`allowed-tools`. A command is a thin dispatcher: it calls a script, reports
that script's result, and does not duplicate a long operational playbook in
Markdown. Scripts must be safe to run from the detected project root, provide
`--help` and `--dry-run`, validate prerequisites, and never expose secrets.

## Installation

`ctk install --profile full` picks up a module by scanning declarations under
`modules/` and selecting those whose `profiles` includes `full`. The installer
then places a selected module's command files under the target
`.claude/commands/ctk/` directory and its complete module tree under
`.claude/ctk/modules/<module-name>/`. This gives commands a stable relative
path to their scripts:

```text
.claude/commands/ctk/<command>.md
.claude/ctk/modules/<module-name>/scripts/<script>.sh
```

Minimal and standard profiles do not acquire a module unless their manifest
explicitly selects it. This staging behavior is an installer responsibility;
the module itself must never copy files into a target project. Installing a
profile only copies module assets; it does not execute a build, alter a
project's Gradle files, or create credentials.

## Writing a module

1. Create `modules/<module-name>/` with the required layout.
2. Make detection conservative. A false negative is safer than offering a
   stack-specific command in the wrong repository.
3. Keep the declaration and README explicit about unsupported workflows.
4. Put operational logic in POSIX `sh` scripts. Quote paths, use `set -eu`,
   fail clearly when a required tool is unavailable, and keep `--dry-run`
   non-mutating.
5. Make command documents call those scripts by their installed path.
6. Test the scripts from both a matching project root and a non-matching
   directory. Run `sh -n` and `shellcheck -s sh` before proposing the module.

## Contributing

Contributions must preserve opt-in behavior. Do not add a module command to
the core, import a module from core instructions, or make a core command rely
on module files. Include a concise README, executable verification, a safe
secret-handling policy where applicable, and a profile declaration. Add the
module to a profile manifest only after its standalone checks are complete.
