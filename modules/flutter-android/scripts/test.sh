#!/bin/sh
set -eu

ctk_dir=$(CDPATH='' cd "$(dirname "$0")" && pwd)
# shellcheck source=common.inc
# shellcheck disable=SC1091 # common.inc is resolved dynamically from ctk_dir.
. "$ctk_dir/common.inc"

ctk_dry_run=false
ctk_jobs=${CTK_FLUTTER_TEST_JOBS:-1}
ctk_target=

ctk_help() {
    cat <<'EOF'
Usage: test.sh [--jobs N|-j N] [test-path] [--dry-run]

Runs flutter test -j N. N defaults to CTK_FLUTTER_TEST_JOBS or 1.
The default is conservative for projects with a test-runner concurrency defect;
it is not a universal Flutter requirement.
EOF
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
        -j|--jobs)
            if [ "$#" -lt 2 ]; then
                ctk_fail "$1 requires a positive integer"
            fi
            ctk_jobs=$2
            shift
            ;;
        --)
            shift
            if [ "$#" -gt 1 ] || { [ "$#" -eq 1 ] && [ -n "$ctk_target" ]; }; then
                ctk_fail "only one optional test path is supported"
            fi
            if [ "$#" -eq 1 ]; then
                ctk_target=$1
            fi
            break
            ;;
        -*)
            ctk_fail "unknown option for test: $1. Use --help"
            ;;
        *)
            if [ -n "$ctk_target" ]; then
                ctk_fail "only one optional test path is supported"
            fi
            ctk_target=$1
            ;;
    esac
    shift
done

if ! ctk_is_positive_integer "$ctk_jobs"; then
    ctk_fail "test jobs must be a positive integer"
fi

ctk_ensure_flutter_project
ctk_require_tool flutter

set -- flutter test -j "$ctk_jobs"
if [ -n "$ctk_target" ]; then
    set -- "$@" "$ctk_target"
fi
ctk_print_run "$@"

if [ "$ctk_dry_run" = true ]; then
    printf '%s\n' 'Result: dry run; flutter test was not invoked.'
    exit 0
fi

if "$@"; then
    printf 'Result: flutter test passed with -j %s.\n' "$ctk_jobs"
else
    ctk_status=$?
    printf 'Result: flutter test failed with exit code %s.\n' "$ctk_status" >&2
    exit "$ctk_status"
fi
