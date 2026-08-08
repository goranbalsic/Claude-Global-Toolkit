#!/bin/sh
set -eu

ctk_dir=$(CDPATH='' cd "$(dirname "$0")" && pwd)
# shellcheck source=common.inc
# shellcheck disable=SC1091 # common.inc is resolved dynamically from ctk_dir.
. "$ctk_dir/common.inc"

ctk_dry_run=false
ctk_base=HEAD~1
ctk_jobs=${CTK_FLUTTER_TEST_JOBS:-1}
ctk_failed=0

ctk_help() {
    cat <<'EOF'
Usage: preflight.sh [--base REF] [--jobs N|-j N] [--dry-run]

Runs release gates: clean Git tree, bumped pubspec version, no tracked signing
or environment files, safe release signing configuration, Flutter analysis,
and tests. The default base revision is HEAD~1.
EOF
}

ctk_gate_pass() {
    printf 'Check: %s: PASS\n' "$1"
}

ctk_gate_fail() {
    printf 'Check: %s: FAIL - %s\n' "$1" "$2" >&2
    ctk_failed=1
}

while [ "$#" -gt 0 ]; do
    case $1 in
        -h|--help)
            ctk_help
            exit 0
            ;;
        --dry-run)
            ctk_dry_run=true
            ;;
        --base)
            if [ "$#" -lt 2 ] || [ -z "$2" ]; then
                ctk_fail "--base requires a Git revision"
            fi
            ctk_base=$2
            shift
            ;;
        -j|--jobs)
            if [ "$#" -lt 2 ]; then
                ctk_fail "$1 requires a positive integer"
            fi
            ctk_jobs=$2
            shift
            ;;
        *)
            ctk_fail "unknown option for preflight: $1. Use --help"
            ;;
    esac
    shift
done

if ! ctk_is_positive_integer "$ctk_jobs"; then
    ctk_fail "test jobs must be a positive integer"
fi

ctk_ensure_flutter_project
ctk_ensure_git_repository

ctk_git_status=$(git status --porcelain)
if [ -n "$ctk_git_status" ]; then
    ctk_gate_fail "clean Git tree" "commit, stash, or discard all changes before release"
else
    ctk_gate_pass "clean Git tree"
fi

ctk_current_version=$(ctk_extract_version pubspec.yaml)
if ! ctk_validate_version "$ctk_current_version"; then
    ctk_gate_fail "current version" "pubspec.yaml must contain SemVer plus a build number"
elif ! git rev-parse --verify "$ctk_base^{commit}" >/dev/null 2>&1; then
    ctk_gate_fail "version bump" "base revision $ctk_base is unavailable"
else
    ctk_base_version=$(git show "$ctk_base:pubspec.yaml" 2>/dev/null |
        awk '
            /^[[:space:]]*version:[[:space:]]*/ {
                value = $0
                sub(/^[[:space:]]*version:[[:space:]]*/, "", value)
                sub(/[[:space:]]*#.*/, "", value)
                print value
                exit
            }
        ')
    if ! ctk_validate_version "$ctk_base_version"; then
        ctk_gate_fail "version bump" "base revision has no supported pubspec version"
    elif ctk_version_is_bumped "$ctk_current_version" "$ctk_base_version"; then
        ctk_gate_pass "version bump"
    else
        ctk_gate_fail "version bump" "current version is not greater than $ctk_base"
    fi
fi

ctk_tracked_secrets=$(git ls-files -- \
    '*.keystore' '*.jks' '*.p12' 'key.properties' '*/key.properties' \
    '.env*' '*/.env*')
if [ -n "$ctk_tracked_secrets" ]; then
    ctk_gate_fail "tracked secrets" "secret-like files are tracked; remove them from the Git index"
else
    ctk_gate_pass "tracked secrets"
fi

if ctk_has_inline_signing_secret; then
    ctk_gate_fail "inline signing secrets" \
        "Gradle appears to assign a signing password literal; use untracked properties or environment values"
else
    ctk_gate_pass "inline signing secrets"
fi

if ctk_has_safe_release_signing_config; then
    ctk_gate_pass "release signing configuration"
else
    ctk_gate_fail "release signing configuration" \
        "configure a non-debug release signing config from an untracked properties file or environment"
fi

if [ "$ctk_failed" -ne 0 ]; then
    printf '%s\n' 'Result: preflight failed before Flutter checks.' >&2
    exit 1
fi

ctk_require_tool flutter

if [ "$ctk_dry_run" = true ]; then
    ctk_print_run sh "$ctk_dir/analyze.sh"
    ctk_print_run sh "$ctk_dir/test.sh" --jobs "$ctk_jobs"
    printf '%s\n' 'Result: dry run; Flutter analysis and tests were not invoked.'
    exit 0
fi

ctk_print_run sh "$ctk_dir/analyze.sh"
if sh "$ctk_dir/analyze.sh"; then
    ctk_gate_pass "Flutter analysis"
else
    ctk_gate_fail "Flutter analysis" "analyze.sh returned a nonzero status"
fi

ctk_print_run sh "$ctk_dir/test.sh" --jobs "$ctk_jobs"
if sh "$ctk_dir/test.sh" --jobs "$ctk_jobs"; then
    ctk_gate_pass "Flutter tests"
else
    ctk_gate_fail "Flutter tests" "test.sh returned a nonzero status"
fi

if [ "$ctk_failed" -ne 0 ]; then
    printf '%s\n' 'Result: preflight failed.' >&2
    exit 1
fi
printf '%s\n' 'Result: preflight passed.'
