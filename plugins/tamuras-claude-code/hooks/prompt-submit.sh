#!/usr/bin/env bash
# Hook: UserPromptSubmit
# Injeta lembrete de contexto disponivel antes do Claude processar
set -euo pipefail

PROJECT_ROOT="${PWD}"
USER_PROMPT="${CLAUDE_USER_PROMPT:-}"

# Montar contexto adicional
CONTEXT=""
CONTEXT+="LEMBRETE: VOCE JA TEM CONTEXTO INJETADO NO SessionStart. Consulte CLAUDE.md, README.md, docs/*, audits/* ANTES de explorar o codebase."
CONTEXT+=$'\n\n'

# Listar docs disponiveis
if [[ -d "${PROJECT_ROOT}/docs" ]]; then
  CONTEXT+="Docs disponiveis:"$'\n'
  find "${PROJECT_ROOT}/docs" -type f | sort | while read -r f; do
    echo "  - ${f#${PROJECT_ROOT}/}"
  done | while read -r line; do CONTEXT+="${line}"$'\n'; done
  # Fallback: usar subshell
  DOCS_LIST=$(find "${PROJECT_ROOT}/docs" -type f 2>/dev/null | sort | sed "s|${PROJECT_ROOT}/|  - |")
  if [[ -n "$DOCS_LIST" ]]; then
    CONTEXT+="${DOCS_LIST}"$'\n'
  fi
fi

# Listar audits disponiveis
if [[ -d "${PROJECT_ROOT}/audits" ]]; then
  AUDITS_LIST=$(find "${PROJECT_ROOT}/audits" -type f 2>/dev/null | sort | sed "s|${PROJECT_ROOT}/|  - |")
  if [[ -n "$AUDITS_LIST" ]]; then
    CONTEXT+=$'\n'"Audits disponiveis:"$'\n'
    CONTEXT+="${AUDITS_LIST}"$'\n'
  fi
fi

# Resumo de CLAUDE.md (primeiras 50 linhas)
if [[ -f "${PROJECT_ROOT}/CLAUDE.md" ]]; then
  CONTEXT+=$'\n'"CLAUDE.md (resumo):"$'\n'
  CONTEXT+=$(head -50 "${PROJECT_ROOT}/CLAUDE.md")
  CONTEXT+=$'\n'
fi

# Detectar palavras de exploracao para enfase extra
EXPLORE_PATTERN="explorar|explore|estrutura|onde fica|como funciona|entender|mapear|planejar|planeje"
if echo "$USER_PROMPT" | grep -qiE "$EXPLORE_PATTERN"; then
  CONTEXT+=$'\n'"*** ATENCAO: USE O CONTEXTO JA DISPONIVEL. So explore se REALMENTE necessario apos consultar docs e audits injetados. ***"$'\n'
fi

# Output JSON
ESCAPED_CONTEXT=$(echo "$CONTEXT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")

cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": ${ESCAPED_CONTEXT}
  }
}
EOF
