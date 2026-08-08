---
description: "Run a pre-release gate without committing, tagging, publishing, or hiding failures."
allowed-tools: Bash, Read, Grep, Glob, Task
argument-hint: "[release version or target]"
---

Run the pre-release gate for: `$ARGUMENTS`. This command is a gate only; it
must not commit, tag, push, publish, deploy, or alter release credentials.

!`printf 'branch: '; git branch --show-current 2>/dev/null || true`
!`git status --short 2>/dev/null | sed -n '1,100p'`
!`git diff --cached --name-only 2>/dev/null | sed -n '1,100p'`

1. Run `/ctk:verify` now. If nested command invocation is unavailable,
   execute its same detection-and-run workflow directly and retain its
   Passed/Failed/Skipped/Unavailable table.
2. Identify the canonical version source from repository manifests
   (`pubspec.yaml`, `package.json`, `Cargo.toml`, `pyproject.toml`, or
   equivalent). Compare its version at `HEAD` with the last release tag when
   one exists. If no versioned artifact or tag exists, mark this check
   Skipped with evidence, not Passed.
3. Check that `CHANGELOG.md` exists and contains an entry for the candidate
   version. Report the line/reference; do not infer a version bump from a
   commit message.
4. Check staged paths for secret-bearing names
   (`.keystore`, `.jks`, `.p12`, `.pem`, `key.properties`, `.env*`,
   `google-services.json`, and `*serviceAccount*.json`) and scan the staged
   diff for credential markers without echoing matched values.
5. Require `git status --porcelain` to be empty for a clean-tree pass. A
   dirty tree, failed verification, missing version/changelog evidence, or a
   suspected staged secret is a failed gate.
6. Return a gate table for verify, version bump, changelog, staged secrets,
   and clean tree. State `READY` only when every required check passed;
   otherwise state `NOT READY` and give the exact blocking remediation.
