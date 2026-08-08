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
    assert_file_contains "$target/CLAUDE.md" '<!-- ctk:begin v=3.3.0 profile=standard hash=' &&
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
        [ "$(awk -F '\t' '$1 == "version" { print $2 }' "$manifest")" = 3.3.0 ] &&
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

new_ctk_home() {
    new_target "$1"
}

test_bootstrap_registers_and_installs_router() {
    home=$(new_ctk_home boot-fresh)
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null
    assert_file_contains "$home/.claude/ctk/registration.txt" "root	$ROOT_DIR" &&
        assert_file_contains "$home/.claude/settings.json" 'session-sync-router.sh'
}

test_bootstrap_is_idempotent() {
    home=$(new_ctk_home boot-idempotent)
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null
    [ "$(grep -o 'session-sync-router' "$home/.claude/settings.json" | wc -l)" -eq 1 ]
}

test_disable_removes_fully_owned_settings_and_registration() {
    home=$(new_ctk_home boot-disable)
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null
    CTK_HOME="$home" "$CTK" disable --yes >/dev/null
    [ ! -e "$home/.claude/settings.json" ] && [ ! -e "$home/.claude/ctk/registration.txt" ]
}

test_bootstrap_preserves_unrelated_settings_content() {
    home=$(new_ctk_home boot-unrelated)
    mkdir -p "$home/.claude"
    printf '%s' '{"hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"echo unrelated-hook"}]}]}}' > "$home/.claude/settings.json"
    # Whether this succeeds (jq present, real merge) or fails closed (no jq,
    # existing content) depends on the environment; the one invariant that
    # must always hold is that the pre-existing unrelated hook is never lost
    # or corrupted, so the bootstrap call's own exit status is not asserted.
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null 2>&1 || true
    assert_file_contains "$home/.claude/settings.json" 'echo unrelated-hook'
}

test_disable_noop_preserves_untouched_settings() {
    home=$(new_ctk_home boot-disable-noop)
    mkdir -p "$home/.claude"
    printf '%s' '{"hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"echo unrelated-hook"}]}]}}' > "$home/.claude/settings.json"
    before=$(cksum "$home/.claude/settings.json")
    CTK_HOME="$home" "$CTK" disable --yes >/dev/null
    after=$(cksum "$home/.claude/settings.json")
    [ "$before" = "$after" ]
}

GLOBAL_COMMAND_NAMES='install update doctor status resume checkpoint goal refine'

test_bootstrap_creates_global_commands() {
    home=$(new_ctk_home boot-global-fresh)
    CTK_HOME="$home" "$CTK" bootstrap --yes >"$home/output"
    [ -f "$home/.claude/ctk/global-router.sh" ] || return 1
    for cmd_name in $GLOBAL_COMMAND_NAMES; do
        [ -f "$home/.claude/commands/ctk/$cmd_name.md" ] || return 1
    done
    grep -F 'Global commands available' "$home/output" >/dev/null &&
        grep -F '/ctk:install' "$home/output" >/dev/null &&
        grep -F '/ctk:refine' "$home/output" >/dev/null
}

test_bootstrap_global_commands_idempotent() {
    home=$(new_ctk_home boot-global-idempotent)
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null
    before=$(cksum "$home/.claude/commands/ctk/resume.md")
    before_router=$(cksum "$home/.claude/ctk/global-router.sh")
    CTK_HOME="$home" "$CTK" bootstrap --yes >"$home/output2"
    after=$(cksum "$home/.claude/commands/ctk/resume.md")
    after_router=$(cksum "$home/.claude/ctk/global-router.sh")
    [ "$before" = "$after" ] && [ "$before_router" = "$after_router" ] &&
        grep -F 'SKIP: identical global file: commands/ctk/resume.md' "$home/output2" >/dev/null
}

test_disable_removes_only_ctk_owned_global_commands() {
    home=$(new_ctk_home boot-global-disable)
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null
    mkdir -p "$home/.claude/commands/other-tool"
    printf '%s\n' 'unrelated user command' > "$home/.claude/commands/other-tool/foo.md"
    printf '%s\n' 'unrelated user note' > "$home/.claude/commands/ctk/my-notes.md"
    CTK_HOME="$home" "$CTK" disable --yes >/dev/null
    for cmd_name in $GLOBAL_COMMAND_NAMES; do
        [ ! -e "$home/.claude/commands/ctk/$cmd_name.md" ] || return 1
    done
    [ ! -e "$home/.claude/ctk/global-router.sh" ] &&
        [ -f "$home/.claude/commands/other-tool/foo.md" ] &&
        [ -f "$home/.claude/commands/ctk/my-notes.md" ]
}

test_global_command_files_have_correct_routing() {
    home=$(new_ctk_home boot-global-routing)
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null
    router="$home/.claude/ctk/global-router.sh"
    # shellcheck disable=SC2016 # asserting on literal router text; no expansion wanted
    grep -F 'registration.txt' "$router" >/dev/null &&
        grep -F 'powershell -NoProfile -ExecutionPolicy Bypass -File' "$router" >/dev/null &&
        grep -F 'sh "$ctk_script"' "$router" >/dev/null || return 1
    for cmd_name in $GLOBAL_COMMAND_NAMES; do
        cmd_file="$home/.claude/commands/ctk/$cmd_name.md"
        ! grep -F 'CLAUDE_PROJECT_DIR/bin/ctk' "$cmd_file" >/dev/null || return 1
        # resume is the one command with no CLI dependency at all (pure git +
        # STATE.md read), so it is the one file that never needs to route
        # through global-router.sh; every other command does.
        if [ "$cmd_name" != resume ]; then
            grep -F 'global-router.sh' "$cmd_file" >/dev/null || return 1
        fi
    done
}

test_global_commands_do_not_load_full_core_by_default() {
    for cmd_name in $GLOBAL_COMMAND_NAMES; do
        tpl="$ROOT_DIR/global-commands/$cmd_name.md"
        [ -f "$tpl" ] || return 1
        # No unconditional @-style import of the core file.
        ! grep -E '^@.*CLAUDE\.core\.md' "$tpl" >/dev/null || return 1
        # The only place content is actually loaded eagerly (before Claude
        # even reads the instructions) is an inline !`...` exec line. Prose
        # elsewhere -- e.g. refine.md naming `.claude/skills/**/SKILL.md` as
        # a target pattern it may propose edits to -- is on-demand analysis,
        # not an eager load, so only inline-exec lines are checked here.
        if grep -E '^!`' "$tpl" | grep -qE 'CLAUDE\.core\.md|\.claude/skills|\.claude/ctk/GOAL\.md|modules/flutter-android'; then
            return 1
        fi
    done
}

test_global_install_works_before_project_ctk_files_exist() {
    home=$(new_ctk_home boot-global-install)
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null
    project=$(new_target new-project-no-ctk)
    [ ! -e "$project/.claude" ] &&
        [ ! -e "$project/bin/ctk" ] || return 1
    CTK_HOME="$home" sh "$home/.claude/ctk/global-router.sh" install --profile standard --target "$project" --yes >/dev/null
    assert_file_contains "$project/CLAUDE.md" '<!-- ctk:begin v=' &&
        [ -f "$project/.claude/commands/ctk/resume.md" ]
}

test_global_update_doctor_resume_on_existing_apk_project() {
    home=$(new_ctk_home boot-global-apk)
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null
    project=$(new_target apk-project)
    printf '%s\n' 'name: demo' 'dependencies:' '  flutter:' '    sdk: flutter' > "$project/pubspec.yaml"
    CTK_HOME="$home" sh "$home/.claude/ctk/global-router.sh" install --profile full --target "$project" --yes >/dev/null
    [ -f "$project/.claude/commands/flutter-android/apk.md" ] || return 1
    CTK_HOME="$home" sh "$home/.claude/ctk/global-router.sh" doctor --target "$project" >"$project/doctor-output" || return 1
    grep -F 'PASS: one complete managed block is present' "$project/doctor-output" >/dev/null || return 1
    CTK_HOME="$home" sh "$home/.claude/ctk/global-router.sh" update --target "$project" --yes >"$project/update-output" || return 1
    grep -F 'CHANGED: updated managed block' "$project/update-output" >/dev/null || return 1
    CTK_HOME="$home" sh "$home/.claude/ctk/global-router.sh" state add "resumed via global command" --target "$project" --yes >/dev/null
    assert_file_contains "$project/.claude/ctk/STATE.md" 'resumed via global command'
}

# 3.3.0 regression set: global command files installed under $HOME are copies,
# so a CTK checkout update used to leave them stale until bootstrap was re-run
# by hand. That is what shipped a fixed template while the broken one still
# ran. Session sync must refresh them, and must refuse to do so from a
# checkout that is not the registered one.
test_session_sync_refreshes_stale_global_commands() {
    home=$(new_ctk_home sync-refresh-home)
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null
    cmd_file=$home/.claude/commands/ctk/update.md
    printf '%s\n' 'STALE CONTENT' > "$cmd_file"
    target=$(new_target sync-refresh-project)
    CTK_HOME="$home" "$CTK" install --target "$target" --yes >/dev/null
    CTK_HOME="$home" "$CTK" update --session-sync --target "$target" --yes > "$target/output" 2>&1 || return 1
    cmp -s "$ROOT_DIR/global-commands/update.md" "$cmd_file" &&
        grep -F 'Refreshed 1 global command file' "$target/output" >/dev/null
}

test_session_sync_global_refresh_is_idempotent() {
    home=$(new_ctk_home sync-refresh-idem-home)
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null
    target=$(new_target sync-refresh-idem-project)
    CTK_HOME="$home" "$CTK" install --target "$target" --yes >/dev/null
    CTK_HOME="$home" "$CTK" update --session-sync --target "$target" --yes > "$target/output" 2>&1 || return 1
    ! grep -F 'Refreshed' "$target/output" >/dev/null
}

test_session_sync_never_creates_global_commands() {
    home=$(new_ctk_home sync-refresh-nocreate-home)
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null
    rm -f "$home/.claude/commands/ctk/doctor.md"
    target=$(new_target sync-refresh-nocreate-project)
    CTK_HOME="$home" "$CTK" install --target "$target" --yes >/dev/null
    CTK_HOME="$home" "$CTK" update --session-sync --target "$target" --yes >/dev/null 2>&1 || return 1
    [ ! -e "$home/.claude/commands/ctk/doctor.md" ]
}

test_session_sync_refresh_ignores_unregistered_checkout() {
    home=$(new_ctk_home sync-refresh-foreign-home)
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null
    cmd_file=$home/.claude/commands/ctk/status.md
    printf '%s\n' 'STALE CONTENT' > "$cmd_file"
    # Point the registration at some other directory: this checkout is then
    # not the registered one and must leave the machine's globals alone.
    other=$(new_target sync-refresh-foreign-root)
    sed "s|^root\t.*|root\t$other|" "$home/.claude/ctk/registration.txt" > "$home/.claude/ctk/registration.new"
    mv "$home/.claude/ctk/registration.new" "$home/.claude/ctk/registration.txt"
    target=$(new_target sync-refresh-foreign-project)
    CTK_HOME="$home" "$CTK" install --target "$target" --yes >/dev/null
    CTK_HOME="$home" "$CTK" update --session-sync --target "$target" --yes >/dev/null 2>&1 || return 1
    grep -F 'STALE CONTENT' "$cmd_file" >/dev/null
}

test_repo_pins_lf_line_endings() {
    # A CRLF checkout of these files broke 4 tests on the primary Windows
    # machine while CI stayed green. .gitattributes is the fix.
    assert_file_contains "$ROOT_DIR/.gitattributes" 'eol=lf'
}

test_session_sync_current_project_no_write() {
    target=$(new_target sync-current)
    "$CTK" install --target "$target" --yes >/dev/null
    before=$(cksum "$target/CLAUDE.md")
    if "$CTK" update --session-sync --target "$target" --yes > "$target/output"; then :; else return 1; fi
    after=$(cksum "$target/CLAUDE.md")
    grep -F 'CTK: current' "$target/output" >/dev/null && [ "$before" = "$after" ]
}

test_session_sync_first_install_needs_approval() {
    target=$(new_target sync-first-install)
    code=0
    "$CTK" update --session-sync --target "$target" --yes > "$target/output" 2>&1 || code=$?
    [ "$code" -eq 10 ] &&
        grep -F 'first install requires approval' "$target/output" >/dev/null &&
        [ ! -e "$target/CLAUDE.md" ]
}

test_session_sync_orphaned_markers_fail_closed() {
    target=$(new_target sync-orphan)
    printf '%s\n' '<!-- ctk:begin v=x -->' '<!-- ctk:end -->' '<!-- ctk:begin v=y -->' '<!-- ctk:end -->' > "$target/CLAUDE.md"
    before=$(cksum "$target/CLAUDE.md")
    code=0
    "$CTK" update --session-sync --target "$target" --yes > "$target/output" 2>&1 || code=$?
    after=$(cksum "$target/CLAUDE.md")
    [ "$code" -eq 12 ] && [ "$before" = "$after" ]
}

test_session_sync_missing_manifest_fails_closed() {
    target=$(new_target sync-no-manifest)
    "$CTK" install --target "$target" --yes >/dev/null
    rm -f "$target/.claude/ctk/installed.txt"
    before=$(cksum "$target/CLAUDE.md")
    code=0
    "$CTK" update --session-sync --target "$target" --yes > "$target/output" 2>&1 || code=$?
    after=$(cksum "$target/CLAUDE.md")
    [ "$code" -eq 12 ] && [ "$before" = "$after" ]
}

test_session_sync_conflict_preserves_local_edit() {
    target=$(new_target sync-conflict)
    "$CTK" install --profile full --target "$target" --yes >/dev/null
    printf '%s\n' 'local edit' >> "$target/.claude/commands/ctk/resume.md"
    before_claude=$(cksum "$target/CLAUDE.md")
    code=0
    "$CTK" update --session-sync --target "$target" --yes > "$target/output" 2>&1 || code=$?
    after_claude=$(cksum "$target/CLAUDE.md")
    [ "$code" -eq 11 ] &&
        grep -F 'locally modified managed file detected (.claude/commands/ctk/resume.md)' "$target/output" >/dev/null &&
        grep -F 'local edit' "$target/.claude/commands/ctk/resume.md" >/dev/null &&
        [ "$before_claude" = "$after_claude" ]
}

test_session_sync_applies_safe_update_after_drift() {
    kit=$(new_isolated_toolkit sync-drift)
    target=$WORK/sync-drift/target
    mkdir -p "$target"
    "$kit/bin/ctk" install --target "$target" --yes >/dev/null
    before_hash=$(grep -o 'hash=[a-f0-9]*' "$target/CLAUDE.md")
    printf '\n%s\n' '<!-- test: pretend upstream change -->' >> "$kit/core/CLAUDE.core.md"
    "$kit/bin/ctk" update --session-sync --target "$target" --yes > "$target/output"
    code=$?
    after_hash=$(grep -o 'hash=[a-f0-9]*' "$target/CLAUDE.md")
    [ "$code" -eq 0 ] &&
        [ "$before_hash" != "$after_hash" ] &&
        grep -F 'CTK: updated to' "$target/output" >/dev/null &&
        "$kit/bin/ctk" update --session-sync --target "$target" --yes | grep -F 'CTK: current' >/dev/null
}

test_session_sync_preserves_checkpoint_state() {
    kit=$(new_isolated_toolkit sync-state-preserve)
    target=$WORK/sync-state-preserve/target
    mkdir -p "$target"
    "$kit/bin/ctk" install --target "$target" --yes >/dev/null
    "$kit/bin/ctk" state add "checkpoint before drift" --target "$target" --yes >/dev/null
    printf '\n%s\n' '<!-- test: pretend upstream change -->' >> "$kit/core/CLAUDE.core.md"
    "$kit/bin/ctk" update --session-sync --target "$target" --yes >/dev/null
    assert_file_contains "$target/.claude/ctk/STATE.md" 'checkpoint before drift'
}

test_doctor_passes_after_state_add() {
    target=$(new_target doctor-state-add)
    "$CTK" install --target "$target" --yes >/dev/null
    "$CTK" state add "a normal checkpoint" --target "$target" --yes >/dev/null
    "$CTK" doctor --target "$target" >/dev/null
}

test_update_preserves_state_history() {
    target=$(new_target update-state-preserve)
    "$CTK" install --target "$target" --yes >/dev/null
    "$CTK" state add "must survive update" --target "$target" --yes >/dev/null
    "$CTK" update --target "$target" --yes >/dev/null
    assert_file_contains "$target/.claude/ctk/STATE.md" 'must survive update'
}

test_router_unrelated_directory_is_silent() {
    home=$(new_ctk_home router-unrelated-home)
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null
    unrelated=$(new_target router-unrelated-dir)
    output=$(CTK_HOME="$home" CLAUDE_PROJECT_DIR="$unrelated" sh "$ROOT_DIR/router/session-sync-router.sh")
    [ -z "$output" ] && [ ! -e "$unrelated/.claude" ] && [ ! -e "$unrelated/CLAUDE.md" ]
}

test_router_first_time_project_reports_approval() {
    home=$(new_ctk_home router-first-home)
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null
    first=$WORK/router-first-project
    mkdir -p "$first/.git"
    output=$(CTK_HOME="$home" CLAUDE_PROJECT_DIR="$first" sh "$ROOT_DIR/router/session-sync-router.sh")
    printf '%s\n' "$output" | grep -F 'approval required' >/dev/null && [ ! -e "$first/CLAUDE.md" ]
}

test_router_existing_project_defers_to_session_sync() {
    home=$(new_ctk_home router-existing-home)
    CTK_HOME="$home" "$CTK" bootstrap --yes >/dev/null
    target=$(new_target router-existing-project)
    "$CTK" install --target "$target" --yes >/dev/null
    output=$(CTK_HOME="$home" CLAUDE_PROJECT_DIR="$target" sh "$ROOT_DIR/router/session-sync-router.sh")
    printf '%s\n' "$output" | grep -F 'CTK: current' >/dev/null
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
run_test test_bootstrap_registers_and_installs_router
run_test test_bootstrap_is_idempotent
run_test test_disable_removes_fully_owned_settings_and_registration
run_test test_bootstrap_preserves_unrelated_settings_content
run_test test_disable_noop_preserves_untouched_settings
run_test test_bootstrap_creates_global_commands
run_test test_bootstrap_global_commands_idempotent
run_test test_disable_removes_only_ctk_owned_global_commands
run_test test_global_command_files_have_correct_routing
run_test test_global_commands_do_not_load_full_core_by_default
run_test test_global_install_works_before_project_ctk_files_exist
run_test test_global_update_doctor_resume_on_existing_apk_project
run_test test_session_sync_current_project_no_write
run_test test_session_sync_refreshes_stale_global_commands
run_test test_session_sync_global_refresh_is_idempotent
run_test test_session_sync_never_creates_global_commands
run_test test_session_sync_refresh_ignores_unregistered_checkout
run_test test_repo_pins_lf_line_endings
run_test test_session_sync_first_install_needs_approval
run_test test_session_sync_orphaned_markers_fail_closed
run_test test_session_sync_missing_manifest_fails_closed
run_test test_session_sync_conflict_preserves_local_edit
run_test test_session_sync_applies_safe_update_after_drift
run_test test_session_sync_preserves_checkpoint_state
run_test test_doctor_passes_after_state_add
run_test test_update_preserves_state_history
run_test test_router_unrelated_directory_is_silent
run_test test_router_first_time_project_reports_approval
run_test test_router_existing_project_defers_to_session_sync

printf '%s\n' "SUMMARY: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
