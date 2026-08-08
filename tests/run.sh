#!/bin/sh
# This harness uses isolated targets so every assertion exercises the public CLI.
set -eu

TEST_DIR=$(CDPATH='' ; export CDPATH; cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(CDPATH='' ; export CDPATH; cd "$TEST_DIR/.." && pwd)
CTK=$ROOT_DIR/bin/ctk
FIXTURES=$TEST_DIR/fixtures
WORK=$(mktemp -d "${TMPDIR:-/tmp}/ctk-tests.XXXXXX")
PASS=0
FAIL=0

cleanup() {
    rm -rf "$WORK"
}
trap cleanup 0 HUP INT TERM

pass() {
    PASS=$((PASS + 1))
    printf '%s\n' "PASS: $1"
}

fail() {
    FAIL=$((FAIL + 1))
    printf '%s\n' "FAIL: $1"
}

assert_file_contains() {
    file=$1
    text=$2
    grep -F "$text" "$file" >/dev/null 2>&1
}

strip_block() {
    awk '
        /^<!-- ctk:begin v=/ { inside = 1; next }
        /^<!-- ctk:end -->$/ && inside { inside = 0; next }
        !inside { print }
    ' "$1"
}

new_target() {
    name=$1
    dir=$WORK/$name
    mkdir -p "$dir"
    printf '%s\n' "$dir"
}

test_fresh_install() {
    target=$(new_target fresh)
    "$CTK" install --target "$target" --yes >/dev/null
    assert_file_contains "$target/CLAUDE.md" '<!-- ctk:begin v=3.1.0 profile=standard hash=' &&
        assert_file_contains "$target/CLAUDE.md" '<!-- ctk:end -->'
}

test_idempotent_install() {
    target=$(new_target idempotent)
    "$CTK" install --target "$target" --yes >/dev/null
    before=$(cksum "$target/CLAUDE.md")
    "$CTK" install --target "$target" --yes >/dev/null
    after=$(cksum "$target/CLAUDE.md")
    [ "$before" = "$after" ]
}

test_user_content_preserved() {
    target=$(new_target preserve)
    cp "$FIXTURES/user-claude.md" "$target/CLAUDE.md"
    "$CTK" install --target "$target" --yes >/dev/null
    strip_block "$target/CLAUDE.md" > "$target/outside.md"
    cmp -s "$FIXTURES/user-claude.md" "$target/outside.md"
}

test_update_only_block_body() {
    target=$(new_target update)
    cp "$FIXTURES/user-claude.md" "$target/CLAUDE.md"
    "$CTK" install --target "$target" --link --profile minimal --yes >/dev/null
    printf '%s\n' 'Post-block local content.' >> "$target/CLAUDE.md"
    cat "$FIXTURES/user-claude.md" > "$target/expected-outside.md"
    printf '%s\n' 'Post-block local content.' >> "$target/expected-outside.md"
    "$CTK" update --target "$target" --embed --yes >/dev/null
    strip_block "$target/CLAUDE.md" > "$target/outside.md"
    cmp -s "$target/expected-outside.md" "$target/outside.md" &&
        assert_file_contains "$target/CLAUDE.md" '# Operating rules' &&
        ! grep -q "^@$ROOT_DIR/core/CLAUDE.core.md$" "$target/CLAUDE.md"
}

test_uninstall_restores_original() {
    target=$(new_target uninstall)
    cp "$FIXTURES/user-claude.md" "$target/CLAUDE.md"
    "$CTK" install --target "$target" --yes >/dev/null
    "$CTK" uninstall --target "$target" --yes >/dev/null
    cmp -s "$FIXTURES/user-claude.md" "$target/CLAUDE.md"
}

test_uninstall_empty_removes_file() {
    target=$(new_target empty)
    "$CTK" install --target "$target" --yes >/dev/null
    "$CTK" uninstall --target "$target" --yes >/dev/null
    [ ! -e "$target/CLAUDE.md" ]
}

test_restore() {
    target=$(new_target restore)
    cp "$FIXTURES/user-claude.md" "$target/CLAUDE.md"
    "$CTK" install --target "$target" --yes >/dev/null
    "$CTK" restore --target "$target" --yes >/dev/null
    cmp -s "$FIXTURES/user-claude.md" "$target/CLAUDE.md"
}

test_dry_run_writes_nothing() {
    target=$(new_target dry-run)
    cp "$FIXTURES/user-claude.md" "$target/CLAUDE.md"
    before=$(cksum "$target/CLAUDE.md")
    "$CTK" install --target "$target" --dry-run --yes >/dev/null
    after=$(cksum "$target/CLAUDE.md")
    [ "$before" = "$after" ] && [ ! -e "$target/.ctk-backup" ]
}

new_isolated_toolkit() {
    name=$1
    kit=$WORK/$name/toolkit
    mkdir -p "$kit/bin" "$kit/core/profiles"
    cp "$CTK" "$kit/bin/ctk"
    cp "$ROOT_DIR/core/CLAUDE.core.md" "$kit/core/CLAUDE.core.md"
    cp "$ROOT_DIR"/core/profiles/*.txt "$kit/core/profiles/"
    cp -R "$ROOT_DIR/.claude" "$ROOT_DIR/hooks" "$kit/"
    chmod +x "$kit/bin/ctk"
    printf '%s\n' "$kit"
}

test_budget_rejects_padded_core() {
    kit=$(new_isolated_toolkit padded)
    target=$WORK/padded/target
    mkdir -p "$target"
    yes x | head -c 5000 >> "$kit/core/CLAUDE.core.md"
    if "$kit/bin/ctk" budget --target "$target" > "$WORK/padded/output" 2>&1; then
        return 1
    fi
    grep -q '^FAIL: core ' "$WORK/padded/output"
}

test_doctor_detects_drift() {
    kit=$(new_isolated_toolkit drift)
    target=$WORK/drift/target
    mkdir -p "$target"
    "$kit/bin/ctk" install --target "$target" --yes >/dev/null
    printf '%s\n' 'Changed after installation.' >> "$kit/core/CLAUDE.core.md"
    if "$kit/bin/ctk" doctor --target "$target" > "$WORK/drift/output" 2>&1; then
        return 1
    fi
    grep -q '^FAIL: managed hash drift ' "$WORK/drift/output"
}

run_test() {
    name=$1
    if "$name"; then
        pass "$name"
    else
        fail "$name"
    fi
}


test_profiles_stage_different_file_sets() {
    minimal=$(new_target profile-minimal)
    standard=$(new_target profile-standard)
    full=$(new_target profile-full)
    "$CTK" install --profile minimal --target "$minimal" --yes >/dev/null
    "$CTK" install --profile standard --target "$standard" --yes >/dev/null
    "$CTK" install --profile full --target "$full" --yes >/dev/null
    [ ! -e "$minimal/.claude" ] &&
        [ -f "$standard/.claude/commands/ctk/resume.md" ] &&
        [ -f "$standard/hooks/session-start.sh" ] &&
        [ -f "$standard/.claude/settings.json" ] &&
        [ ! -e "$standard/.claude/agents/investigator.md" ] &&
        [ -f "$full/.claude/agents/investigator.md" ] &&
        [ -f "$full/.claude/skills/safe-changes/SKILL.md" ]
}

test_full_module_detected_only_for_flutter_project() {
    flutter=$(new_target module-flutter)
    plain=$(new_target module-plain)
    printf '%s\n' 'name: demo' 'dependencies:' '  flutter:' '    sdk: flutter' > "$flutter/pubspec.yaml"
    "$CTK" install --profile full --target "$flutter" --yes >/dev/null
    "$CTK" install --profile full --target "$plain" --yes >/dev/null
    [ -f "$flutter/.claude/commands/flutter-android/apk.md" ] &&
        [ -f "$flutter/.claude/ctk/modules/flutter-android/scripts/apk.sh" ] &&
        [ ! -e "$plain/.claude/commands/flutter-android/apk.md" ]
}

test_explicit_module_and_no_modules_are_honored() {
    forced=$(new_target module-forced)
    disabled=$(new_target module-disabled)
    printf '%s\n' 'flutter:' > "$disabled/pubspec.yaml"
    "$CTK" install --profile standard --module flutter-android --target "$forced" --yes >/dev/null
    "$CTK" install --profile full --no-modules --target "$disabled" --yes >/dev/null
    [ -f "$forced/.claude/commands/flutter-android/analyze.md" ] &&
        [ -f "$forced/.claude/ctk/modules/flutter-android/scripts/analyze.sh" ] &&
        [ ! -e "$disabled/.claude/commands/flutter-android/analyze.md" ]
}

test_uninstall_removes_unmodified_staged_assets() {
    target=$(new_target staged-uninstall)
    cp "$FIXTURES/user-claude.md" "$target/CLAUDE.md"
    "$CTK" install --profile standard --target "$target" --yes >/dev/null
    "$CTK" uninstall --target "$target" --yes >/dev/null
    [ ! -e "$target/.claude/commands/ctk/resume.md" ] &&
        [ ! -e "$target/hooks/session-start.sh" ] &&
        [ ! -e "$target/.claude/ctk/installed.txt" ] &&
        cmp -s "$FIXTURES/user-claude.md" "$target/CLAUDE.md"
}

test_uninstall_keeps_modified_staged_asset() {
    target=$(new_target staged-keep)
    "$CTK" install --profile standard --target "$target" --yes >/dev/null
    printf '%s\n' 'local command edit' >> "$target/.claude/commands/ctk/resume.md"
    "$CTK" uninstall --target "$target" --yes > "$target/output"
    [ -f "$target/.claude/commands/ctk/resume.md" ] &&
        grep -F 'KEPT: locally modified staged file: .claude/commands/ctk/resume.md' "$target/output" >/dev/null &&
        grep -F '.claude/commands/ctk/resume.md' "$target/.claude/ctk/installed.txt" >/dev/null
}

test_installed_manifest_is_accurate() {
    target=$(new_target installed-manifest)
    "$CTK" install --profile standard --target "$target" --yes >/dev/null
    manifest=$target/.claude/ctk/installed.txt
    [ "$(awk -F '\t' '$1 == "profile" { print $2 }' "$manifest")" = standard ] &&
        [ "$(awk -F '\t' '$1 == "version" { print $2 }' "$manifest")" = 3.1.0 ] &&
        [ "$(awk -F '\t' '$1 == "schema" { print $2 }' "$manifest")" = 1 ] &&
        grep -F '.claude/commands/ctk/resume.md' "$manifest" >/dev/null &&
        grep -F 'hooks/session-start.sh' "$manifest" >/dev/null &&
        [ "$(awk -F '\t' 'NF == 2 && $1 != "version" && $1 != "profile" && $1 != "schema" && $1 !~ /^#/ { count++ } END { print count + 0 }' "$manifest")" -eq 14 ] &&
        "$CTK" status --target "$target" | grep -F 'Staged files: 14' >/dev/null
}

test_dry_run_profile_stages_nothing() {
    target=$(new_target dry-run-profile)
    cp "$FIXTURES/user-claude.md" "$target/CLAUDE.md"
    "$CTK" install --profile full --target "$target" --dry-run --yes > "$target/output"
    grep -F 'DRY-RUN: STAGE: @state -> .claude/ctk/STATE.md' "$target/output" >/dev/null &&
        grep -F 'DRY-RUN: STAGE:' "$target/output" >/dev/null &&
        [ ! -e "$target/.claude" ] &&
        [ ! -e "$target/.ctk-backup" ] &&
        cmp -s "$FIXTURES/user-claude.md" "$target/CLAUDE.md"
}


test_doctor_flags_missing_and_modified_staged_assets() {
    modified=$(new_target doctor-modified-asset)
    missing=$(new_target doctor-missing-asset)
    "$CTK" install --profile standard --target "$modified" --yes >/dev/null
    printf '%s\n' 'local modification' >> "$modified/.claude/commands/ctk/resume.md"
    if "$CTK" doctor --target "$modified" > "$modified/output" 2>&1; then
        return 1
    fi
    grep -F 'FAIL: staged asset was locally modified: .claude/commands/ctk/resume.md' "$modified/output" >/dev/null || return 1
    "$CTK" install --profile standard --target "$missing" --yes >/dev/null
    rm "$missing/hooks/session-start.sh"
    if "$CTK" doctor --target "$missing" > "$missing/output" 2>&1; then
        return 1
    fi
    grep -F 'FAIL: staged asset is missing: hooks/session-start.sh' "$missing/output" >/dev/null
}

test_dry_run_reports_backup_and_skip_without_writing() {
    target=$(new_target dry-run-backup-skip)
    "$CTK" install --profile standard --target "$target" --yes >/dev/null
    printf '%s\n' 'local settings edit' >> "$target/.claude/settings.json"
    before=$(cksum "$target/.claude/settings.json")
    "$CTK" install --profile standard --target "$target" --dry-run --yes > "$target/output"
    after=$(cksum "$target/.claude/settings.json")
    grep -F 'DRY-RUN: BACKUP: .claude/settings.json' "$target/output" >/dev/null &&
        grep -F 'DRY-RUN: SKIP: identical staged file: .claude/commands/ctk/resume.md' "$target/output" >/dev/null &&
        [ "$before" = "$after" ]
}

test_legacy_manifest_migrates_on_update() {
    target=$(new_target legacy-manifest)
    "$CTK" install --profile standard --target "$target" --yes >/dev/null
    manifest=$target/.claude/ctk/installed.txt
    awk -F '\t' '$1 != "schema"' "$manifest" > "$manifest.tmp" && mv "$manifest.tmp" "$manifest"
    [ "$(awk -F '\t' '$1 == "schema" { c++ } END { print c + 0 }' "$manifest")" -eq 0 ] || return 1
    "$CTK" update --target "$target" --yes >/dev/null
    [ "$(awk -F '\t' '$1 == "schema" { c++ } END { print c + 0 }' "$manifest")" -eq 1 ] &&
        [ "$(awk -F '\t' '$1 == "schema" { print $2 }' "$manifest")" = 1 ] &&
        [ "$(awk -F '\t' '$1 == "version" { c++ } END { print c + 0 }' "$manifest")" -eq 1 ] &&
        [ "$(awk -F '\t' '$1 == "profile" { c++ } END { print c + 0 }' "$manifest")" -eq 1 ]
}

test_doctor_warns_on_legacy_manifest() {
    target=$(new_target doctor-legacy-manifest)
    "$CTK" install --profile standard --target "$target" --yes >/dev/null
    manifest=$target/.claude/ctk/installed.txt
    awk -F '\t' '$1 != "schema"' "$manifest" > "$manifest.tmp" && mv "$manifest.tmp" "$manifest"
    "$CTK" doctor --target "$target" > "$target/output" 2>&1 || return 1
    grep -F "WARN: installed manifest predates schema versioning (run 'ctk update' to migrate)" "$target/output" >/dev/null
}

test_goal_lifecycle() {
    target=$(new_target goal-lifecycle)
    "$CTK" goal show --target "$target" | grep -F 'SKIP: no active goal' >/dev/null || return 1
    "$CTK" goal set --objective 'ship parser' --acceptance 'tests pass' --target "$target" --yes >/dev/null
    assert_file_contains "$target/.claude/ctk/GOAL.md" 'objective: ship parser' &&
        assert_file_contains "$target/.claude/ctk/GOAL.md" 'status: active' || return 1
    "$CTK" goal pause --target "$target" --yes >/dev/null
    assert_file_contains "$target/.claude/ctk/GOAL.md" 'status: paused' || return 1
    if "$CTK" goal complete --target "$target" --yes >"$target/output" 2>&1; then
        return 1
    fi
    grep -F 'goal complete requires --evidence' "$target/output" >/dev/null || return 1
    "$CTK" goal complete --evidence 'sh tests/run.sh: 0 failed' --target "$target" --yes >/dev/null
    assert_file_contains "$target/.claude/ctk/GOAL.md" 'status: completed' &&
        assert_file_contains "$target/.claude/ctk/GOAL.md" 'evidence: sh tests/run.sh: 0 failed' || return 1
    "$CTK" goal clear --target "$target" --yes >/dev/null
    [ ! -e "$target/.claude/ctk/GOAL.md" ]
}

test_goal_excluded_from_budget() {
    target=$(new_target goal-budget)
    "$CTK" goal set --objective 'x' --acceptance 'y' --target "$target" --yes >/dev/null
    "$CTK" budget --target "$target" > "$target/output"
    ! grep -F 'GOAL.md' "$target/output" >/dev/null
}

test_flutter_module_skills_staged_with_module() {
    flutter=$(new_target module-flutter-skills)
    plain=$(new_target module-plain-skills)
    printf '%s\n' 'name: demo' 'dependencies:' '  flutter:' '    sdk: flutter' > "$flutter/pubspec.yaml"
    "$CTK" install --profile full --target "$flutter" --yes >/dev/null
    "$CTK" install --profile full --target "$plain" --yes >/dev/null
    [ -f "$flutter/.claude/skills/flutter-android/flutter-recon/SKILL.md" ] &&
        [ -f "$flutter/.claude/skills/flutter-android/flutter-ui-checklist/SKILL.md" ] &&
        [ ! -e "$plain/.claude/skills/flutter-android" ] &&
        grep -F '.claude/skills/flutter-android/flutter-recon/SKILL.md' "$flutter/.claude/ctk/installed.txt" >/dev/null
}

run_test test_fresh_install
run_test test_idempotent_install
run_test test_user_content_preserved
run_test test_update_only_block_body
run_test test_uninstall_restores_original
run_test test_uninstall_empty_removes_file
run_test test_restore
run_test test_dry_run_writes_nothing
run_test test_budget_rejects_padded_core
run_test test_doctor_detects_drift
run_test test_profiles_stage_different_file_sets
run_test test_full_module_detected_only_for_flutter_project
run_test test_explicit_module_and_no_modules_are_honored
run_test test_uninstall_removes_unmodified_staged_assets
run_test test_uninstall_keeps_modified_staged_asset
run_test test_installed_manifest_is_accurate
run_test test_dry_run_profile_stages_nothing
run_test test_doctor_flags_missing_and_modified_staged_assets
run_test test_dry_run_reports_backup_and_skip_without_writing
run_test test_legacy_manifest_migrates_on_update
run_test test_doctor_warns_on_legacy_manifest
run_test test_goal_lifecycle
run_test test_goal_excluded_from_budget
run_test test_flutter_module_skills_staged_with_module

printf '%s\n' "SUMMARY: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
