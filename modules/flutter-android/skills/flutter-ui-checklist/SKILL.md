---
name: flutter-ui-checklist
description: "Checklist for implementing a Flutter UI or feature change without regressing an existing screen."
---

# Flutter UI/feature checklist

Before marking a Flutter UI or feature change done, confirm each of these
against the actual project, not from memory: the change reuses the existing
theme/design tokens rather than hard-coded colors or sizes; widget state
follows the state-management pattern already in use elsewhere in `lib/`;
layout is responsive to at least the device sizes the project already
targets; interactive elements have semantics/labels for accessibility; any
user-facing string follows the project's existing localization approach if
one exists; and a test was added or updated under `test/` for the new
behavior, not only a manual description of it.

Run `/flutter-android:analyze` and `/flutter-android:test` before reporting
the change complete, and report their actual result rather than an assumed
one. If any item above does not apply to this project, say so explicitly
instead of silently skipping it.
