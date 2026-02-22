#!/usr/bin/env bash
# Hook: PreToolUse (matcher: mcp__context7__)
# Injeta versoes dos pacotes do projeto na pesquisa
set -euo pipefail

PROJECT_ROOT="${PWD}"
INPUT=$(cat)

# Extrair o prompt/query do tool_input
QUERY=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
# Tentar diferentes campos comuns
for key in ['query', 'prompt', 'topic', 'search', 'libraryName', 'library_name']:
    val = ti.get(key, '')
    if val:
        print(val)
        break
else:
    print('')
" 2>/dev/null || echo "")

if [[ -z "$QUERY" ]]; then
  exit 0
fi

# Ler package.json e extrair versoes relevantes
if [[ ! -f "${PROJECT_ROOT}/package.json" ]]; then
  exit 0
fi

# Extrair versoes dos pacotes mencionados na query
VERSIONS=$(python3 -c "
import json, re, sys

query = '''${QUERY}'''.lower()

try:
    with open('${PROJECT_ROOT}/package.json') as f:
        pkg = json.load(f)
except:
    sys.exit(0)

deps = {}
deps.update(pkg.get('dependencies', {}))
deps.update(pkg.get('devDependencies', {}))

matches = []
for name, version in deps.items():
    # Limpar nome para comparacao
    clean_name = name.replace('@', '').replace('/', ' ').replace('-', ' ').lower()
    # Verificar se o pacote e mencionado na query
    for part in clean_name.split():
        if len(part) > 2 and part in query:
            ver = version.lstrip('^~>=<')
            matches.append(f'{name}@{ver}')
            break

if matches:
    print(', '.join(matches[:5]))
" 2>/dev/null || echo "")

if [[ -n "$VERSIONS" ]]; then
  CONTEXT="Versoes instaladas no projeto: ${VERSIONS}. Use estas versoes na pesquisa de documentacao."
  ESCAPED=$(echo "$CONTEXT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")

  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": ${ESCAPED}
  }
}
EOF
fi

exit 0
