#!/bin/bash
# Hook: PreCompact - Salva estado antes de compactar contexto
# Trigger: PreCompact
# Autor: tamuras-claude-code (2026)
#
# Antes de compactação, gera snapshot YAML com:
# - Últimos arquivos modificados
# - ID da sessão
# - Timestamp
# - Espaço para decisões e próximos passos

# Diretório base do plugin (relativo ao hook)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

PROJECT=$(basename "$(pwd)")
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
HANDOFF_DIR="$PLUGIN_DIR/thoughts/handoffs"
HANDOFF_FILE="$HANDOFF_DIR/handoff-${PROJECT}-${TIMESTAMP}.yaml"

# Criar diretório se não existir
mkdir -p "$HANDOFF_DIR"

# Coletar últimos arquivos modificados via git
LAST_FILES=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    LAST_FILES=$(git diff --name-only HEAD~5 2>/dev/null | head -10 | tr '\n' '\n  - ' | sed 's/^/  - /')
    if [ -z "$LAST_FILES" ]; then
        LAST_FILES=$(git status --porcelain 2>/dev/null | head -10 | awk '{print $2}' | tr '\n' '\n  - ' | sed 's/^/  - /')
    fi
fi

# Se não há arquivos, indicar
if [ -z "$LAST_FILES" ]; then
    LAST_FILES="  - (nenhum arquivo rastreado)"
fi

# Gerar YAML com estado atual
cat << EOF > "$HANDOFF_FILE"
# Handoff automático gerado antes de compactação
# Projeto: $PROJECT
# Gerado: $(date '+%Y-%m-%d %H:%M:%S')

project: $PROJECT
timestamp: "$TIMESTAMP"
session_id: "${CLAUDE_SESSION_ID:-unknown}"
working_directory: "$(pwd)"

context:
  last_files_modified:
$LAST_FILES

  current_branch: "$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'N/A')"
  last_commit: "$(git log -1 --oneline 2>/dev/null || echo 'N/A')"

decisions:
  # Adicione decisões importantes aqui
  - "(preencher manualmente)"

next_steps:
  # Próximos passos para continuar o trabalho
  - "(preencher manualmente)"

notes: |
  Handoff automático gerado antes da compactação de contexto.

  Para carregar este handoff em uma nova sessão:
  1. Abra este arquivo
  2. Cole o conteúdo no início da conversa

  Ou use: /resume-handoff $HANDOFF_FILE
EOF

echo "✅ Handoff salvo: $HANDOFF_FILE"
echo "📋 Use este arquivo para retomar o contexto em nova sessão"

exit 0
