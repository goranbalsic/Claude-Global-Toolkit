---
title: New session
use_when: Starting work in a repository for the first time (no PROJECT_STATUS.md or governance files exist yet)
related: chapters/00-mission-and-authority.md, chapters/03-phase0-investigation.md
---

# Prompt: New session

```
Before any implementation, run Phase 0 investigation on this repository:

1. Inspect the directory tree, README, any existing CLAUDE.md, and package/
   build manifests.
2. Inspect Git status, current branch, and recent log if this is a Git
   repository.
3. Identify OS, shell, language runtime(s), package manager(s), and already-
   available tooling — do not install anything.
4. Note whether PROJECT_CONSTITUTION.md, DECISIONS.md, PROJECT_STATUS.md,
   ROADMAP.md, or a SOURCE_REGISTER.md already exist. If not, flag that as a
   gap rather than assuming none is needed.
5. Detect test, lint, type-check, link-check, and build commands actually
   available in this repository — do not assume a generic command works
   without checking.
6. Report what you found, distinguish confirmed facts from assumptions, and
   propose (don't silently create) any governance scaffolding you think this
   repository needs before you start the requested work.

Then state the objective as you understand it, constraints, acceptance
criteria, and any blocking questions before proceeding.
```
