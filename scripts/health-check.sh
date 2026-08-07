#!/usr/bin/env bash
# Mechanical repository health check for the Claude Global Toolkit.
# Read-only. Runs the same fixed set of checks as health-check.ps1 and
# reports pass/fail/skip for each, plus a summary. Never modifies any file.
# Diagnostic only - does not authorize corrective changes on its own.
#
# Checks: required root files present; README.md's structure table matches
# the actual top-level tree; frontmatter version/last_reviewed consistency
# across CLAUDE.md/GLOBAL_CLAUDE.md/PROJECT_CONSTITUTION.md/README.md; no
# empty/near-empty files under content directories; internal Markdown
# cross-references resolve (best-effort - see health-check.ps1's header
# comment for the same documented limitations, which apply here too).
#
# Usage: ./scripts/health-check.sh [repo-root]

set -uo pipefail

REPO_ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PASS=0
FAIL=0
SKIP=0

result() {
    local status="$1" name="$2" detail="${3:-}"
    if [ -n "$detail" ]; then
        echo "[$status] $name - $detail"
    else
        echo "[$status] $name"
    fi
    case "$status" in
        PASS) PASS=$((PASS + 1)) ;;
        FAIL) FAIL=$((FAIL + 1)) ;;
        SKIP) SKIP=$((SKIP + 1)) ;;
    esac
}

echo "Claude Global Toolkit health check"
echo "  Repo root: $REPO_ROOT"
echo ""

# --- Check 1: required root files ---
echo "-- Check 1: required root files --"
required_root_files=(README.md GLOBAL_CLAUDE.md CLAUDE.md PROJECT_CONSTITUTION.md
    PROJECT_CONTEXT.md PROJECT_RULES.md DECISIONS.md PROMPTS.md IDEAS.md
    OPEN_QUESTIONS.md SOURCE_REGISTER.md PROJECT_STATUS.md ROADMAP.md
    CHANGELOG.md HOW_TO_USE.md HOW_TO_BUILD.md)
for f in "${required_root_files[@]}"; do
    if [ -f "$REPO_ROOT/$f" ]; then
        result PASS "root file present: $f"
    else
        result FAIL "root file present: $f" "not found"
    fi
done
echo ""

# --- Check 2: README structure table vs actual tree ---
echo "-- Check 2: README.md structure table vs actual tree --"
README="$REPO_ROOT/README.md"
if [ -f "$README" ]; then
    mapfile -t table_paths < <(grep -oE '^\| `[^`]+` \|' "$README" | sed -E 's/^\| `([^`]+)` \|/\1/' | sed -E 's:/$::')
    if [ "${#table_paths[@]}" -eq 0 ]; then
        result FAIL "README structure table parsed" "no \`path\` rows found - table format may have changed"
    else
        result PASS "README structure table parsed" "${#table_paths[@]} entries"
        for tp in "${table_paths[@]}"; do
            if [ -e "$REPO_ROOT/$tp" ]; then
                result PASS "table entry exists on disk: $tp"
            else
                result FAIL "table entry exists on disk: $tp" "listed in README.md but not found"
            fi
        done
        for item in "$REPO_ROOT"/*; do
            name="$(basename "$item")"
            [ "$name" = "README.md" ] && continue
            found=0
            for tp in "${table_paths[@]}"; do
                [ "$tp" = "$name" ] && found=1 && break
            done
            if [ "$found" -eq 0 ]; then
                result FAIL "top-level item documented: $name" "exists on disk but not listed in README.md's structure table"
            fi
        done
    fi
else
    result SKIP "README.md structure table" "README.md not found"
fi
echo ""

# --- Check 3: frontmatter version/last_reviewed consistency ---
echo "-- Check 3: frontmatter version/last_reviewed consistency --"
declare -A vers reviewed
for f in CLAUDE.md GLOBAL_CLAUDE.md PROJECT_CONSTITUTION.md; do
    p="$REPO_ROOT/$f"
    if [ ! -f "$p" ]; then
        result SKIP "frontmatter readable: $f" "file not found"
        continue
    fi
    v="$(grep -m1 -E '^version:' "$p" | sed -E 's/^version:[[:space:]]*//')"
    r="$(grep -m1 -E '^last_reviewed:' "$p" | sed -E 's/^last_reviewed:[[:space:]]*//')"
    if [ -n "$v" ] && [ -n "$r" ]; then
        vers[$f]="$v"; reviewed[$f]="$r"
        result PASS "frontmatter readable: $f" "version=$v last_reviewed=$r"
    else
        result FAIL "frontmatter readable: $f" "missing version and/or last_reviewed frontmatter field"
    fi
done
if [ -f "$README" ]; then
    # Match version and last-reviewed independently rather than via a single
    # pattern spanning the "." separator character - that separator is a
    # multi-byte UTF-8 character (middle dot, U+00B7) and a negated
    # character class containing it is locale-sensitive in grep -E, which
    # broke this check under some locales despite working in PowerShell.
    rv="$(grep -oE 'Toolkit version:[[:space:]]*[0-9.]+' "$README" | head -1 | sed -E 's/.*:[[:space:]]*//')"
    rr="$(grep -oE 'Last reviewed:[[:space:]]*[0-9-]+' "$README" | head -1 | sed -E 's/.*:[[:space:]]*//')"
    if [ -n "$rv" ] && [ -n "$rr" ]; then
        vers[README.md]="$rv"; reviewed[README.md]="$rr"
        result PASS "version line readable: README.md" "version=$rv last_reviewed=$rr"
    else
        result FAIL "version line readable: README.md" "'Toolkit version: X . Last reviewed: Y' line not found or format changed"
    fi
fi
if [ "${#vers[@]}" -gt 1 ]; then
    distinct_v=$(printf '%s\n' "${vers[@]}" | sort -u | wc -l)
    distinct_r=$(printf '%s\n' "${reviewed[@]}" | sort -u | wc -l)
    if [ "$distinct_v" -eq 1 ] && [ "$distinct_r" -eq 1 ]; then
        result PASS "versions consistent across all files" "all at ${vers[CLAUDE.md]:-?}"
    else
        detail=""
        for k in "${!vers[@]}"; do detail="$detail $k=${vers[$k]}/${reviewed[$k]};"; done
        result FAIL "versions consistent across all files" "mismatch found:$detail"
    fi
fi
echo ""

# --- Check 4: no empty/near-empty files in content directories ---
echo "-- Check 4: no empty or near-empty planned deliverables --"
for dir in chapters prompts templates checklists reviews summaries session_logs; do
    dirpath="$REPO_ROOT/$dir"
    if [ ! -d "$dirpath" ]; then
        result SKIP "directory scanned: $dir" "not found"
        continue
    fi
    while IFS= read -r -d '' file; do
        rel="${file#$REPO_ROOT/}"
        nonblank=$(grep -cve '^[[:space:]]*$' "$file")
        if [ "$nonblank" -lt 3 ]; then
            result FAIL "non-empty: $rel" "only $nonblank non-blank line(s)"
        else
            result PASS "non-empty: $rel"
        fi
    done < <(find "$dirpath" -maxdepth 1 -name "*.md" -type f -print0)
done
echo ""

# --- Check 5: internal cross-references resolve (best-effort) ---
echo "-- Check 5: internal Markdown cross-references resolve (best-effort) --"
mapfile -t top_level_dirs < <(find "$REPO_ROOT" -maxdepth 1 -mindepth 1 -type d ! -name ".git" -printf '%f\n')
mapfile -t all_md_files < <(find "$REPO_ROOT" -name "*.md" -type f -not -path '*/.git/*')

is_top_level_dir() {
    local needle="$1"
    for d in "${top_level_dirs[@]}"; do [ "$d" = "$needle" ] && return 0; done
    return 1
}

# Precompute basenames once (pure bash parameter expansion, no subprocess)
# instead of shelling out to basename(1) inside a loop per lookup - that
# was the actual cause of this script taking minutes on Windows Git Bash,
# where each subprocess spawn has significant overhead: with ~74 files and
# dozens of bare-filename references, the naive per-lookup version called
# basename thousands of times.
declare -A basename_set
for f in "${all_md_files[@]}"; do
    basename_set["${f##*/}"]=1
done
basename_exists() {
    [ -n "${basename_set[$1]+x}" ]
}

checked=0
broken=0
for file in "${all_md_files[@]}"; do
    fdir="$(dirname "$file")"
    rel_source="${file#$REPO_ROOT/}"
    # Extract backtick- and markdown-link-quoted *.md references
    refs=$(grep -oE '`[A-Za-z0-9_][A-Za-z0-9_./\\-]*\.md`|\]\([A-Za-z0-9_][A-Za-z0-9_./\\-]*\.md\)' "$file" | \
        sed -E 's/^`(.*)`$/\1/; s/^\]\((.*)\)$/\1/')
    [ -z "$refs" ] && continue
    while IFS= read -r ref; do
        [ -z "$ref" ] && continue
        case "$ref" in *YYYY*|*NN*|*'<'*|*'>'*|*'...'*) continue ;; esac
        checked=$((checked + 1))
        if [[ "$ref" == */* ]]; then
            first_seg="${ref%%/*}"
            if ! is_top_level_dir "$first_seg"; then
                checked=$((checked - 1))
                continue
            fi
            if [ -e "$fdir/$ref" ] || [ -e "$REPO_ROOT/$ref" ]; then
                : # resolved
            else
                broken=$((broken + 1))
                result FAIL "cross-reference resolves" "'$ref' referenced in $rel_source does not resolve"
            fi
        else
            if ! basename_exists "$ref"; then
                broken=$((broken + 1))
                result FAIL "cross-reference resolves" "'$ref' referenced in $rel_source does not resolve"
            fi
        fi
    done <<< "$refs"
done
if [ "$checked" -gt 0 ] && [ "$broken" -eq 0 ]; then
    result PASS "all $checked checked cross-references resolve"
elif [ "$checked" -eq 0 ]; then
    result SKIP "cross-reference scan" "no matching references found - regex may need adjustment"
fi
echo ""

echo "== Summary =="
echo "  Pass: $PASS"
echo "  Fail: $FAIL"
echo "  Skip: $SKIP"
echo ""
echo "This check is diagnostic only. It does not authorize corrective"
echo "changes on its own - review findings and apply this repository's"
echo "own approval rules before acting on them."

[ "$FAIL" -eq 0 ]
