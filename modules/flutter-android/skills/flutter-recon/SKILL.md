---
name: flutter-recon
description: "Reconnaissance and scoped change planning for a Flutter/Android project before editing it."
---

# Flutter reconnaissance

Before changing a Flutter project, inspect only what a scoped plan needs:
`pubspec.yaml` for the Flutter/Dart SDK constraints and dependencies already
in use, `lib/` for the existing state-management pattern and folder
convention (do not introduce a second pattern alongside one already in use),
`test/` for what is already covered, and any project-local `CLAUDE.md` or
`README.md` for stated conventions. Prefer `/flutter-android:doctor` over
manually checking the Flutter/Gradle toolchain.

Turn that into a scoped plan naming the exact files to touch and the exact
existing widgets, providers, or services to reuse, before writing any code.
A plan that requires a new abstraction to reuse existing widgets is a signal
to re-check whether reuse was actually possible.

Verify with `/flutter-android:analyze` and `/flutter-android:test`, not a
manual `flutter` invocation, so failures are reported the same way this
toolkit already reports them.
