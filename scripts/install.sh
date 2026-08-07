#!/usr/bin/env bash
# Install GLOBAL_CLAUDE.md into a target repository as CLAUDE.md.
#
# - Creates directories without deleting unrelated files.
# - Detects an existing target CLAUDE.md and never overwrites it silently.
# - Creates a timestamped backup before any overwrite.
# - Shows a diff/proposal and requires explicit confirmation before writing,
#   unless --yes is passed (still an explicit, informed choice — not automatic).
# - Never installs packages or touches anything outside the target repo.
# - Reports exactly what changed.
#
# Usage:
#   ./install.sh --target-repo /path/to/other/repo [--source-file /path/to/GLOBAL_CLAUDE.md] [--yes]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/../GLOBAL_CLAUDE.md"
TARGET_REPO=""
ASSUME_YES=0

while [ $# -gt 0 ]; do
    case "$1" in
        --target-repo)
            TARGET_REPO="$2"
            shift 2
            ;;
        --source-file)
            SOURCE_FILE="$2"
            shift 2
            ;;
        --yes)
            ASSUME_YES=1
            shift
            ;;
        *)
            echo "Unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

if [ -z "$TARGET_REPO" ]; then
    echo "Usage: $0 --target-repo /path/to/other/repo [--source-file path] [--yes]" >&2
    exit 1
fi

if [ ! -f "$SOURCE_FILE" ]; then
    echo "Source file not found: $SOURCE_FILE. Nothing was changed." >&2
    exit 1
fi

if [ ! -d "$TARGET_REPO" ]; then
    echo "Target repository directory does not exist: $TARGET_REPO. Nothing was changed. (This script creates files inside an existing repository directory; it does not create the repository itself.)" >&2
    exit 1
fi

TARGET_FILE="$TARGET_REPO/CLAUDE.md"

echo "Claude Global Toolkit installer"
echo "  Source: $SOURCE_FILE"
echo "  Target: $TARGET_FILE"
echo ""

BACKUP_PATH=""
if [ -f "$TARGET_FILE" ]; then
    if cmp -s "$SOURCE_FILE" "$TARGET_FILE"; then
        echo "Target CLAUDE.md is already identical to the source. No change needed. Nothing was written."
        exit 0
    fi

    TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
    BACKUP_PATH="$TARGET_FILE.bak.$TIMESTAMP"

    echo "An existing CLAUDE.md was found at the target."
    echo "It will be backed up to: $BACKUP_PATH"
    echo ""
    echo "--- Diff (existing vs. proposed) ---"
    diff -u "$TARGET_FILE" "$SOURCE_FILE" || true
    echo "--- End diff ---"
else
    echo "No existing CLAUDE.md found at the target. This will create a new file; no backup needed."
fi

echo ""

if [ "$ASSUME_YES" -ne 1 ]; then
    read -r -p "Proceed with writing $TARGET_FILE ? [y/N] " REPLY
    case "$REPLY" in
        y|Y|yes|Yes) ;;
        *)
            echo "Aborted by user. Nothing was changed."
            exit 0
            ;;
    esac
fi

if [ -f "$TARGET_FILE" ]; then
    cp -p "$TARGET_FILE" "$BACKUP_PATH"
fi
cp -p "$SOURCE_FILE" "$TARGET_FILE"

echo ""
echo "Done."
if [ -n "$BACKUP_PATH" ]; then
    echo "  Backed up previous CLAUDE.md to: $BACKUP_PATH"
    echo "  Overwrote: $TARGET_FILE"
else
    echo "  Created: $TARGET_FILE"
fi
echo "  No packages were installed. No files outside the target repository were touched."
echo "  Next step (manual, not performed by this script): review $TARGET_FILE in the target repository and adopt the rest of the reusable structure from HOW_TO_USE.md if desired."
