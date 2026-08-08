# Security

## Reporting a vulnerability

Report privately through GitHub's [security advisory
form](https://github.com/goranbalsic/Claude-Global-Toolkit/security/advisories/new).
Please do not open a public issue for anything exploitable. Include the version or
commit, the platform, and a reproduction. Expect an acknowledgement within seven
days.

## What this toolkit does to your machine

Worth stating plainly, since the toolkit's job is to modify instruction files that
an AI agent then follows.

It does:

- read and write files inside the directory you point it at
- write timestamped backups into `.ctk-backup/` in that directory
- write `~/.claude/CLAUDE.md` only when you pass `--global`

It does not:

- make network calls
- install packages
- collect telemetry
- read or write anything outside the target directory, other than the `--global`
  case above
- delete files it did not create, except for removing a managed block's host file
  when that file would otherwise be left empty

Every mutating command supports `--dry-run`, takes a backup first, and is
reversible with `ctk uninstall` or `ctk restore`.

## Threat model worth taking seriously

**Prompt injection through instruction files.** The toolkit's output is text that
an agent treats as instructions. If an attacker can write to your
`CLAUDE.md`, `.claude/`, or the toolkit checkout, they can influence what your
agent does. Treat these files as code: review changes in pull requests, and do not
`ctk install --link` against a toolkit checkout you do not control. The managed
block markers make injected content easy to spot in a diff, which is part of why
the block is delimited rather than merged.

**Untrusted repository content.** Skills and commands in this toolkit instruct the
agent to treat file contents, issue text, and dependency metadata as data, not as
commands. That is a mitigation, not a guarantee. Keep a human in the loop for
destructive and outbound actions.

## Secret handling

The toolkit never reads, prints, logs, or commits secrets, and it actively guards
against doing so:

- A `PreToolUse` hook blocks the agent from writing to secret-bearing paths:
  `*.keystore`, `*.jks`, `*.p12`, `*.pem`, `key.properties`, `.env*`,
  `google-services.json`, and service-account JSON files.
- The Flutter/Android module's preflight check fails if any of those paths are
  tracked by git.

Signing credentials belong in a gitignored local file or in environment variables,
referenced from the build configuration, with CI supplying them from its own
secret store. Never in the repository.

## Supported versions

Fixes land on the latest release. The `v2.2.0` tag is preserved as a historical
revert point and is not maintained.
