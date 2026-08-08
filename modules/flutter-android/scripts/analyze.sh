#!/bin/sh
set -eu

ctk_dir=$(CDPATH='' cd "$(dirname "$0")" && pwd)
# shellcheck source=common.inc
# shellcheck disable=SC1091 # common.inc is resolved dynamically from ctk_dir.
. "$ctk_dir/common.inc"

ctk_dry_run=false

ctk_help() {
    cat <<'EOF'
Usage: analyze.sh [--dry-run]

Runs flutter analyze --machine from a Flutter application root.
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
        *)
            ctk_fail "unknown option for analyze: $1. Use --help"
            ;;
    esac
    shift
done

ctk_ensure_flutter_project
ctk_require_tool flutter
ctk_print_run flutter analyze --machine

if [ "$ctk_dry_run" = true ]; then
    printf '%s\n' 'Result: dry run; flutter analyze was not invoked.'
    exit 0
fi

if flutter analyze --machine; then
    printf '%s\n' 'Result: flutter analyze passed (machine-readable diagnostics were emitted above).'
else
    ctk_status=$?
    printf 'Result: flutter analyze failed with exit code %s.\n' "$ctk_status" >&2
    exit "$ctk_status"
fi
