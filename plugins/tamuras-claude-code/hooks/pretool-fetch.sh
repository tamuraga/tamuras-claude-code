#!/bin/bash
# Hook: PreToolUse - Injeta data atual antes de WebFetch/WebSearch
# Matcher: WebFetch, WebSearch

# Pegar data atual no fuso horário do Brasil (America/Sao_Paulo)
CURRENT_DATE=$(TZ="America/Sao_Paulo" date "+%Y-%m-%d %H:%M:%S")
CURRENT_YEAR=$(TZ="America/Sao_Paulo" date "+%Y")
CURRENT_MONTH=$(TZ="America/Sao_Paulo" date "+%B")
DAY_OF_WEEK=$(TZ="America/Sao_Paulo" date "+%A")

cat << EOF
# Contexto Temporal (Brasil)

**Data atual:** $CURRENT_DATE (America/Sao_Paulo)
**Ano:** $CURRENT_YEAR
**Mês:** $CURRENT_MONTH
**Dia da semana:** $DAY_OF_WEEK

IMPORTANT: Use $CURRENT_YEAR como ano atual em todas as buscas.
Se buscar documentação, eventos ou notícias, use "$CURRENT_YEAR" no query.

Exemplo: "React documentation $CURRENT_YEAR" ao invés de "React documentation"
EOF
