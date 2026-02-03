#!/bin/bash
# Hook: SessionStart - Busca memorias do mcp-memory e injeta no contexto
# Requer: MCP_MEMORY_URL e MCP_MEMORY_TOKEN no ambiente

MCP_URL="${MCP_MEMORY_URL:-https://memory.mamiya.dev}"
MCP_TOKEN="${MCP_MEMORY_TOKEN}"
PROJECT_SLUG=$(basename "$(pwd)")

# Sem token = sem memoria (graceful degradation)
[ -z "$MCP_TOKEN" ] && exit 0

# Buscar observacoes recentes do projeto (timeline, ultimas 5)
RESPONSE=$(curl -s -X POST "$MCP_URL/mcp" \
  -H "Authorization: Bearer $MCP_TOKEN" \
  -H "X-Project-Slug: $PROJECT_SLUG" \
  -H "Content-Type: application/json" \
  -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"timeline\",\"arguments\":{\"limit\":5}}}" \
  --max-time 3 2>/dev/null)

# Se falhou ou vazio, sair silenciosamente
[ -z "$RESPONSE" ] && exit 0

# Verificar se tem conteudo util (nao apenas erro)
if echo "$RESPONSE" | grep -q '"error"'; then
    exit 0
fi

# Extrair o texto do resultado
CONTENT=$(echo "$RESPONSE" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    result = data.get('result', {})
    for item in result.get('content', []):
        if item.get('type') == 'text':
            print(item['text'][:2000])
            break
except:
    pass
" 2>/dev/null)

[ -z "$CONTENT" ] && exit 0

echo "# Memorias do projeto ($PROJECT_SLUG)"
echo "INSTRUCAO: Use estas memorias como contexto. Nao precisa buscar novamente."
echo "---"
echo "$CONTENT" | head -50
