#!/bin/bash
# Hook: SessionStart - Injeta contexto pre-computado
# Uso: Configurar em settings.local.json do projeto alvo

CONTEXT_DIR="docs/ai-context"
STRUCTURE_FILE="$CONTEXT_DIR/project-structure.md"
OVERVIEW_FILE="$CONTEXT_DIR/docs-overview.md"

if [[ -f "$STRUCTURE_FILE" ]]; then
    echo "=== PROJECT CONTEXT (pre-computed) ==="
    echo ""
    cat "$STRUCTURE_FILE"
    echo ""

    if [[ -f "$OVERVIEW_FILE" ]]; then
        echo "=== DOCS OVERVIEW ==="
        echo ""
        cat "$OVERVIEW_FILE"
        echo ""
    fi

    echo "=== END CONTEXT ==="
else
    echo "[WARN] Context not found. Run: /gen-context"
fi
