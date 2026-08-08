#!/bin/sh
# Block Claude Code Write/Edit operations targeting common secret-bearing paths.
set -eu

payload=$(cat)

extract_paths() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$payload" |
      jq -r '.. | objects | .file_path? // empty' 2>/dev/null || :
  else
    printf '%s\n' "$payload" |
      sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
  fi
}

blocked_path=''
while IFS= read -r path; do
  [ -n "$path" ] || continue
  normalized=$(printf '%s' "$path" | sed 's|\\|/|g')
  case "$normalized" in
    *.keystore|*.jks|*.p12|*.pem|key.properties|*/key.properties|.env|.env.*|*/.env|*/.env.*|google-services.json|*/google-services.json|*serviceAccount*.json)
      blocked_path=$normalized
      break
      ;;
  esac
done <<EOF
$(extract_paths)
EOF

if [ -n "$blocked_path" ]; then
  printf '%s\n' "ctk: blocked Write/Edit for secret-bearing path: $blocked_path" >&2
  printf '%s\n' 'Use an approved secret-management workflow; do not edit signing keys, credentials, or environment files through Claude Code.' >&2
  exit 2
fi

exit 0
