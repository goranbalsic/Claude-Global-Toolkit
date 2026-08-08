---
description: Run Flutter Android release gates without exposing signing secrets.
allowed-tools:
  - Bash
argument-hint: "[--base REF] [--jobs N] [--dry-run]"
---

Run from the Flutter project root:

```sh
sh .claude/ctk/modules/flutter-android/scripts/preflight.sh $ARGUMENTS
```
