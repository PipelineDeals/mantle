#!/bin/bash
# protect-sensitive-files.sh
#
# PreToolUse hook — blocks edits to sensitive files.
# Receives JSON on stdin with tool_input.file_path.
# Exit 0 = allow, Exit 2 = block (stderr shown to Claude).

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [ -z "$file_path" ]; then
  exit 0
fi

basename=$(basename "$file_path")
dirpath=$(dirname "$file_path")

# Block sensitive files
case "$basename" in
  .env|.env.*|.env.local|.env.production|.env.staging)
    echo "BLOCKED: Will not edit environment file: $file_path" >&2
    exit 2
    ;;
  credentials.json|secrets.json|secrets.yml|secrets.yaml)
    echo "BLOCKED: Will not edit credentials file: $file_path" >&2
    exit 2
    ;;
  *.pem|*.key|*.p12|*.pfx|id_rsa|id_ed25519)
    echo "BLOCKED: Will not edit key/certificate file: $file_path" >&2
    exit 2
    ;;
  master.key|credentials.yml.enc)
    echo "BLOCKED: Will not edit Rails encrypted credentials: $file_path" >&2
    exit 2
    ;;
esac

exit 0
