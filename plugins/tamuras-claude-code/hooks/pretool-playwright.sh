#!/bin/bash
# Hook: PreToolUse - Restringe domínios do Playwright
# Matcher: mcp__playwright__

# Extrair URL do input (se houver)
TOOL_INPUT="$1"

cat << 'EOF'
# Playwright - Restrições de Domínio

## Domínios Permitidos
- localhost:*
- 127.0.0.1:*
- *.local
- *.test

## Domínios Bloqueados
- Qualquer domínio externo (produção, APIs públicas)
- Sites de terceiros sem autorização explícita

## IMPORTANTE
Antes de navegar para qualquer URL que NÃO seja localhost:
1. PARAR e perguntar ao usuário
2. Informar o domínio que será acessado
3. Aguardar confirmação explícita

## Exemplo de Pergunta
"Posso acessar [domínio]? Este não é um domínio local."

## Ações Permitidas sem Perguntar
- Navegar para localhost:3000, localhost:8080, etc
- Screenshots de páginas locais
- Interações com app local em desenvolvimento
EOF

# Verificar se URL contém domínio externo
if echo "$TOOL_INPUT" | grep -qE "https?://[^localhost|127.0.0.1]"; then
    echo ""
    echo "⚠️  ALERTA: URL externa detectada. Confirmar com usuário antes de prosseguir."
fi
