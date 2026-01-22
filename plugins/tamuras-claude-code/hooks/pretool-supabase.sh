#!/bin/bash
# Hook: PreToolUse - Injeta regras antes de chamadas mcp__supabase__*
# Matcher: mcp__supabase__

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cat "$SCRIPT_DIR/pretool-supabase.md"
