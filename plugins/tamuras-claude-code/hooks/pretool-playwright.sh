#!/usr/bin/env bash
# Hook: PreToolUse (matcher: mcp__playwright__)
# Injeta contexto fechado para Playwright
set -euo pipefail

cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "Contexto FECHADO para Playwright. Regras: (1) Nao navegue para sites nao relacionados ao pedido. (2) Nao queime tokens com screenshots desnecessarios. (3) Foque apenas no que foi pedido. (4) Minimize o numero de acoes de browser."
  }
}
EOF
