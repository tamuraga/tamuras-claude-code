#!/usr/bin/env bash
# Hook: SubagentStop
# Consolida resultado de Explore em audit
set -euo pipefail

PROJECT_ROOT="${PWD}"
INPUT=$(cat)

AGENT_TYPE=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('agent_type', data.get('subagent_type', '')))
" 2>/dev/null || echo "")

# Apenas processar Explore
if [[ "$AGENT_TYPE" != "Explore" ]]; then
  exit 0
fi

# Extrair ultima mensagem do assistente
LAST_MESSAGE=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('last_assistant_message', data.get('result', ''))[:2000])
" 2>/dev/null || echo "")

if [[ -z "$LAST_MESSAGE" ]]; then
  exit 0
fi

# Classificar categoria e severidade
CLASSIFICATION=$(python3 -c "
import re

msg = '''${LAST_MESSAGE//\'/\\\'}'''[:2000].lower()

# Classificar categoria
categories = {
    'research': ['pesquisa', 'research', 'analise', 'entender', 'documentacao'],
    'visual': ['ui', 'design', 'visual', 'layout', 'componente', 'css', 'tailwind'],
    'development': ['codigo', 'implementa', 'funcao', 'api', 'endpoint', 'migration'],
    'business': ['negocio', 'requisito', 'fluxo', 'usuario', 'jornada'],
}

category = 'general'
for cat, keywords in categories.items():
    if any(kw in msg for kw in keywords):
        category = cat
        break

# Classificar severidade
if any(w in msg for w in ['critico', 'critical', 'urgente', 'bug', 'erro', 'falha', 'broken']):
    severity = 'critical'
elif any(w in msg for w in ['importante', 'atencao', 'melhorar', 'refactor', 'warning']):
    severity = 'medium'
else:
    severity = 'low'

print(f'{category} {severity}')
" 2>/dev/null || echo "general low")

CATEGORY=$(echo "$CLASSIFICATION" | cut -d' ' -f1)
SEVERITY=$(echo "$CLASSIFICATION" | cut -d' ' -f2)
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")

# Criar diretorio de audits
AUDIT_DIR="${PROJECT_ROOT}/audits/${CATEGORY}"
mkdir -p "$AUDIT_DIR"

# Gerar arquivo de audit
AUDIT_FILE="${AUDIT_DIR}/audit-${SEVERITY}-${TIMESTAMP}.md"
cat > "$AUDIT_FILE" <<AUDIT
**Gerado em:** $(date "+%Y-%m-%d %H:%M:%S")
**Categoria:** ${CATEGORY}
**Severidade:** ${SEVERITY}
**Agente:** Explore

---

${LAST_MESSAGE}
AUDIT

exit 0
