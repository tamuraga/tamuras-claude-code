#!/bin/bash
# Hook: PreCompact - Salva resumo da sessao no mcp-memory antes do compact
# Requer: MCP_MEMORY_URL e MCP_MEMORY_TOKEN no ambiente

MCP_URL="${MCP_MEMORY_URL:-https://memory.mamiya.dev}"
MCP_TOKEN="${MCP_MEMORY_TOKEN}"
PROJECT_SLUG=$(basename "$(pwd)")

# Sem token = sem memoria (graceful degradation)
[ -z "$MCP_TOKEN" ] && exit 0

# Capturar contexto da sessao
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
LAST_COMMITS=$(git log -3 --oneline 2>/dev/null | tr '\n' '; ' || echo "n/a")
MODIFIED_FILES=$(git diff --name-only HEAD~3 2>/dev/null | head -10 | tr '\n' ', ' || echo "n/a")
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

# Montar conteudo do resumo
CONTENT="Session summary ($TIMESTAMP) on branch $BRANCH. Recent commits: $LAST_COMMITS. Modified files: $MODIFIED_FILES"

# Escapar aspas para JSON
CONTENT_ESCAPED=$(echo "$CONTENT" | sed 's/"/\\"/g' | tr -d '\n')

# Salvar como observation tipo "learning"
curl -s -X POST "$MCP_URL/mcp" \
  -H "Authorization: Bearer $MCP_TOKEN" \
  -H "X-Project-Slug: $PROJECT_SLUG" \
  -H "Content-Type: application/json" \
  -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"save\",\"arguments\":{\"content\":\"$CONTENT_ESCAPED\",\"type\":\"learning\",\"tags\":[\"session-summary\",\"auto\"]}}}" \
  --max-time 5 >/dev/null 2>&1

exit 0
