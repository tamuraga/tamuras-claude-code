#!/bin/bash
# Hook: SessionStart - Injeta audit de exploração no contexto
# Roda automaticamente ao iniciar sessão em QUALQUER projeto
# Detecta o projeto via pwd, busca audits/exploration/LATEST.yaml

PROJECT_DIR="$(pwd)"
AUDIT_FILE="$PROJECT_DIR/audits/exploration/LATEST.yaml"

# Se não existe audit, sair silenciosamente
[ ! -f "$AUDIT_FILE" ] && exit 0

# Extrair git_ref do audit
AUDIT_REF=$(grep '^git_ref:' "$AUDIT_FILE" | cut -d' ' -f2)
CURRENT_REF=$(git rev-parse --short HEAD 2>/dev/null)

# Se não estamos num repo git, apenas injetar o audit
if [ -z "$CURRENT_REF" ]; then
    echo "---"
    cat "$AUDIT_FILE"
    exit 0
fi

# Verificar staleness
if [ "$AUDIT_REF" = "$CURRENT_REF" ]; then
    # Audit atualizado - injetar com instrução diretiva
    echo "# Contexto do projeto (ref: $AUDIT_REF)"
    echo "INSTRUCAO: NAO explore arquivos listados abaixo. Use este contexto."
    echo "Explore APENAS se o usuario pedir algo NAO coberto aqui."
    echo "---"
    cat "$AUDIT_FILE"
else
    # Audit desatualizado - injetar + listar diff
    echo "# Contexto do projeto (ref: $AUDIT_REF) - DESATUALIZADO (HEAD: $CURRENT_REF)"
    echo "INSTRUCAO: Use este contexto como base. Explore APENAS os arquivos modificados:"
    DIFF_FILES=$(git diff --name-only "$AUDIT_REF"..HEAD 2>/dev/null)
    if [ -n "$DIFF_FILES" ]; then
        echo "$DIFF_FILES"
    else
        echo "(diff indisponivel - explore incrementalmente)"
    fi
    echo "---"
    cat "$AUDIT_FILE"
fi
