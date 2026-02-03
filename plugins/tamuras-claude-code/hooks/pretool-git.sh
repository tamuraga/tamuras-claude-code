#!/bin/bash
# Hook: PreToolUse - Valida e corrige commits antes de executar
# Matcher: Bash (quando contém "git commit" ou "gh pr")
# Suporta: Input Modification (Claude 2.1.0+)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL_INPUT="$1"

# Verificar se é comando git commit ou gh pr
if echo "$TOOL_INPUT" | grep -qE "(git commit|gh pr)"; then

    # Extrair mensagem do commit (entre aspas após -m)
    COMMIT_MSG=$(echo "$TOOL_INPUT" | grep -oP '(?<=-m\s*["\x27])[^"\x27]+')

    if [ -n "$COMMIT_MSG" ]; then
        MSG_LENGTH=${#COMMIT_MSG}

        # Verificar se mensagem é muito longa (limite: 80 chars)
        if [ "$MSG_LENGTH" -gt 80 ]; then
            # Truncar para 77 chars + "..."
            TRUNCATED="${COMMIT_MSG:0:77}..."

            # Substituir mensagem no comando
            MODIFIED_INPUT=$(echo "$TOOL_INPUT" | sed "s|$COMMIT_MSG|$TRUNCATED|")

            # Retornar JSON para Input Modification
            echo "{\"updatedInput\": true, \"command\": \"$MODIFIED_INPUT\", \"reason\": \"Mensagem truncada de $MSG_LENGTH para 80 chars\"}"
            exit 0
        fi

        # Verificar Co-Authored-By
        if echo "$TOOL_INPUT" | grep -qiE "co-authored-by|claude|anthropic|ai assistant"; then
            # Remover linhas com Co-Authored-By
            MODIFIED_INPUT=$(echo "$TOOL_INPUT" | sed -E 's/Co-Authored-By:[^\n"]*//gi')

            echo "{\"updatedInput\": true, \"command\": \"$MODIFIED_INPUT\", \"reason\": \"Removido Co-Authored-By/menção de IA\"}"
            exit 0
        fi
    fi

    # Se não precisou modificar, apenas exibir regras
    cat "$SCRIPT_DIR/pretool-git.md"
fi
