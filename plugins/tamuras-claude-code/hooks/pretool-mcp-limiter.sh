#!/usr/bin/env bash
# Hook: PreToolUse (matcher: mcp__)
# Rate-limit MCPs pesados (playwright, puppeteer, browser)
set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('tool_name',''))" 2>/dev/null || echo "")

# Apenas limitar MCPs pesados (browser-based)
HEAVY_PATTERNS="playwright|puppeteer|browser"
if ! echo "$TOOL_NAME" | grep -qiE "$HEAVY_PATTERNS"; then
  exit 0
fi

# Contar processos pesados ativos
MAX_INSTANCES=2
HEAVY_COUNT=0

for proc in playwright puppeteer chromium chrome; do
  COUNT=$(pgrep -f "$proc" 2>/dev/null | wc -l | tr -d ' ')
  HEAVY_COUNT=$((HEAVY_COUNT + COUNT))
done

if [[ $HEAVY_COUNT -ge $MAX_INSTANCES ]]; then
  # Matar processos mais antigos
  for proc in playwright puppeteer; do
    OLDEST_PID=$(pgrep -f "$proc" -o 2>/dev/null || true)
    if [[ -n "$OLDEST_PID" ]]; then
      kill "$OLDEST_PID" 2>/dev/null || true
    fi
  done

  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "AVISO: Processos de browser pesados foram limitados (max ${MAX_INSTANCES}). Processos antigos foram encerrados para liberar recursos."
  }
}
EOF
fi

exit 0
