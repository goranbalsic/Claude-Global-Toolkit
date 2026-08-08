#!/bin/sh
set -eu

ctk_dir=$(CDPATH='' cd "$(dirname "$0")" && pwd)
# shellcheck source=common.inc
# shellcheck disable=SC1091 # common.inc is resolved dynamically from ctk_dir.
. "$ctk_dir/common.inc"

ctk_dry_run=false
ctk_include_apk=false
ctk_split_per_abi=false
ctk_flavor=
ctk_target=
ctk_base=HEAD~1
ctk_jobs=${CTK_FLUTTER_TEST_JOBS:-1}

ctk_help() {
    cat <<'EOF'
Usage: release.sh [--apk] [--split-per-abi] [--flavor NAME] [--target PATH]
                  [--base REF] [--jobs N|-j N] [--dry-run]

Runs preflight, builds a release App Bundle, and optionally builds release APKs.
This command does not upload artifacts or create signing material.
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
        --apk)
            ctk_include_apk=true
            ;;
        --split-per-abi)
            ctk_split_per_abi=true
            ;;
        --flavor|--target|--base)
            if [ "$#" -lt 2 ] || [ -z "$2" ]; then
                ctk_fail "$1 requires a value"
            fi
            case $1 in
                --flavor)
                    ctk_flavor=$2
                    ;;
                --target)
                    ctk_target=$2
                    ;;
                --base)
                    ctk_base=$2
                    ;;
            esac
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
            ctk_fail "unknown option for release: $1. Use --help"
            ;;
    esac
    shift
done

if ! ctk_is_positive_integer "$ctk_jobs"; then
    ctk_fail "test jobs must be a positive integer"
fi
if [ "$ctk_split_per_abi" = true ] && [ "$ctk_include_apk" = false ]; then
    ctk_fail "--split-per-abi requires --apk"
fi

ctk_ensure_flutter_project
ctk_require_tool flutter

set -- sh "$ctk_dir/preflight.sh" --base "$ctk_base" --jobs "$ctk_jobs"
if [ "$ctk_dry_run" = true ]; then
    set -- "$@" --dry-run
fi
ctk_print_run "$@"
if "$@"; then
    :
else
    ctk_status=$?
    printf 'Result: release stopped because preflight failed with exit code %s.\n' "$ctk_status" >&2
    exit "$ctk_status"
fi

set -- sh "$ctk_dir/bundle.sh"
if [ -n "$ctk_flavor" ]; then
    set -- "$@" --flavor "$ctk_flavor"
fi
if [ -n "$ctk_target" ]; then
    set -- "$@" --target "$ctk_target"
fi
if [ "$ctk_dry_run" = true ]; then
    set -- "$@" --dry-run
fi
ctk_print_run "$@"
if "$@"; then
    :
else
    ctk_status=$?
    printf 'Result: release App Bundle build failed with exit code %s.\n' "$ctk_status" >&2
    exit "$ctk_status"
fi

if [ "$ctk_include_apk" = true ]; then
    set -- sh "$ctk_dir/apk.sh" --release
    if [ "$ctk_split_per_abi" = true ]; then
        set -- "$@" --split-per-abi
    fi
    if [ -n "$ctk_flavor" ]; then
        set -- "$@" --flavor "$ctk_flavor"
    fi
    if [ -n "$ctk_target" ]; then
        set -- "$@" --target "$ctk_target"
    fi
    if [ "$ctk_dry_run" = true ]; then
        set -- "$@" --dry-run
    fi
    ctk_print_run "$@"
    if "$@"; then
        :
    else
        ctk_status=$?
        printf 'Result: release APK build failed with exit code %s.\n' "$ctk_status" >&2
        exit "$ctk_status"
    fi
fi

if [ "$ctk_dry_run" = true ]; then
    printf '%s\n' 'Result: release dry run completed; no artifacts were built.'
else
    printf '%s\n' 'Result: release artifacts built successfully; no upload was performed.'
fi
