#!/bin/sh
# Thin resolver + invoker for CTK's GLOBAL Claude Code slash commands
# (/ctk:install, /ctk:update, /ctk:doctor, /ctk:status, /ctk:resume,
# /ctk:checkpoint, /ctk:goal, /ctk:refine).
#
# Installed by `ctk bootstrap` to $CTK_HOME/.claude/ctk/global-router.sh (or
# $HOME/.claude/ctk/global-router.sh). Re-copied verbatim on every bootstrap;
# never edited in place, never staged into a project.
#
# It never re-implements install/update/doctor/status lifecycle behavior:
# for every command except `detect-profile` it only resolves the registered
# CTK root from registration.txt and execs the real CTK CLI at its absolute
# path -- bin/ctk.ps1 through a process-only PowerShell execution-policy
# bypass on Windows, bin/ctk through sh everywhere else. It never relies on
# PATH and never requires any project-local CTK files to already exist.
set -eu

home_base=${CTK_HOME:-${HOME:-}}
if [ -z "$home_base" ]; then
    printf '%s\n' "CTK: HOME is not set; cannot resolve CTK registration." >&2
    exit 1
fi
registration="$home_base/.claude/ctk/registration.txt"
if [ ! -f "$registration" ]; then
    printf '%s\n' "CTK: not bootstrapped yet (missing $registration). Run 'ctk bootstrap' from a CTK checkout, then restart Claude Code." >&2
    exit 1
fi

root=$(awk -F '\t' '$1 == "root" { print $2; exit }' "$registration" 2>/dev/null || true)
if [ -z "$root" ]; then
    printf '%s\n' "CTK: registration file has no root entry: $registration" >&2
    exit 1
fi

is_windows() {
    case "$(uname -s 2>/dev/null || true)" in
        MINGW*|MSYS*|CYGWIN*) return 0 ;;
        *) return 1 ;;
    esac
}

if is_windows; then
    ctk_script="$root/bin/ctk.ps1"
else
    ctk_script="$root/bin/ctk"
fi
if [ ! -f "$ctk_script" ]; then
    printf '%s\n' "CTK: registered checkout is missing or moved ($root); run 'ctk bootstrap' again once it is available." >&2
    exit 1
fi

# detect-profile is the one piece of logic this router owns outright: it has
# no CLI counterpart (ctk install takes --profile as an already-decided
# value), and duplicating it into every global command template would be
# exactly the reimplemented-lifecycle-behavior the design forbids. It mirrors
# router/session-sync-router.sh's own detection so a manual /ctk:install
# suggests the same profile the automatic first-install path would have used.
if [ "${1:-}" = 'detect-profile' ]; then
    shift
    target=''
    while [ $# -gt 0 ]; do
        case $1 in
            --target) target=$2; shift 2 ;;
            *) shift ;;
        esac
    done
    [ -n "$target" ] || target=$(pwd)
    profile=standard
    for module_file in "$root"/modules/*/module.md; do
        [ -f "$module_file" ] || continue
        rule=$(awk '
            /^detect:[[:space:]]*/ {
                sub(/^detect:[[:space:]]*/, "")
                sub(/[[:space:]]+$/, "")
                if (substr($0, 1, 1) == "\"" && substr($0, length($0), 1) == "\"") { $0 = substr($0, 2, length($0) - 2) }
                print
                exit
            }
        ' "$module_file")
        [ -n "$rule" ] || continue
        case $rule in
            *' contains '*)
                rule_file=${rule%% contains *}
                rule_text=${rule#* contains }
                [ -f "$target/$rule_file" ] && grep -F "$rule_text" "$target/$rule_file" >/dev/null 2>&1 && profile=full
                ;;
            *' exists')
                rule_file=${rule% exists}
                [ -e "$target/$rule_file" ] && profile=full
                ;;
        esac
    done
    printf '%s\n' "$profile"
    exit 0
fi

if is_windows; then
    exec powershell -NoProfile -ExecutionPolicy Bypass -File "$ctk_script" "$@"
else
    exec sh "$ctk_script" "$@"
fi
