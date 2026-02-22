#!/usr/bin/env bash
# Hook: SubagentStart
# Injeta contexto + foca Explore
set -euo pipefail

PROJECT_ROOT="${PWD}"
INPUT=$(cat)

AGENT_TYPE=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('agent_type', data.get('subagent_type', '')))
" 2>/dev/null || echo "")

# Montar contexto
CONTEXT=""

# CLAUDE.md resumido
if [[ -f "${PROJECT_ROOT}/CLAUDE.md" ]]; then
  CONTEXT+="=== CLAUDE.md (resumo) ==="$'\n'
  CONTEXT+=$(head -50 "${PROJECT_ROOT}/CLAUDE.md")
  CONTEXT+=$'\n\n'
fi

# Lista de docs
if [[ -d "${PROJECT_ROOT}/docs" ]]; then
  DOCS_LIST=$(find "${PROJECT_ROOT}/docs" -type f 2>/dev/null | sort | sed "s|${PROJECT_ROOT}/||")
  if [[ -n "$DOCS_LIST" ]]; then
    CONTEXT+="=== Docs disponiveis ==="$'\n'
    CONTEXT+="${DOCS_LIST}"$'\n\n'
  fi
fi

# Lista de audits
if [[ -d "${PROJECT_ROOT}/audits" ]]; then
  AUDITS_LIST=$(find "${PROJECT_ROOT}/audits" -type f 2>/dev/null | sort | sed "s|${PROJECT_ROOT}/||")
  if [[ -n "$AUDITS_LIST" ]]; then
    CONTEXT+="=== Audits disponiveis ==="$'\n'
    CONTEXT+="${AUDITS_LIST}"$'\n\n'
  fi
fi

# Ultimos 2 commits
if git rev-parse --is-inside-work-tree &>/dev/null; then
  CONTEXT+="=== Ultimos commits ==="$'\n'
  CONTEXT+=$(git log -2 --oneline 2>/dev/null || echo "(vazio)")
  CONTEXT+=$'\n\n'
fi

# Se Explore, adicionar instrucao de foco
if [[ "$AGENT_TYPE" == "Explore" ]]; then
  CONTEXT+="*** FOQUE no pedido especifico. NAO explore o projeto inteiro. Use o contexto injetado como base. ***"$'\n'
fi

ESCAPED_CONTEXT=$(echo "$CONTEXT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")

cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": ${ESCAPED_CONTEXT}
  }
}
EOF
