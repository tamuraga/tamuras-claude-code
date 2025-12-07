---
name: qa
description: Executa checklist QA adaptativo do projeto. Busca QA.md, roda build/lint/types, lista pendencias.
---

Voce deve executar um QA completo do projeto atual.

## Workflow Adaptativo

1. **Descoberta:** Buscar arquivo QA com `glob **/QA.md` ou `**/CHECKLIST.md`
2. Se nao encontrar:
   - Perguntar: "Nao encontrei QA.md. Criar em docs/QA.md?"
   - Se sim, criar template basico
3. Se encontrar, ler e extrair pendencias `[ ]`

## Steps

1. **Build:** Executar `npm run build` ou `pnpm build`
2. **Lint:** Executar `npm run lint`
3. **Types:** Executar `npx tsc --noEmit`
4. **Pendencias:** Extrair itens `[ ]` do QA.md encontrado
5. **Migrations:** Contar arquivos em `supabase/migrations/`
6. **Relatorio:** Gerar sumario formatado

## Output Format

```
QA Report - [Projeto] - [Data]
================================
Build:      OK | FAIL
Lint:       X warnings
Types:      OK | X errors
Migrations: X arquivos

Pendencias (de QA.md):
- [ ] Item pendente 1
- [ ] Item pendente 2

Concluidos: X items
Pendentes:  X items
```

## Template QA.md (criar se nao existir)

```markdown
# QA - [Nome do Projeto]

**Ultima atualizacao:** [Data]

## Fase 1 - MVP
- [ ] Feature 1
- [ ] Feature 2

## Validacoes Tecnicas
- [ ] Build sem erros
- [ ] Lint sem warnings criticos
- [ ] Types OK
- [ ] RLS configurado em todas tabelas
```
