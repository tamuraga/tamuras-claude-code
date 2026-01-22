#!/bin/bash
# Hook: PreToolUse - Redireciona Explorer nativo para codebase-explorer
# Matcher: Task
# Suporta: Input Modification (Claude 2.1.0+)

TOOL_INPUT="$1"

# Capturar nome do projeto
PROJECT_NAME=$(basename "$(pwd)")

# Detectar se é chamada de exploração (Explore ou general-purpose com termos de exploração)
IS_EXPLORE=false

if echo "$TOOL_INPUT" | grep -qiE '"subagent_type"\s*:\s*"Explore"'; then
    IS_EXPLORE=true
fi

if echo "$TOOL_INPUT" | grep -qiE '"subagent_type"\s*:\s*"general-purpose"' && \
   echo "$TOOL_INPUT" | grep -qiE 'explor|entender|mapear|estrutura|codebase|onboarding'; then
    IS_EXPLORE=true
fi

# Se for exploração, modificar para usar nosso agente
if [ "$IS_EXPLORE" = true ]; then
    # Substituir subagent_type para nosso codebase-explorer
    MODIFIED_INPUT=$(echo "$TOOL_INPUT" | sed 's/"subagent_type"[[:space:]]*:[[:space:]]*"Explore"/"subagent_type": "tamuras-claude-code:codebase-explorer"/g' | sed 's/"subagent_type"[[:space:]]*:[[:space:]]*"general-purpose"/"subagent_type": "tamuras-claude-code:codebase-explorer"/g')

    # Injetar nome do projeto no prompt
    MODIFIED_INPUT=$(echo "$MODIFIED_INPUT" | sed "s/\"prompt\"[[:space:]]*:[[:space:]]*\"/\"prompt\": \"Projeto: $PROJECT_NAME - Verificar contexto no claude-mem primeiro. /g")

    # Retornar JSON para Input Modification
    cat << EOF
{
  "updatedInput": true,
  "input": $MODIFIED_INPUT,
  "reason": "Redirecionado para codebase-explorer (contexto Git + claude-mem + docs) - Projeto: $PROJECT_NAME"
}
EOF
    exit 0
fi

# Se não for exploração, não interferir
exit 0
