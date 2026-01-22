#!/bin/bash
# Hook: SessionStart + PostToolUse - Mantém ledger de continuidade
# Triggers: SessionStart, PostToolUse (matcher: Edit|Write)
# Autor: tamuras-claude-code (2026)
#
# Funcionalidades:
# - SessionStart: Carrega ledger existente ou cria novo
# - PostToolUse: Registra arquivos modificados automaticamente
#
# Uso com variável de ambiente HOOK_EVENT:
# - HOOK_EVENT=SessionStart ./session-ledger.sh
# - HOOK_EVENT=PostToolUse ./session-ledger.sh "$TOOL_INPUT"

# Diretório base do plugin (relativo ao hook)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

PROJECT=$(basename "$(pwd)")
LEDGER_DIR="$PLUGIN_DIR/thoughts/ledgers"
LEDGER_FILE="$LEDGER_DIR/CONTINUITY_${PROJECT}.md"

# Criar diretório se não existir
mkdir -p "$LEDGER_DIR"

# Detectar evento (via variável de ambiente ou argumento)
HOOK_EVENT="${HOOK_EVENT:-SessionStart}"

# ============================================
# SessionStart: Carregar ou criar ledger
# ============================================
if [ "$HOOK_EVENT" = "SessionStart" ]; then
    # Lembrete compacto dos princípios
    PRINCIPLES="📅 $(date '+%d/%m/%Y') | 🔍 Não explorar sem autorização | 📚 Embasar com docs | 📋 Exibir princípios"

    if [ -f "$LEDGER_FILE" ]; then
        echo "📋 Ledger de continuidade carregado: $LEDGER_FILE"
        echo "$PRINCIPLES"
        echo "---"
        cat "$LEDGER_FILE"
        echo "---"
    else
        # Criar novo ledger
        CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "N/A")

        cat << EOF > "$LEDGER_FILE"
# Continuity Ledger: $PROJECT

**Criado:** $(date '+%Y-%m-%d %H:%M')
**Branch:** $CURRENT_BRANCH
**Diretório:** $(pwd)

## Decisões Importantes
<!-- Adicione decisões-chave aqui -->
- (nenhuma ainda)

## Arquivos Modificados
<!-- Atualizado automaticamente pelos hooks -->

## Próximos Passos
- [ ] (definir)

## Notas da Sessão
<!-- Anotações livres -->

---
*Ledger mantido automaticamente por tamuras-claude-code*
EOF
        echo "📋 Novo ledger criado: $LEDGER_FILE"
        echo "---"
        cat "$LEDGER_FILE"
        echo "---"
    fi
    exit 0
fi

# ============================================
# PostToolUse: Registrar arquivo modificado
# ============================================
if [ "$HOOK_EVENT" = "PostToolUse" ]; then
    TOOL_INPUT="${1:-$(cat)}"

    # Extrair filepath do input
    MODIFIED_FILE=$(echo "$TOOL_INPUT" | grep -oE '"file_path"\s*:\s*"[^"]+"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

    if [ -z "$MODIFIED_FILE" ]; then
        MODIFIED_FILE=$(echo "$TOOL_INPUT" | grep -oE '"path"\s*:\s*"[^"]+"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
    fi

    if [ -n "$MODIFIED_FILE" ] && [ -f "$LEDGER_FILE" ]; then
        # Verificar se já existe no ledger
        if ! grep -qF "$MODIFIED_FILE" "$LEDGER_FILE" 2>/dev/null; then
            # Adicionar após "## Arquivos Modificados"
            TIMESTAMP=$(date '+%H:%M')

            # Usar sed para inserir após a seção
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                sed -i '' "/## Arquivos Modificados/a\\
- \`$MODIFIED_FILE\` ($TIMESTAMP)" "$LEDGER_FILE"
            else
                # Linux
                sed -i "/## Arquivos Modificados/a\\- \`$MODIFIED_FILE\` ($TIMESTAMP)" "$LEDGER_FILE"
            fi
        fi
    fi
    exit 0
fi

exit 0
