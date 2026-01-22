#!/bin/bash
# Hook: UserPromptSubmit - Mostra % contexto usado
# Trigger: UserPromptSubmit
# Autor: tamuras-claude-code (2026)
#
# Exibe indicador visual de uso de contexto:
# 🟢 Verde: < 60% - Contexto saudável
# 🟡 Amarelo: 60-79% - Considerar handoff
# 🔴 Vermelho: ≥ 80% - Crítico, executar handoff

# Obter % de contexto via variável de ambiente do Claude Code
# CLAUDE_CONTEXT_PERCENT é injetado pelo Claude Code 2.1.0+
CONTEXT_PCT=${CLAUDE_CONTEXT_PERCENT:-0}

# Se não temos a variável, tentar estimar via tamanho da sessão
if [ "$CONTEXT_PCT" = "0" ]; then
    # Fallback: verificar se existe arquivo de sessão com info
    SESSION_FILE="${CLAUDE_SESSION_FILE:-}"
    if [ -n "$SESSION_FILE" ] && [ -f "$SESSION_FILE" ]; then
        # Estimar baseado no tamanho do arquivo (heurística)
        FILE_SIZE=$(stat -f%z "$SESSION_FILE" 2>/dev/null || stat -c%s "$SESSION_FILE" 2>/dev/null || echo "0")
        # ~200KB = ~100% contexto (heurística para 200k tokens)
        CONTEXT_PCT=$((FILE_SIZE * 100 / 200000))
        [ "$CONTEXT_PCT" -gt 100 ] && CONTEXT_PCT=100
    fi
fi

# Exibir indicador baseado no percentual
if [ "$CONTEXT_PCT" -lt 60 ]; then
    echo "🟢 Contexto: ${CONTEXT_PCT}%"
elif [ "$CONTEXT_PCT" -lt 80 ]; then
    echo "🟡 Contexto: ${CONTEXT_PCT}% - Considere criar handoff"
else
    echo "🔴 Contexto: ${CONTEXT_PCT}% ⚠️ CRÍTICO - Execute /compact ou /handoff"
fi

exit 0
