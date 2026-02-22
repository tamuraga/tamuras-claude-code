#!/usr/bin/env bash
# Hook: PreToolUse (matcher: Bash)
# Bloqueia comandos destrutivos
set -euo pipefail

# Ler input do stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Funcao para bloquear
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

# rm -rf destrutivo
if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|--force\s+)*(\/|~|\.)$'; then
  deny "BLOQUEADO: rm -rf em diretorio raiz/home/atual e destrutivo demais"
fi
if echo "$COMMAND" | grep -qE 'rm\s+-rf\s+(/|~|\.)$'; then
  deny "BLOQUEADO: rm -rf em diretorio raiz/home/atual e destrutivo demais"
fi

# sudo (a menos que contexto explicito)
if echo "$COMMAND" | grep -qE '^\s*sudo\s'; then
  deny "BLOQUEADO: uso de sudo requer autorizacao explicita do usuario"
fi

# SQL destrutivo
if echo "$COMMAND" | grep -qiE 'DROP\s+DATABASE'; then
  deny "BLOQUEADO: DROP DATABASE e uma operacao destrutiva"
fi
if echo "$COMMAND" | grep -qiE 'TRUNCATE\s+' && ! echo "$COMMAND" | grep -qiE 'WHERE'; then
  deny "BLOQUEADO: TRUNCATE sem WHERE e uma operacao destrutiva"
fi

# git push --force para main/master
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*--force' && echo "$COMMAND" | grep -qE '(main|master)'; then
  deny "BLOQUEADO: git push --force para main/master e perigoso"
fi
if echo "$COMMAND" | grep -qE 'git\s+push\s+-f' && echo "$COMMAND" | grep -qE '(main|master)'; then
  deny "BLOQUEADO: git push -f para main/master e perigoso"
fi

# git reset --hard
if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  deny "BLOQUEADO: git reset --hard pode perder trabalho. Use com cautela."
fi

# Nada bloqueado
exit 0
