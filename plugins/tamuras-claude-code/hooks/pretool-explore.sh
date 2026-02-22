#!/usr/bin/env bash
# Hook: PreToolUse (matcher: Task)
# Injeta contexto do projeto no subagente e foca Explore
set -euo pipefail

PROJECT_ROOT="${PWD}"
INPUT=$(cat)

# Extrair tipo do subagente e prompt
SUBAGENT_TYPE=$(echo "$INPUT" | python3 -c "import sys,json; data=json.load(sys.stdin); ti=data.get('tool_input',{}); print(ti.get('subagent_type',''))" 2>/dev/null || echo "")
PROMPT=$(echo "$INPUT" | python3 -c "import sys,json; data=json.load(sys.stdin); ti=data.get('tool_input',{}); print(ti.get('prompt',''))" 2>/dev/null || echo "")

# Detectar se e Explore ou general-purpose com termos de exploracao
EXPLORE_PATTERN="explorar|explore|estrutura|onde fica|como funciona|entender|mapear"
IS_EXPLORE=false

if [[ "$SUBAGENT_TYPE" == "Explore" ]]; then
  IS_EXPLORE=true
elif [[ "$SUBAGENT_TYPE" == "general-purpose" ]] && echo "$PROMPT" | grep -qiE "$EXPLORE_PATTERN"; then
  IS_EXPLORE=true
fi

if [[ "$IS_EXPLORE" != "true" ]]; then
  exit 0
fi

# Montar contexto para injetar
CONTEXT=""

# CLAUDE.md resumido
if [[ -f "${PROJECT_ROOT}/CLAUDE.md" ]]; then
  CONTEXT+="=== CLAUDE.md (resumo) ==="$'\n'
  CONTEXT+=$(head -50 "${PROJECT_ROOT}/CLAUDE.md")
  CONTEXT+=$'\n\n'
fi

# Lista de docs
if [[ -d "${PROJECT_ROOT}/docs" ]]; then
  CONTEXT+="=== Docs disponiveis ==="$'\n'
  CONTEXT+=$(find "${PROJECT_ROOT}/docs" -type f 2>/dev/null | sort | sed "s|${PROJECT_ROOT}/||")
  CONTEXT+=$'\n\n'
fi

# Lista de audits
if [[ -d "${PROJECT_ROOT}/audits" ]]; then
  CONTEXT+="=== Audits disponiveis ==="$'\n'
  CONTEXT+=$(find "${PROJECT_ROOT}/audits" -type f 2>/dev/null | sort | sed "s|${PROJECT_ROOT}/||")
  CONTEXT+=$'\n\n'
fi

# Ultimos 2 commits
if git rev-parse --is-inside-work-tree &>/dev/null; then
  CONTEXT+="=== Ultimos commits ==="$'\n'
  CONTEXT+=$(git log -2 --oneline 2>/dev/null || echo "(vazio)")
  CONTEXT+=$'\n\n'
fi

CONTEXT+="INSTRUCAO: Foque APENAS no pedido especifico. NAO explore o projeto inteiro. Use o contexto acima como base antes de fazer glob/grep."

# Injetar via additionalContext
ESCAPED_CONTEXT=$(echo "$CONTEXT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")

cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": ${ESCAPED_CONTEXT}
  }
}
EOF
