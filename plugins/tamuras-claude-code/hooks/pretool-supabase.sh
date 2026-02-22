#!/usr/bin/env bash
# Hook: PreToolUse (matcher: mcp__supabase__)
# Regras de seguranca para Supabase MCP
set -euo pipefail

PROJECT_ROOT="${PWD}"
INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('tool_name',''))" 2>/dev/null || echo "")
TOOL_INPUT=$(echo "$INPUT" | python3 -c "import sys,json; data=json.load(sys.stdin); print(json.dumps(data.get('tool_input',{})))" 2>/dev/null || echo "{}")

deny() {
  local reason="$1"
  cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "reason": "${reason}"
  }
}
EOF
  exit 0
}

inject() {
  local context="$1"
  ESCAPED=$(echo "$context" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": ${ESCAPED}
  }
}
EOF
  exit 0
}

# Bloquear get_tables / list_tables
if echo "$TOOL_NAME" | grep -qiE '(get_tables|list_tables)'; then
  HINT="BLOQUEADO: Em vez de listar tabelas via MCP, consulte as migrations em supabase/migrations/ ou schema em prisma/schema.prisma"
  if [[ -d "${PROJECT_ROOT}/supabase/migrations" ]]; then
    HINT+=". Migrations encontradas em: supabase/migrations/"
  fi
  if [[ -f "${PROJECT_ROOT}/prisma/schema.prisma" ]]; then
    HINT+=". Schema encontrado em: prisma/schema.prisma"
  fi
  deny "$HINT"
fi

# Bloquear execute_sql destrutivo
if echo "$TOOL_NAME" | grep -qiE 'execute_sql'; then
  SQL=$(echo "$TOOL_INPUT" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('sql','') or data.get('query',''))" 2>/dev/null || echo "")

  if echo "$SQL" | grep -qiE '^\s*(DROP|TRUNCATE)'; then
    deny "BLOQUEADO: Operacao SQL destrutiva (DROP/TRUNCATE) nao permitida via MCP"
  fi

  if echo "$SQL" | grep -qiE 'DELETE\s+FROM' && ! echo "$SQL" | grep -qiE 'WHERE'; then
    deny "BLOQUEADO: DELETE FROM sem WHERE nao e permitido via MCP"
  fi
fi

# Para queries permitidas, injetar regras de contexto
RULES="Regras Supabase:"$'\n'
RULES+="- Sempre verificar RLS policies antes de criar tabelas"$'\n'
RULES+="- Usar auth.uid() para row-level security"$'\n'
RULES+="- Verificar tipos gerados em src/types/supabase.ts ou database.types.ts"$'\n'
RULES+="- Preferir migrations versionadas sobre SQL direto"

inject "$RULES"
