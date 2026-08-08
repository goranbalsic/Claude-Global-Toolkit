---
name: flutter-android
description: "Flutter Android release workflows: static analysis, tests, APK and Play App Bundle builds, version bumping, signing preflight, and environment diagnostics."
version: 1.1.0
profiles:
  - full
detect: "pubspec.yaml contains flutter:"
token-cost: "0 until a flutter-android slash command is invoked"
---

# Flutter Android module

This module adds executable Flutter Android workflows for static analysis,
tests, APKs, Play App Bundles, version changes, release preflight, and
environment diagnostics. It is intended for a Flutter application repository,
not a Dart-only package.

## Applies when

Install and use this module only when the repository root contains
`pubspec.yaml` with a top-level `flutter:` section. Every script repeats this
check before it does any work.

## Adds

- `/flutter-android:analyze`, `/flutter-android:test`, `/flutter-android:apk`,
  `/flutter-android:bundle`, `/flutter-android:version`,
  `/flutter-android:preflight`, `/flutter-android:release`, and
  `/flutter-android:doctor`.
- POSIX shell helpers that call the installed Flutter SDK and Gradle wrapper
  through Flutter.
- A release gate that rejects tracked keystores, `key.properties`, and
  environment files before release work begins.
- Two on-demand skills for the planning side of Flutter work that the
  commands above do not cover: `flutter-recon` (project reconnaissance and
  scoped change planning) and `flutter-ui-checklist` (a UI/feature
  implementation checklist). Both cost nothing until invoked, same as the
  commands.

## Does not do

- It does not install Flutter, Java, Android SDK components, Gradle, or any
  package.
- It does not edit Gradle signing configuration, generate a keystore, read or
  print password values, upload artifacts, publish to Play, or commit changes.
- It does not assume every Flutter project needs serial tests. The test
  concurrency is configurable because some projects have a runner-concurrency
  defect.

The module adds no always-loaded instructions. Its token cost is zero until a
user invokes one of its commands.
