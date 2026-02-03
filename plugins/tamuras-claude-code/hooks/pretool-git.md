# Git Commit Rules

## OBRIGATORIO

### Mensagem de Commit
- IMPORTANT: Maximo 80 caracteres no titulo
- NUNCA incluir Co-Authored-By
- NUNCA mencionar IA, Claude, ou assistente
- Usar git semantico: feat:, fix:, docs:, refactor:, test:, chore:
- NUNCA usar HEREDOC, cat <<EOF, ou mensagem multi-linha

### Formato
```
<tipo>: <descricao curta>
```

### Exemplos Corretos
```
feat: add user authentication with OAuth
fix: resolve login redirect loop on expired session
docs: update README setup section
refactor: extract validation logic to shared utils
```

### Exemplos Errados
```
feat: add user login form with validation and error handling and tests and documentation (MUITO LONGO)
Added new feature (SEM TIPO SEMANTICO)
feat: Add X (MAIUSCULO APOS PREFIXO)
fix: bug. (PONTO FINAL)

Co-Authored-By: Claude <...> (PROIBIDO)
```

## Checklist Pre-Commit
- [ ] Titulo tem menos de 80 caracteres?
- [ ] Usa tipo semantico (feat/fix/docs/etc)?
- [ ] Sem mencao de IA ou Co-Authored-By?
- [ ] Sem --amend (a menos que explicitamente pedido)?
- [ ] Sem HEREDOC ou mensagem multi-linha?
