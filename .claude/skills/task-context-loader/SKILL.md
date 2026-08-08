---
name: task-context-loader
description: "Route a stated task to the smallest existing command, skill, agent, or module asset instead of reading broadly."
---

# Task context loader

Before reading files to understand a task, name its category and load only
what that category maps to. Categories are deterministic, not inferred from
vibes: Flutter/Dart feature or UI work, Flutter analysis or test-failure
diagnosis, Android/Gradle/manifest troubleshooting, release or build
validation, and documentation/handoff.

| Task category | Load | Do not load |
|---|---|---|
| Flutter UI/feature work | `modules/flutter-android/skills/flutter-recon/SKILL.md`, then `flutter-ui-checklist/SKILL.md` | the `analyze`/`test`/`release` scripts until verification is actually due |
| Flutter analyze/test diagnosis | `/flutter-android:analyze` or `/flutter-android:test`, then the `investigator` or `verifier` subagent for a compact digest | raw `flutter analyze`/`flutter test` output past what the digest needs |
| Android/Gradle/manifest troubleshooting | `/flutter-android:doctor`, then `/flutter-android:preflight` if signing is in scope | Gradle files outside the reported failure |
| Release/build validation | `/flutter-android:preflight`, `/flutter-android:release`, `/flutter-android:version` | shortcuts around the keystore/`.env` gate those scripts already enforce |
| Documentation/handoff | `.claude/ctk/STATE.md` via `/ctk:resume`; `ctk goal show` if a goal is active | `DECISIONS.md` or session logs unless the task names a specific record |

State what was loaded and why in one line before acting. If a task does not
match a category above, load only the skill or command whose own description
names it, not adjacent material "in case it helps."
