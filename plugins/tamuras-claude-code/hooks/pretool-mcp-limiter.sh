#!/bin/bash
# Hook: PreToolUse - Limita instâncias de MCP servers pesados
# Matcher: mcp__
# Evita que múltiplas sessões travem o PC com processos duplicados
#
# Uso: pretool-mcp-limiter.sh "$TOOL_NAME"
# Exemplo: pretool-mcp-limiter.sh "mcp__playwright__navigate"

TOOL_NAME="$1"

# Extrai o nome do MCP do TOOL_NAME (ex: mcp__playwright__navigate -> playwright)
MCP_NAME=$(echo "$TOOL_NAME" | sed -n 's/^mcp__\([^_]*\)__.*/\1/p')

# Se não conseguiu extrair, sai silenciosamente
if [ -z "$MCP_NAME" ]; then
    exit 0
fi

# Configuração: limites específicos para MCPs pesados
declare -A MCP_LIMITS=(
    ["playwright"]=2
    ["puppeteer"]=2
    ["chrome-devtools"]=2
    ["browser"]=2
    ["selenium"]=2
    ["chromium"]=3
)

# Limite padrão para MCPs não listados
DEFAULT_LIMIT=5

# Determina o limite para este MCP
LIMIT="${MCP_LIMITS[$MCP_NAME]:-$DEFAULT_LIMIT}"

# Conta instâncias do MCP atual
COUNT=$(pgrep -f "$MCP_NAME" 2>/dev/null | wc -l | tr -d ' ')

# Se excedeu o limite, mata os mais antigos
if [ "$COUNT" -gt "$LIMIT" ]; then
    TO_KILL=$((COUNT - LIMIT))
    pgrep -f "$MCP_NAME" | head -n "$TO_KILL" | xargs -r kill -9 2>/dev/null

    cat << EOF

# ⚠️ MCP Process Limiter

**MCP:** \`$MCP_NAME\`
**Instâncias detectadas:** $COUNT
**Limite configurado:** $LIMIT
**Processos terminados:** $TO_KILL

> Processos mais antigos foram terminados para evitar travamento do sistema.

EOF
fi

exit 0
