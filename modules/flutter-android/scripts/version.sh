#!/bin/sh
set -eu

ctk_dir=$(CDPATH='' cd "$(dirname "$0")" && pwd)
# shellcheck source=common.inc
# shellcheck disable=SC1091 # common.inc is resolved dynamically from ctk_dir.
. "$ctk_dir/common.inc"

ctk_dry_run=false
ctk_action=show
ctk_action_value=

ctk_help() {
    cat <<'EOF'
Usage: version.sh [--show] [--bump major|minor|patch]
                  [--set X.Y.Z+N] [--build-number N] [--dry-run]

Reads or updates the first top-level version field in pubspec.yaml.
Accepted versions are SemVer core versions with an optional prerelease and a
required nonnegative Flutter/Android build number, for example 1.4.0+27.
EOF
}

ctk_set_action() {
    if [ "$ctk_action" != show ]; then
        ctk_fail "choose only one version action"
    fi
    ctk_action=$1
    ctk_action_value=$2
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
        --show)
            if [ "$ctk_action" != show ]; then
                ctk_fail "choose only one version action"
            fi
            ;;
        --bump|--set|--build-number)
            if [ "$#" -lt 2 ] || [ -z "$2" ]; then
                ctk_fail "$1 requires a value"
            fi
            case $1 in
                --bump)
                    ctk_set_action bump "$2"
                    ;;
                --set)
                    ctk_set_action set "$2"
                    ;;
                --build-number)
                    ctk_set_action build-number "$2"
                    ;;
            esac
            shift
            ;;
        *)
            ctk_fail "unknown option for version: $1. Use --help"
            ;;
    esac
    shift
done

ctk_ensure_flutter_project
ctk_current_version=$(ctk_extract_version pubspec.yaml)
if [ -z "$ctk_current_version" ]; then
    ctk_fail "pubspec.yaml has no version field"
fi
if ! ctk_validate_version "$ctk_current_version"; then
    ctk_fail "pubspec.yaml version is not a supported SemVer plus build number: $ctk_current_version"
fi

if [ "$ctk_action" = show ]; then
    printf 'Version: %s\n' "$ctk_current_version"
    printf '%s\n' 'Result: version read successfully.'
    exit 0
fi

case $ctk_action in
    bump)
        case $ctk_action_value in
            major|minor|patch)
                ;;
            *)
                ctk_fail "bump must be major, minor, or patch"
                ;;
        esac
        ctk_version_components "$ctk_current_version"
        # shellcheck disable=SC2154 # ctk_version_components initializes this value.
        ctk_next_build=$((ctk_component_build + 1))
        case $ctk_action_value in
            major)
                # shellcheck disable=SC2154 # ctk_version_components initializes this value.
                ctk_new_version="$((ctk_component_major + 1)).0.0+$ctk_next_build"
                ;;
            minor)
                # shellcheck disable=SC2154 # ctk_version_components initializes this value.
                ctk_new_version="$ctk_component_major.$((ctk_component_minor + 1)).0+$ctk_next_build"
                ;;
            patch)
                # shellcheck disable=SC2154 # ctk_version_components initializes this value.
                ctk_new_version="$ctk_component_major.$ctk_component_minor.$((ctk_component_patch + 1))+$ctk_next_build"
                ;;
        esac
        ;;
    set)
        ctk_new_version=$ctk_action_value
        if ! ctk_validate_version "$ctk_new_version"; then
            ctk_fail "version must use SemVer plus a nonnegative build number, for example 1.4.0+27"
        fi
        ;;
    build-number)
        if ! ctk_is_nonnegative_integer "$ctk_action_value"; then
            ctk_fail "build number must be a nonnegative integer"
        fi
        ctk_new_version="${ctk_current_version%%+*}+$ctk_action_value"
        ;;
esac

printf 'Current version: %s\n' "$ctk_current_version"
printf 'New version: %s\n' "$ctk_new_version"
ctk_print_run "rewrite pubspec.yaml version field"

if [ "$ctk_dry_run" = true ]; then
    printf '%s\n' 'Result: dry run; pubspec.yaml was not changed.'
    exit 0
fi

ctk_tmp_file="pubspec.yaml.ctk-version-tmp-$$"
if [ -e "$ctk_tmp_file" ]; then
    ctk_fail "temporary version file already exists; remove it and retry"
fi
trap 'rm -f "$ctk_tmp_file"' 0 1 2 3 15

umask 022
if ! awk -v replacement="$ctk_new_version" '
    BEGIN {
        changed = 0
    }
    !changed && $0 ~ /^[[:space:]]*version:[[:space:]]*/ {
        match($0, /^[[:space:]]*version:[[:space:]]*/)
        prefix = substr($0, 1, RLENGTH)
        suffix = substr($0, RLENGTH + 1)
        sub(/^[^[:space:]#]+/, "", suffix)
        print prefix replacement suffix
        changed = 1
        next
    }
    {
        print
    }
    END {
        if (!changed) {
            exit 2
        }
    }
' pubspec.yaml > "$ctk_tmp_file"; then
    ctk_fail "could not prepare an updated pubspec.yaml"
fi

if ! mv "$ctk_tmp_file" pubspec.yaml; then
    ctk_fail "could not replace pubspec.yaml"
fi
printf '%s\n' 'Result: pubspec.yaml version updated successfully.'
