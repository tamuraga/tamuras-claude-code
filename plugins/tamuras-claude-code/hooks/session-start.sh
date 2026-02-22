#!/usr/bin/env bash
# Hook: SessionStart
# Injeta contexto completo do projeto ao iniciar sessao
set -euo pipefail

PROJECT_ROOT="${PWD}"

echo "=== CONTEXTO DO PROJETO (SessionStart) ==="
echo ""

# CLAUDE.md
if [[ -f "${PROJECT_ROOT}/CLAUDE.md" ]]; then
  echo "--- CLAUDE.md ---"
  cat "${PROJECT_ROOT}/CLAUDE.md"
  echo ""
fi

# README.md
if [[ -f "${PROJECT_ROOT}/README.md" ]]; then
  echo "--- README.md ---"
  cat "${PROJECT_ROOT}/README.md"
  echo ""
fi

# docs/* (conteudo completo)
if [[ -d "${PROJECT_ROOT}/docs" ]]; then
  echo "--- DOCS ---"
  find "${PROJECT_ROOT}/docs" -type f \( -name "*.md" -o -name "*.txt" -o -name "*.json" \) | sort | while read -r f; do
    rel="${f#${PROJECT_ROOT}/}"
    echo ""
    echo ">> ${rel}"
    cat "$f"
    echo ""
  done
fi

# audits/* (listagem apenas, nao conteudo completo)
if [[ -d "${PROJECT_ROOT}/audits" ]]; then
  echo "--- AUDITS (listagem) ---"
  find "${PROJECT_ROOT}/audits" -type f | sort | while read -r f; do
    rel="${f#${PROJECT_ROOT}/}"
    echo "  - ${rel}"
  done
  echo ""
fi

# Ultimos 2 commits
echo "--- GIT LOG (ultimos 2 commits) ---"
if git rev-parse --is-inside-work-tree &>/dev/null; then
  git log -2 --oneline 2>/dev/null || echo "(sem historico git)"
else
  echo "(nao e repositorio git)"
fi
echo ""
echo "=== FIM DO CONTEXTO ==="
