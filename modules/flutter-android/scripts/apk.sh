#!/bin/sh
set -eu

ctk_dir=$(CDPATH='' cd "$(dirname "$0")" && pwd)
# shellcheck source=common.inc
# shellcheck disable=SC1091 # common.inc is resolved dynamically from ctk_dir.
. "$ctk_dir/common.inc"

ctk_dry_run=false
ctk_mode=debug
ctk_split_per_abi=false
ctk_flavor=
ctk_target=

ctk_help() {
    cat <<'EOF'
Usage: apk.sh [--debug|--release] [--split-per-abi] [--flavor NAME]
              [--target PATH] [--dry-run]

Builds a Flutter Android APK. Debug is the default. Reports APK paths and
sizes after a successful build.
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
        --debug)
            ctk_mode=debug
            ;;
        --release)
            ctk_mode=release
            ;;
        --split-per-abi)
            ctk_split_per_abi=true
            ;;
        --flavor|--target)
            if [ "$#" -lt 2 ] || [ -z "$2" ]; then
                ctk_fail "$1 requires a value"
            fi
            if [ "$1" = --flavor ]; then
                ctk_flavor=$2
            else
                ctk_target=$2
            fi
            shift
            ;;
        *)
            ctk_fail "unknown option for apk: $1. Use --help"
            ;;
    esac
    shift
done

ctk_ensure_flutter_project
ctk_require_tool flutter

set -- flutter build apk "--$ctk_mode"
if [ "$ctk_split_per_abi" = true ]; then
    set -- "$@" --split-per-abi
fi
if [ -n "$ctk_flavor" ]; then
    set -- "$@" --flavor "$ctk_flavor"
fi
if [ -n "$ctk_target" ]; then
    set -- "$@" --target "$ctk_target"
fi
ctk_print_run "$@"

if [ "$ctk_dry_run" = true ]; then
    printf '%s\n' 'Result: dry run; no APK was built.'
    exit 0
fi

if "$@"; then
    :
else
    ctk_status=$?
    printf 'Result: Flutter APK build failed with exit code %s.\n' "$ctk_status" >&2
    exit "$ctk_status"
fi

if ! ctk_report_artifacts '*.apk' build/app/outputs/flutter-apk; then
    ctk_fail "Flutter reported success but no APK was found under build/app/outputs/flutter-apk"
fi
printf '%s\n' 'Result: Flutter APK build succeeded.'
