#!/bin/sh
# Best-effort file-local formatting after Claude Code Write/Edit operations.
set -eu

payload=$(cat)
project_dir=${CLAUDE_PROJECT_DIR:-$(pwd)}

extract_path() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$payload" |
      jq -r '.. | objects | .file_path? // empty' 2>/dev/null |
      sed -n '1p' || :
  else
    printf '%s\n' "$payload" |
      sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' |
      sed -n '1p'
  fi
}

file=$(extract_path)
[ -n "$file" ] || exit 0

case "$file" in
  /*) target=$file ;;
  *) target=$project_dir/$file ;;
esac

[ -f "$target" ] || exit 0

case "$target" in
  *.dart)
    if command -v dart >/dev/null 2>&1; then
      dart format "$target" >/dev/null 2>&1 || :
    fi
    ;;
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs)
    if [ -x "$project_dir/node_modules/.bin/prettier" ]; then
      "$project_dir/node_modules/.bin/prettier" --write "$target" >/dev/null 2>&1 || :
    elif command -v prettier >/dev/null 2>&1; then
      prettier --write "$target" >/dev/null 2>&1 || :
    fi
    ;;
  *.py)
    if [ -x "$project_dir/.venv/bin/ruff" ]; then
      "$project_dir/.venv/bin/ruff" format "$target" >/dev/null 2>&1 || :
    elif command -v ruff >/dev/null 2>&1; then
      ruff format "$target" >/dev/null 2>&1 || :
    elif [ -x "$project_dir/.venv/bin/black" ]; then
      "$project_dir/.venv/bin/black" "$target" >/dev/null 2>&1 || :
    elif command -v black >/dev/null 2>&1; then
      black "$target" >/dev/null 2>&1 || :
    fi
    ;;
esac

exit 0
