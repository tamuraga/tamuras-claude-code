#!/bin/bash
# Hook: PreToolUse - Redireciona Explorer nativo para codebase-explorer
# Matcher: Task
# Suporta: Input Modification (Claude 2.1.0+)

TOOL_INPUT="$1"

# Capturar nome do projeto
PROJECT_NAME=$(basename "$(pwd)")

# Detectar se e chamada de exploracao (Explore ou general-purpose com termos de exploracao)
IS_EXPLORE=false

if echo "$TOOL_INPUT" | grep -qiE '"subagent_type"\s*:\s*"Explore"'; then
    IS_EXPLORE=true
fi

if echo "$TOOL_INPUT" | grep -qiE '"subagent_type"\s*:\s*"general-purpose"' && \
   echo "$TOOL_INPUT" | grep -qiE 'explor|entender|mapear|estrutura|codebase|onboarding'; then
    IS_EXPLORE=true
fi

# Se nao for exploracao, nao interferir
if [ "$IS_EXPLORE" != true ]; then
    exit 0
fi

# SHORT-CIRCUIT: Verificar se audit valido existe
AUDIT_FILE="$(pwd)/audits/exploration/LATEST.yaml"
if [ -f "$AUDIT_FILE" ]; then
    AUDIT_REF=$(grep '^git_ref:' "$AUDIT_FILE" | cut -d' ' -f2)
    CURRENT_REF=$(git rev-parse --short HEAD 2>/dev/null)

    if [ "$AUDIT_REF" = "$CURRENT_REF" ]; then
        # Audit valido - injetar no prompt ao inves de explorar
        AUDIT_CONTENT=$(cat "$AUDIT_FILE")

        # Extrair o prompt original do JSON
        ORIGINAL_PROMPT=$(echo "$TOOL_INPUT" | sed -n 's/.*"prompt"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/p' | head -1)

        # Modificar o prompt para incluir o audit e instrucao de nao explorar
        INJECT_PREFIX="CONTEXTO JA MAPEADO (ref: $AUDIT_REF). NAO explore novamente. Use o YAML abaixo como contexto e responda a pergunta do usuario diretamente.\\n---\\n$AUDIT_CONTENT\\n---\\nPergunta original: "

        MODIFIED_INPUT=$(echo "$TOOL_INPUT" | sed "s|\"prompt\"[[:space:]]*:[[:space:]]*\"|\"prompt\": \"$INJECT_PREFIX|")

        cat << EOF
{
  "updatedInput": true,
  "input": $MODIFIED_INPUT,
  "reason": "Audit valido encontrado (ref: $AUDIT_REF). Contexto injetado no prompt - Projeto: $PROJECT_NAME"
}
EOF
        exit 0
    fi
fi

# Se chegou aqui, redirecionar normalmente para codebase-explorer
MODIFIED_INPUT=$(echo "$TOOL_INPUT" | sed 's/"subagent_type"[[:space:]]*:[[:space:]]*"Explore"/"subagent_type": "tamuras-claude-code:codebase-explorer"/g' | sed 's/"subagent_type"[[:space:]]*:[[:space:]]*"general-purpose"/"subagent_type": "tamuras-claude-code:codebase-explorer"/g')

# Injetar nome do projeto no prompt
MODIFIED_INPUT=$(echo "$MODIFIED_INPUT" | sed "s/\"prompt\"[[:space:]]*:[[:space:]]*\"/\"prompt\": \"Projeto: $PROJECT_NAME - Verificar contexto no claude-mem primeiro. /g")

cat << EOF
{
  "updatedInput": true,
  "input": $MODIFIED_INPUT,
  "reason": "Redirecionado para codebase-explorer (contexto Git + claude-mem + docs) - Projeto: $PROJECT_NAME"
}
EOF
exit 0
