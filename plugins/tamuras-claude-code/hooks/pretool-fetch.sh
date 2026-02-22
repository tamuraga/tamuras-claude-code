#!/usr/bin/env bash
# Hook: PreToolUse (matcher: WebFetch|WebSearch)
# Injeta data atual nas buscas web
set -euo pipefail

CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S %Z")
CURRENT_YEAR=$(date "+%Y")

cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "Data atual: ${CURRENT_DATE}. Use ANO ATUAL (${CURRENT_YEAR}) nas buscas. Nao use anos anteriores para documentacao ou informacoes recentes."
  }
}
EOF
