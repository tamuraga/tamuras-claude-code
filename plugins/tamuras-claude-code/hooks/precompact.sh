#!/usr/bin/env bash
# Hook: PreCompact
# Salva handoff + consolida audits antes de compactar
set -euo pipefail

PROJECT_ROOT="${PWD}"
PLUGIN_DIR="${PROJECT_ROOT}/plugins/tamuras-claude-code"
HANDOFF_DIR="${PLUGIN_DIR}/thoughts/handoffs"
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")

# Criar diretorios se necessario
mkdir -p "$HANDOFF_DIR"

# Coletar info do git
BRANCH="(desconhecido)"
LAST_COMMIT="(desconhecido)"
MODIFIED_FILES=""

if git rev-parse --is-inside-work-tree &>/dev/null; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
  LAST_COMMIT=$(git log -1 --oneline 2>/dev/null || echo "(sem commits)")
  MODIFIED_FILES=$(git diff --name-only HEAD 2>/dev/null || echo "")
  if [[ -z "$MODIFIED_FILES" ]]; then
    MODIFIED_FILES=$(git diff --name-only --cached 2>/dev/null || echo "(nenhum)")
  fi
fi

# Session ID (usar PID do processo pai como proxy)
SESSION_ID="${PPID:-unknown}"

# Salvar handoff YAML
cat > "${HANDOFF_DIR}/handoff-${TIMESTAMP}.yaml" <<YAML
# Handoff - Pre-Compact
timestamp: "${TIMESTAMP}"
session_id: "${SESSION_ID}"
branch: "${BRANCH}"
last_commit: "${LAST_COMMIT}"
modified_files:
$(echo "$MODIFIED_FILES" | sed 's/^/  - /' | head -20)
project_root: "${PROJECT_ROOT}"
YAML

# Consolidar audits pendentes (listar o que existe)
if [[ -d "${PROJECT_ROOT}/audits" ]]; then
  AUDIT_COUNT=$(find "${PROJECT_ROOT}/audits" -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  if [[ $AUDIT_COUNT -gt 0 ]]; then
    echo "Handoff salvo. ${AUDIT_COUNT} audits existentes no projeto."
  fi
fi

exit 0
