#!/bin/sh
# Print a bounded, deterministic orientation digest for Claude Code sessions.
set -eu

project_dir=${CLAUDE_PROJECT_DIR:-$(pwd)}

if ! cd "$project_dir" 2>/dev/null; then
  exit 0
fi

printf '%s\n' 'ctk session digest'

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git branch --show-current 2>/dev/null || printf '%s' 'detached')
  [ -n "$branch" ] || branch='detached'
  printf 'branch: %s\n' "$branch"
  printf '%s\n' 'status (first 20):'
  git status --short 2>/dev/null | sed -n '1,20p' | cut -c1-240 || :
else
  printf '%s\n' 'git: unavailable or not a work tree'
fi

if [ -f .claude/ctk/STATE.md ]; then
  printf '%s\n' 'state (last 24 lines):'
  tail -n 24 .claude/ctk/STATE.md 2>/dev/null | cut -c1-240 || :
else
  printf '%s\n' 'state: none'
fi
