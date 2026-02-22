#!/usr/bin/env bash
# Hook: SessionEnd
# Registra sessao no ledger + salva handoff + atualiza docs
set -euo pipefail

PROJECT_ROOT="${PWD}"
PLUGIN_DIR="${PROJECT_ROOT}/plugins/tamuras-claude-code"
HANDOFF_DIR="${PLUGIN_DIR}/thoughts/handoffs"
LEDGER_DIR="${PLUGIN_DIR}/thoughts/ledgers"
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
TIMESTAMP_READABLE=$(date "+%Y-%m-%d %H:%M:%S")

# Criar diretorios
mkdir -p "$HANDOFF_DIR" "$LEDGER_DIR"

# Info do git
BRANCH="(desconhecido)"
LAST_COMMIT="(desconhecido)"
MODIFIED_FILES=""

if git rev-parse --is-inside-work-tree &>/dev/null; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
  LAST_COMMIT=$(git log -1 --oneline 2>/dev/null || echo "(sem commits)")
  MODIFIED_FILES=$(git diff --name-only HEAD 2>/dev/null || echo "")
fi

SESSION_ID="${PPID:-unknown}"

# Determinar nome do projeto
PROJECT_NAME=$(basename "$PROJECT_ROOT")

# === 1. Salvar handoff ===
cat > "${HANDOFF_DIR}/handoff-${TIMESTAMP}.yaml" <<YAML
# Handoff - Session End
timestamp: "${TIMESTAMP}"
session_id: "${SESSION_ID}"
branch: "${BRANCH}"
last_commit: "${LAST_COMMIT}"
modified_files:
$(echo "$MODIFIED_FILES" | sed 's/^/  - /' | head -20)
project_root: "${PROJECT_ROOT}"
YAML

# === 2. Registrar no ledger ===
LEDGER_FILE="${LEDGER_DIR}/CONTINUITY_${PROJECT_NAME}.md"

if [[ ! -f "$LEDGER_FILE" ]]; then
  cat > "$LEDGER_FILE" <<HEADER
# Continuity Ledger - ${PROJECT_NAME}

Registro de sessoes para manter continuidade entre conversas.

---

HEADER
fi

# Append entrada da sessao
cat >> "$LEDGER_FILE" <<ENTRY

## Sessao ${TIMESTAMP_READABLE}
- **Session ID:** ${SESSION_ID}
- **Branch:** ${BRANCH}
- **Ultimo commit:** ${LAST_COMMIT}
- **Arquivos modificados:**
$(echo "$MODIFIED_FILES" | sed 's/^/  - /' | head -10)

ENTRY

# === 3. Verificar novos audits/docs ===
# Listar audits recentes (criados na ultima hora)
if [[ -d "${PROJECT_ROOT}/audits" ]]; then
  RECENT_AUDITS=$(find "${PROJECT_ROOT}/audits" -type f -name "*.md" -newer "${LEDGER_FILE}" 2>/dev/null | head -5)
  if [[ -n "$RECENT_AUDITS" ]]; then
    echo "Novos audits detectados nesta sessao:" >> "$LEDGER_FILE"
    echo "$RECENT_AUDITS" | sed "s|${PROJECT_ROOT}/|  - |" >> "$LEDGER_FILE"
    echo "" >> "$LEDGER_FILE"
  fi
fi

exit 0
