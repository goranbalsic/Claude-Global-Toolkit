#!/bin/sh
# Global SessionStart router, registered once by `ctk bootstrap` into
# ~/.claude/settings.json. Runs on every Claude Code session, in every
# project, so it stays tiny and silent unless there is something to report.
#
# It never stages files itself and never duplicates install/update logic: for
# an already CTK-managed project it defers entirely to the tested
# `ctk update --session-sync`. For a first-time project it only prints a
# one-line approval signal (or, if auto_apply_managed_ctk=true was explicitly
# set at bootstrap, runs the ordinary `ctk install`) and never invents a
# second write path of its own.
set -eu

home_base=${CTK_HOME:-${HOME:-}}
[ -n "$home_base" ] || exit 0
registration=$home_base/.claude/ctk/registration.txt
[ -f "$registration" ] || exit 0

root=$(awk -F '\t' '$1 == "root" { print $2; exit }' "$registration" 2>/dev/null || true)
auto_apply=$(awk -F '\t' '$1 == "auto_apply_managed_ctk" { print $2; exit }' "$registration" 2>/dev/null || true)
[ -n "$root" ] || exit 0

ctk_script=$root/bin/ctk
if [ ! -f "$ctk_script" ] || [ ! -f "$root/core/CLAUDE.core.md" ]; then
    printf '%s\n' "CTK: registered checkout is missing or moved ($root); run bootstrap again once it is available."
    exit 0
fi

project_dir=${CLAUDE_PROJECT_DIR:-}
[ -n "$project_dir" ] || exit 0
[ -d "$project_dir" ] || exit 0
cd "$project_dir" 2>/dev/null || exit 0

detect_profile() {
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
                [ -f "$project_dir/$rule_file" ] && grep -F "$rule_text" "$project_dir/$rule_file" >/dev/null 2>&1 && profile=full
                ;;
            *' exists')
                rule_file=${rule% exists}
                [ -e "$project_dir/$rule_file" ] && profile=full
                ;;
        esac
    done
    printf '%s\n' "$profile"
}

claude_md=$project_dir/CLAUDE.md
has_block=0
if [ -f "$claude_md" ] && grep -q '^<!-- ctk:begin v=' "$claude_md" 2>/dev/null; then
    has_block=1
fi

if [ "$has_block" -eq 0 ]; then
    # No managed block: only speak up for something that looks like a real,
    # git-tracked project. A random directory stays completely silent.
    [ -d "$project_dir/.git" ] || exit 0
    profile=$(detect_profile)
    if [ "$auto_apply" = true ]; then
        if sh "$ctk_script" install --profile "$profile" --target "$project_dir" --yes >/dev/null 2>&1; then
            printf '%s\n' "CTK: installed ($profile profile) under auto_apply_managed_ctk; restart once to pick up new slash commands."
        else
            printf '%s\n' "CTK: auto_apply install failed for this project; run 'ctk doctor --target $project_dir' to inspect."
        fi
    else
        printf '%s\n' "CTK: setup available for this project ($profile profile); approval required before CTK-managed files are added."
    fi
    exit 0
fi

sync_output=$(sh "$ctk_script" update --session-sync --target "$project_dir" --yes 2>&1) && sync_code=0 || sync_code=$?
case $sync_code in
    0) printf '%s\n' "$sync_output" | tail -n 1 ;;
    11) printf '%s\n' 'CTK: locally modified managed file detected; sync skipped, nothing overwritten. Run "ctk doctor" for detail.' ;;
    12) printf '%s\n' 'CTK: unrecognized or legacy CTK state in this project; run "ctk doctor" then resolve manually.' ;;
    14) printf '%s\n' 'CTK: sync applied but the health check failed; a backup was preserved. Run "ctk doctor" to inspect.' ;;
    10) printf '%s\n' 'CTK: setup available for this project; approval required before CTK-managed files are added.' ;;
    *) printf '%s\n' "CTK: session sync check failed (exit $sync_code); run 'ctk doctor --target $project_dir'." ;;
esac
exit 0
