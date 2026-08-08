# Shared POSIX-shell helpers for the Flutter Android module.

ctk_fail() {
    printf '%s\n' "Error: $*" >&2
    exit 1
}

ctk_unavailable() {
    printf '%s\n' "Unavailable: $*." >&2
    exit 127
}

ctk_require_tool() {
    if ! command -v "$1" >/dev/null 2>&1; then
        ctk_unavailable "$1 command was not found; install or activate it before running this command"
    fi
}

ctk_print_run() {
    printf '%s' 'Run:'
    for ctk_run_arg do
        printf ' %s' "$ctk_run_arg"
    done
    printf '\n'
}

ctk_ensure_flutter_project() {
    if [ ! -f pubspec.yaml ]; then
        ctk_fail "not a Flutter project root: pubspec.yaml is missing. Run this command from the application root"
    fi

    if ! grep -Eq '^[[:space:]]*flutter:[[:space:]]*(#.*)?$' pubspec.yaml; then
        ctk_fail "not a Flutter project root: pubspec.yaml has no top-level flutter: section"
    fi
}

ctk_ensure_git_repository() {
    ctk_require_tool git
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        ctk_fail "this command requires a Git working tree"
    fi
}

ctk_is_positive_integer() {
    case $1 in
        ''|*[!0-9]*)
            return 1
            ;;
        *)
            [ "$1" -gt 0 ]
            ;;
    esac
}

ctk_is_nonnegative_integer() {
    case $1 in
        ''|*[!0-9]*)
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

ctk_extract_version() {
    awk '
        /^[[:space:]]*version:[[:space:]]*/ {
            value = $0
            sub(/^[[:space:]]*version:[[:space:]]*/, "", value)
            sub(/[[:space:]]*#.*/, "", value)
            print value
            exit
        }
    ' "$1"
}

ctk_validate_version() {
    printf '%s\n' "$1" |
        grep -Eq '^(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)[.](0|[1-9][0-9]*)(-[0-9A-Za-z][0-9A-Za-z.-]*)?[+](0|[1-9][0-9]*)$'
}

ctk_version_components() {
    ctk_component_semver=${1%%+*}
    ctk_component_build=${1#*+}
    ctk_component_core=${ctk_component_semver%%-*}
    ctk_component_major=${ctk_component_core%%.*}
    ctk_component_rest=${ctk_component_core#*.}
    ctk_component_minor=${ctk_component_rest%%.*}
    ctk_component_patch=${ctk_component_rest#*.}
}

ctk_version_is_bumped() {
    ctk_version_components "$1"
    ctk_current_major=$ctk_component_major
    ctk_current_minor=$ctk_component_minor
    ctk_current_patch=$ctk_component_patch
    ctk_current_build=$ctk_component_build

    ctk_version_components "$2"
    ctk_base_major=$ctk_component_major
    ctk_base_minor=$ctk_component_minor
    ctk_base_patch=$ctk_component_patch
    ctk_base_build=$ctk_component_build

    if [ "$ctk_current_major" -gt "$ctk_base_major" ]; then
        return 0
    fi
    if [ "$ctk_current_major" -lt "$ctk_base_major" ]; then
        return 1
    fi
    if [ "$ctk_current_minor" -gt "$ctk_base_minor" ]; then
        return 0
    fi
    if [ "$ctk_current_minor" -lt "$ctk_base_minor" ]; then
        return 1
    fi
    if [ "$ctk_current_patch" -gt "$ctk_base_patch" ]; then
        return 0
    fi
    if [ "$ctk_current_patch" -lt "$ctk_base_patch" ]; then
        return 1
    fi
    [ "$ctk_current_build" -gt "$ctk_base_build" ]
}

ctk_gradle_build_file() {
    if [ -f android/app/build.gradle.kts ]; then
        printf '%s\n' 'android/app/build.gradle.kts'
        return 0
    fi
    if [ -f android/app/build.gradle ]; then
        printf '%s\n' 'android/app/build.gradle'
        return 0
    fi
    return 1
}

ctk_has_safe_release_signing_config() {
    ctk_signing_gradle_file=$(ctk_gradle_build_file) || return 1

    if ! grep -Eq 'signingConfig' "$ctk_signing_gradle_file"; then
        return 1
    fi

    if grep -Eiq 'signingConfig[^#]*(debug|Debug)' "$ctk_signing_gradle_file"; then
        return 1
    fi

    grep -Eq 'key[.]properties|System[.]getenv|System.getenv|environmentVariable|storeFile' "$ctk_signing_gradle_file"
}

ctk_has_inline_signing_secret() {
    ctk_inline_secret_gradle_file=$(ctk_gradle_build_file) || return 1
    grep -Eiq "(storePassword|keyPassword)[[:space:]]*(=|[[:space:]])[[:space:]]*[\"']" \
        "$ctk_inline_secret_gradle_file"
}

ctk_report_artifacts() {
    ctk_artifact_pattern=$1
    ctk_artifact_directory=$2

    if [ ! -d "$ctk_artifact_directory" ]; then
        return 1
    fi

    ctk_artifacts=$(find "$ctk_artifact_directory" -type f -name "$ctk_artifact_pattern" -print)
    if [ -z "$ctk_artifacts" ]; then
        return 1
    fi

    printf '%s\n' "$ctk_artifacts" |
        while IFS= read -r ctk_artifact; do
            ctk_artifact_bytes=$(wc -c < "$ctk_artifact" | tr -d '[:space:]')
            ctk_artifact_mib=$(awk -v bytes="$ctk_artifact_bytes" 'BEGIN { printf "%.2f", bytes / 1048576 }')
            printf 'Artifact: %s (%s bytes, %s MiB)\n' \
                "$ctk_artifact" "$ctk_artifact_bytes" "$ctk_artifact_mib"
        done
}

ctk_script_dir() {
    CDPATH='' cd "$(dirname "$0")" && pwd
}
