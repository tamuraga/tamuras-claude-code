#!/bin/bash
# Hook: PreToolUse - Redireciona Explorer nativo para codebase-explorer
# Matcher: Task
# Suporta: Input Modification (Claude 2.1.0+)

TOOL_INPUT="$1"

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
    MODIFIED_INPUT=$(echo "$TOOL_INPUT" | sed -E 's/"subagent_type"\s*:\s*"(Explore|general-purpose)"/"subagent_type": "tamuras-claude-code:codebase-explorer"/g')

    # Retornar JSON para Input Modification
    cat << EOF
{
  "updatedInput": true,
  "input": $MODIFIED_INPUT,
  "reason": "Redirecionado para codebase-explorer (contexto Git + Memento + docs)"
}
EOF
    exit 0
fi

# Se não for exploração, não interferir
exit 0
