#!/bin/bash
# Hook: PreToolUse - TypeScript preflight antes de Edit/Write
# Trigger: PreToolUse
# Matcher: Edit|Write
# Autor: tamuras-claude-code (2026)
#
# Otimizações:
# - Roda só no arquivo modificado (não projeto inteiro)
# - Usa --incremental para cache do tsc
# - Usa --skipLibCheck para ignorar node_modules
#
# Performance esperada:
# - Primeira execução: ~1-3s
# - Execuções seguintes: ~100-300ms (cache)

# Input vem como JSON via argumento ou stdin
TOOL_INPUT="${1:-$(cat)}"

# Extrair filepath do input JSON
FILEPATH=$(echo "$TOOL_INPUT" | grep -oE '"file_path"\s*:\s*"[^"]+"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

# Se não encontrou file_path, tentar outros padrões
if [ -z "$FILEPATH" ]; then
    FILEPATH=$(echo "$TOOL_INPUT" | grep -oE '"path"\s*:\s*"[^"]+"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
fi

# Verificar se é arquivo TypeScript
if [[ ! "$FILEPATH" =~ \.(ts|tsx)$ ]]; then
    exit 0  # Não é TypeScript, permitir
fi

# Verificar se arquivo existe (se não existe, é arquivo novo - permitir)
if [ ! -f "$FILEPATH" ]; then
    exit 0
fi

# Encontrar diretório do projeto (subir até encontrar tsconfig.json)
PROJECT_DIR=$(dirname "$FILEPATH")
while [ "$PROJECT_DIR" != "/" ] && [ ! -f "$PROJECT_DIR/tsconfig.json" ]; do
    PROJECT_DIR=$(dirname "$PROJECT_DIR")
done

# Se não encontrou tsconfig.json, pular validação
if [ ! -f "$PROJECT_DIR/tsconfig.json" ]; then
    exit 0
fi

# Cache dir para builds incrementais (dentro do projeto)
CACHE_DIR="$PROJECT_DIR/node_modules/.cache/.tsbuildinfo"
mkdir -p "$(dirname "$CACHE_DIR")" 2>/dev/null

# Rodar tsc com otimizações:
# --noEmit: não gera output
# --incremental: usa cache
# --skipLibCheck: ignora tipos de node_modules
# --tsBuildInfoFile: onde salvar cache
TSC_OUTPUT=$(cd "$PROJECT_DIR" && npx tsc \
    --noEmit \
    --incremental \
    --skipLibCheck \
    --tsBuildInfoFile "$CACHE_DIR" \
    2>&1)
TSC_EXIT=$?

if [ $TSC_EXIT -ne 0 ]; then
    # Filtrar apenas erros relevantes (do arquivo ou erros gerais)
    RELEVANT_ERRORS=$(echo "$TSC_OUTPUT" | grep -E "error TS|^$FILEPATH" | head -15)

    # Se não há erros relevantes, mostrar tudo
    if [ -z "$RELEVANT_ERRORS" ]; then
        RELEVANT_ERRORS=$(echo "$TSC_OUTPUT" | head -20)
    fi

    # Escapar para JSON
    ERRORS_JSON=$(echo "$RELEVANT_ERRORS" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | tr '\n' '|' | sed 's/|/\\n/g')

    cat << EOF
{
  "decision": "block",
  "reason": "TypeScript errors detected. Fix errors before editing.",
  "file": "$FILEPATH",
  "errors": "$ERRORS_JSON"
}
EOF
    exit 1
fi

# TypeScript OK, permitir edição
exit 0
