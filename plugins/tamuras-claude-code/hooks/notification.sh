#!/usr/bin/env bash
# Hook: Notification
# Notificacao nativa macOS direcionando para terminal correto
set -euo pipefail

INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('message', data.get('title', 'Tarefa concluida')))
" 2>/dev/null || echo "Tarefa concluida")

# Limitar tamanho da mensagem
MESSAGE="${MESSAGE:0:200}"

# Notificacao macOS
osascript -e "display notification \"${MESSAGE}\" with title \"Claude Code\" sound name \"Ping\"" 2>/dev/null || true

# Detectar terminal e ativar janela
TERM="${TERM_PROGRAM:-Terminal}"
case "$TERM" in
  iTerm*|iTerm2|iTerm.app)
    osascript -e 'tell application "iTerm2" to activate' 2>/dev/null || true
    ;;
  WarpTerminal|Warp)
    osascript -e 'tell application "Warp" to activate' 2>/dev/null || true
    ;;
  vscode|Code)
    osascript -e 'tell application "Visual Studio Code" to activate' 2>/dev/null || true
    ;;
  Apple_Terminal|Terminal)
    osascript -e 'tell application "Terminal" to activate' 2>/dev/null || true
    ;;
  *)
    # Fallback: tentar Terminal generico
    osascript -e 'tell application "Terminal" to activate' 2>/dev/null || true
    ;;
esac

exit 0
