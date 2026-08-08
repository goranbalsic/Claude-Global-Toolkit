---
description: "Detect the real toolchain and run its applicable verification commands."
allowed-tools: Bash, Read, Grep, Glob
argument-hint: "[changed area or task]"
---

Verify: `$ARGUMENTS`. Never install packages or substitute a generic command
for a repository-defined one.

!`find . -maxdepth 2 -type f \( -name pubspec.yaml -o -name package.json -o -name pnpm-lock.yaml -o -name package-lock.json -o -name yarn.lock -o -name pyproject.toml -o -name pytest.ini -o -name go.mod -o -name Cargo.toml -o -name Makefile -o -name makefile \) -print 2>/dev/null | sed -n '1,80p'`
!`for x in flutter dart node pnpm npm yarn python3 go cargo make; do command -v "$x" >/dev/null 2>&1 && printf '%s=%s\n' "$x" "$(command -v "$x")"; done`

1. Read project scripts/configuration first. Existing documented verification
   commands take priority over these fallbacks.
2. If `pubspec.yaml` declares Flutter, run `flutter analyze` and **always**
   run `flutter test -j 1`; the single job is required for this project's
   test-runner concurrency quirk. If it is non-Flutter Dart, run `dart
   analyze` and `dart test`.
3. For `package.json`, select the manager from its lockfile
   (`pnpm`, `npm`, or `yarn`), inspect scripts, and run only scripts that
   exist: `lint`, `typecheck` or `type-check`, `test`, and project-defined
   `check`/`verify`. Do not run a missing script.
4. For Python, use configured commands when present; otherwise run available
   `ruff check .`, `python3 -m pytest`, and configured type checking only
   when the corresponding tool/configuration exists.
5. For Go run `go vet ./...` and `go test ./...`. For Rust run `cargo fmt
   --check`, `cargo clippy -- -D warnings`, and `cargo test`. For Make, run
   only targets actually declared in the Makefile such as `lint`, `check`,
   `test`, or `verify`.
6. Run every applicable command. A missing tool is **Unavailable**; a missing
   relevant script or configuration is **Skipped**; a nonzero executed
   command is **Failed**; successful execution is **Passed**.
7. Return a compact table: check, exact command, status, and one-line
   evidence. State whether any failure or skip blocks completion. Do not
   claim tests, lint, types, or builds passed unless their commands ran.
