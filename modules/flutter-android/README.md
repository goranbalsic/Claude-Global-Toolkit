# Flutter Android module

This opt-in module provides executable checks and build helpers for a Flutter
application that ships Android artifacts. Install it with:

```sh
ctk install --profile full
```

Run the installed slash commands from the Flutter project root. The commands
dispatch to `.claude/ctk/modules/flutter-android/scripts/`; the same scripts
can be run directly while developing the module.

## Prerequisites

- A Flutter application root: `pubspec.yaml` must contain `flutter:`.
- Flutter on `PATH`. Use the project's pinned Flutter version where one is
  documented.
- A compatible JDK and Android SDK. Modern Android Gradle Plugin projects
  commonly require JDK 17 or newer; obey the project's Gradle configuration.
- A Gradle wrapper under `android/`. Flutter invokes it for Android builds.
- Git for `preflight` and `release`.

`doctor` reports missing prerequisites without attempting to install them.

## Commands

| Slash command | Script | Purpose |
| --- | --- | --- |
| `/ctk:analyze` | `analyze.sh` | Runs `flutter analyze --machine`. |
| `/ctk:test` | `test.sh` | Runs tests with configurable concurrency. |
| `/ctk:apk` | `apk.sh` | Builds debug or release APKs, including ABI splits. |
| `/ctk:bundle` | `bundle.sh` | Builds a release `.aab` for Play delivery. |
| `/ctk:version` | `version.sh` | Reads or safely updates `version: x.y.z+n`. |
| `/ctk:preflight` | `preflight.sh` | Runs release gates before an artifact build. |
| `/ctk:release` | `release.sh` | Runs preflight, builds an App Bundle, and can add APKs. |
| `/ctk:doctor` | `doctor.sh` | Reports Flutter, JDK, SDK, wrapper, and signing readiness. |

Every script accepts `--help` and `--dry-run`. Dry-run validates the project
shape and static prerequisites, prints the Flutter command that would run, and
does not start a build, test, analysis, or version rewrite.

Examples:

```sh
sh .claude/ctk/modules/flutter-android/scripts/analyze.sh
sh .claude/ctk/modules/flutter-android/scripts/test.sh --jobs 4 test/widget_test.dart
sh .claude/ctk/modules/flutter-android/scripts/apk.sh --release --split-per-abi
sh .claude/ctk/modules/flutter-android/scripts/bundle.sh --flavor production
sh .claude/ctk/modules/flutter-android/scripts/version.sh --bump patch
sh .claude/ctk/modules/flutter-android/scripts/preflight.sh --base HEAD~1
sh .claude/ctk/modules/flutter-android/scripts/release.sh --apk --split-per-abi
```

### Test concurrency

`test.sh` defaults to `-j 1`. This is a conservative default for the owner
project, which has a documented Flutter test-runner concurrency bug. It is not
a claim that all Flutter projects require serial tests. Override it per run
with `--jobs N`, or set `CTK_FLUTTER_TEST_JOBS=N`; for example, use
`--jobs 4` after the project's suite is known to be concurrency-safe.

### APK and bundle outputs

`apk.sh` defaults to debug. Use `--release` for a signed release build,
`--split-per-abi` for raw-distribution APKs, `--flavor NAME` for a configured
product flavor, and `--target lib/main.dart` for a different entry point. It
reports every APK currently under `build/app/outputs/flutter-apk/` with its
byte and MiB size after a successful build.

`bundle.sh` builds `flutter build appbundle --release` and reports `.aab`
files beneath `build/app/outputs/bundle/`. App Bundles are the normal Play
Store artifact; use ABI-split APKs only where direct APK distribution requires
them.

`release.sh` runs preflight first, then builds an App Bundle. Add `--apk` to
also build release APKs, and pair it with `--split-per-abi` if required. It
never uploads an artifact.

## Safe signing setup

Keep signing material local or in CI secrets. Do not commit a keystore,
`key.properties`, `.env` file, or password value.

1. Add `*.keystore`, `*.jks`, `*.p12`, `android/key.properties`, `.env`, and
   `.env.*` to `.gitignore`.
2. Keep `android/key.properties` untracked and owner-readable only. It needs
   the keys `storeFile`, `storePassword`, `keyAlias`, and `keyPassword`; do
   not put real values in documentation, source control, command output, or
   issue reports.
3. Make `android/app/build.gradle` or `android/app/build.gradle.kts` load that
   local properties file only when it exists, and map a named release signing
   configuration to the release build type. Environment-backed properties are
   also valid when the Gradle file reads them at build time.
4. In CI, inject the keystore and password values from the CI secret store.
   Decode any base64 keystore into a temporary, untracked workspace file and
   remove it after the job.

For Kotlin DSL, the release configuration should load a local properties file
without logging it, then set `release` to use a non-debug signing config. The
module's `doctor` verifies the presence of the local configuration and the
keystore path without displaying property values. `preflight` rejects a
release configuration that explicitly uses debug signing.

## Preflight gates

`preflight.sh` requires all of the following:

- a clean Git working tree;
- a version in `pubspec.yaml` that is greater than the selected base revision
  (`HEAD~1` by default);
- clean `flutter analyze --machine`;
- passing `flutter test -j N`;
- no Git-tracked `*.keystore`, `*.jks`, `*.p12`, `key.properties`, or `.env*`
  files;
- no apparent literal assignment to an Android signing password in Gradle
  source;
- a release signing configuration that uses a local properties file or
  environment values, not debug signing.

Use `--base REF` when the release candidate should be compared with a revision
other than `HEAD~1`. The gate intentionally does not require a local keystore
to be committed or inspect secret values.

## Troubleshooting

| Symptom | Likely cause | Action |
| --- | --- | --- |
| `Unavailable: flutter command was not found` | Flutter is absent from `PATH`. | Install or activate the project's Flutter SDK, then rerun `doctor`. |
| `flutter.sdk not set in local.properties` from `settings.gradle.kts` | The Android build cannot locate Flutter. | Regenerate or correct `android/local.properties`; keep it untracked. |
| Gradle reports an unsupported Java version | The JDK does not match the Android Gradle Plugin. | Check the project Gradle files and select the required JDK, often JDK 17 for current projects. |
| Android SDK license or platform errors | Required SDK packages or licenses are missing. | Use `flutter doctor` and the Android SDK manager outside this module. |
| `SigningConfig ... release` is missing or preflight rejects debug signing | Release signing is not configured safely. | Add an untracked local or environment-backed release signing configuration. Never commit its values. |
| `Conflicting configuration ... ndk abiFilters ... splits abi filters` | Manual Gradle ABI splits conflict with Flutter's plugin. | Remove the manual Gradle `splits` block and use `apk.sh --split-per-abi`. |
| Tests are flaky or hang at higher parallelism | The suite has a concurrency defect. | Keep `--jobs 1`, then raise it only after the project proves safe. |
| No artifact is reported after a successful build | The Gradle output location differs from the standard Flutter layout. | Inspect the Flutter build output, then update the project layout or report the discrepancy. |
