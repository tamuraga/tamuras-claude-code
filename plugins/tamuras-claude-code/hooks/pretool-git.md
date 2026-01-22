# Git Commit Rules

## OBRIGATÓRIO

### Mensagem de Commit
- IMPORTANT: Máximo 50 caracteres no título
- NUNCA incluir Co-Authored-By
- NUNCA mencionar IA, Claude, ou assistente
- Usar git semântico: feat:, fix:, docs:, refactor:, test:, chore:

### Formato
```
<tipo>: <descrição curta>

[corpo opcional - max 72 chars por linha]
```

### Exemplos Corretos
```
feat: add user login form
fix: resolve null pointer in auth
docs: update README setup section
refactor: simplify date parsing
```

### Exemplos Errados
```
feat: add user login form with validation and error handling (MUITO LONGO)
Added new feature (SEM TIPO SEMÂNTICO)
fix: resolve bug

Co-Authored-By: Claude <...> (PROIBIDO)
```

## Checklist Pré-Commit
- [ ] Título tem menos de 50 caracteres?
- [ ] Usa tipo semântico (feat/fix/docs/etc)?
- [ ] Sem menção de IA ou Co-Authored-By?
- [ ] Sem --amend (a menos que explicitamente pedido)?
