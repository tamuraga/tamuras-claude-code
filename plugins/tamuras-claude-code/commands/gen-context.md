---
name: gen-context
description: Gera docs/ai-context/ com estrutura do projeto. Use apenas se projeto NAO tiver docs/ estruturado.
---

**IMPORTANTE**: Este comando e um FALLBACK para projetos sem documentacao estruturada.

## Quando usar
- Projeto **NAO** tem `docs/` organizado
- Projeto **NAO** tem CLAUDE.md com tabela de referencias

## Quando NAO usar
- Projeto ja tem `docs/arquitetura/`, `docs/setup/`, etc
- CLAUDE.md ja referencia docs existentes

---

Voce deve gerar arquivos de contexto pre-computado para otimizar uso de tokens.

## Workflow

1. Criar diretorio `docs/ai-context/` se nao existir
2. Gerar `project-structure.md` com:
   - Tech stack (detectar package.json, Cargo.toml, etc)
   - Arvore de diretorios (3 niveis, ignorando node_modules/.git/dist/.next)
   - Arquivos-chave por categoria (config, src, tests)
3. Gerar `docs-overview.md` com:
   - Lista de docs existentes em `docs/`
   - Referencias para cada doc com descricao curta

## Comandos

```bash
mkdir -p docs/ai-context

tree -L 3 -I 'node_modules|.git|dist|.next|coverage|.turbo|.vercel' --dirsfirst
```

## Output: project-structure.md

```markdown
# Project Structure

**Gerado em:** YYYY-MM-DD HH:MM:SS

## Tech Stack
- Framework: [detectado]
- Language: [detectado]
- Database: [detectado]

## Directory Tree
\`\`\`
[output do tree]
\`\`\`

## Key Files
| Categoria | Arquivo | Proposito |
|-----------|---------|-----------|
| Config | package.json | Dependencies |
| Config | tsconfig.json | TypeScript config |
| Entry | src/app/layout.tsx | Root layout |
| DB | supabase/migrations/ | Database schema |
```

## Output: docs-overview.md

```markdown
# Documentation Overview

**Gerado em:** YYYY-MM-DD HH:MM:SS

## Available Docs
| Doc | Path | Conteudo |
|-----|------|----------|
| API | @docs/api.md | Endpoints e contracts |
| DB Schema | @docs/db-schema.md | Tabelas e relacoes |
```

## Regras

- Se `docs/ai-context/` ja existir, perguntar antes de sobrescrever
- Detectar stack automaticamente (Next.js, Vite, NestJS, etc)
- Manter arquivos concisos (< 200 linhas cada)
- Usar formato tabular para facilitar scan rapido
