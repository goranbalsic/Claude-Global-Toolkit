#!/bin/sh
set -eu

ctk_dir=$(CDPATH='' cd "$(dirname "$0")" && pwd)
# shellcheck source=common.inc
# shellcheck disable=SC1091 # common.inc is resolved dynamically from ctk_dir.
. "$ctk_dir/common.inc"

ctk_dry_run=false
ctk_failed=0

ctk_help() {
    cat <<'EOF'
Usage: doctor.sh [--dry-run]

Runs flutter doctor and checks the JDK, Android SDK, Gradle wrapper, and safe
release-signing configuration. It never displays signing-property values.
EOF
}

ctk_check_pass() {
    printf 'Check: %s: PASS\n' "$1"
}

ctk_check_fail() {
    printf 'Check: %s: FAIL - %s\n' "$1" "$2" >&2
    ctk_failed=1
}

ctk_key_property() {
    awk -v wanted="$2" '
        /^[[:space:]]*#/ {
            next
        }
        {
            line = $0
            sub(/^[[:space:]]*/, "", line)
            separator = index(line, "=")
            if (separator == 0) {
                next
            }
            key = substr(line, 1, separator - 1)
            value = substr(line, separator + 1)
            sub(/[[:space:]]*$/, "", key)
            if (key == wanted) {
                print value
                exit
            }
        }
    ' "$1"
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
            ctk_fail "unknown option for doctor: $1. Use --help"
            ;;
    esac
    shift
done

ctk_ensure_flutter_project

if command -v flutter >/dev/null 2>&1; then
    ctk_print_run flutter doctor
    if [ "$ctk_dry_run" = true ]; then
        printf '%s\n' 'Check: Flutter: dry run; flutter doctor was not invoked.'
    elif flutter doctor; then
        ctk_check_pass "Flutter"
    else
        ctk_status=$?
        ctk_check_fail "Flutter" "flutter doctor exited with status $ctk_status"
    fi
else
    ctk_check_fail "Flutter" "flutter command is unavailable"
fi

if command -v java >/dev/null 2>&1; then
    ctk_print_run java -version
    if [ "$ctk_dry_run" = true ]; then
        printf '%s\n' 'Check: JDK: dry run; java -version was not invoked.'
    elif java -version; then
        ctk_check_pass "JDK"
    else
        ctk_status=$?
        ctk_check_fail "JDK" "java -version exited with status $ctk_status"
    fi
else
    ctk_check_fail "JDK" "java command is unavailable"
fi

ctk_android_sdk=${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}
if [ -z "$ctk_android_sdk" ] && [ -f android/local.properties ]; then
    ctk_android_sdk=$(awk '
        /^[[:space:]]*sdk[.]dir[[:space:]]*=/ {
            value = $0
            sub(/^[[:space:]]*sdk[.]dir[[:space:]]*=/, "", value)
            print value
            exit
        }
    ' android/local.properties)
fi
if [ -n "$ctk_android_sdk" ] && [ -d "$ctk_android_sdk" ]; then
    ctk_check_pass "Android SDK"
else
    ctk_check_fail "Android SDK" "set ANDROID_SDK_ROOT or provide a valid android/local.properties sdk.dir"
fi

if [ -f android/gradlew ] && [ -f android/gradle/wrapper/gradle-wrapper.properties ]; then
    ctk_check_pass "Gradle wrapper"
else
    ctk_check_fail "Gradle wrapper" "android/gradlew or its wrapper properties are missing"
fi

ctk_gradle_file=$(ctk_gradle_build_file || true)
if [ -z "$ctk_gradle_file" ]; then
    ctk_check_fail "release signing" "android/app/build.gradle or build.gradle.kts is missing"
elif ctk_has_inline_signing_secret; then
    ctk_check_fail "release signing" "Gradle appears to contain a signing password literal"
elif grep -Eiq 'signingConfig[^#]*(debug|Debug)' "$ctk_gradle_file"; then
    ctk_check_fail "release signing" "release configuration explicitly uses debug signing"
elif ! grep -Eq 'signingConfig' "$ctk_gradle_file"; then
    ctk_check_fail "release signing" "no signing configuration is referenced"
elif grep -Eq 'key[.]properties' "$ctk_gradle_file"; then
    ctk_key_properties=android/key.properties
    if [ ! -r "$ctk_key_properties" ]; then
        ctk_check_fail "release signing" "local key.properties is referenced but unavailable"
    else
        ctk_missing_key=
        for ctk_required_key in storeFile storePassword keyAlias keyPassword; do
            if [ -z "$(ctk_key_property "$ctk_key_properties" "$ctk_required_key")" ]; then
                ctk_missing_key=$ctk_required_key
                break
            fi
        done
        if [ -n "$ctk_missing_key" ]; then
            ctk_check_fail "release signing" "local key.properties is missing a required key"
        else
            ctk_store_file=$(ctk_key_property "$ctk_key_properties" storeFile)
            if [ -f "$ctk_store_file" ] || [ -f "android/$ctk_store_file" ]; then
                ctk_check_pass "release signing"
            else
                ctk_check_fail "release signing" "configured keystore file is unavailable"
            fi
        fi
    fi
elif grep -Eq 'System[.]getenv|System.getenv|environmentVariable' "$ctk_gradle_file"; then
    printf '%s\n' 'Check: release signing: PASS - environment-backed configuration detected; values were not inspected.'
else
    ctk_check_fail "release signing" "signing is present but not resolvable from local properties or environment"
fi

if [ "$ctk_failed" -ne 0 ]; then
    printf '%s\n' 'Result: doctor found unavailable or incomplete prerequisites.' >&2
    exit 1
fi
printf '%s\n' 'Result: doctor checks passed.'
