# Git Rules

Aplique estas regras SEMPRE ao trabalhar com Git.

## REGRAS CRÍTICAS

### 1. Commit Message

- **MÁXIMO 50 caracteres** no título
- Conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
- **Minúsculo** após o prefixo
- **Sem ponto final**
- Sem emojis

**Válido:**
```
feat: add user authentication
fix: resolve login redirect bug
docs: update api documentation
refactor: simplify auth logic
```

**Inválido:**
```
feat: Add user authentication feature with OAuth support  (muito longo)
Fix: resolve bug  (maiúsculo)
feat: add feature.  (ponto final)
```

### 2. Verificar Usuário

SEMPRE executar antes de commits:

```bash
gh auth status
```

Se usuário incorreto → PARAR e alertar.

### 3. SEM Assinatura de IA

- **NUNCA** adicionar `Co-Authored-By: Claude`
- **NUNCA** mencionar IA no commit
- **NUNCA** mencionar IA no PR
- Commits devem parecer 100% humanos

### 4. Branch Naming

- `feature/` - novas features
- `bugfix/` - correções de bugs
- `hotfix/` - correções urgentes em prod
- `refactor/` - refatorações
- `docs/` - documentação

## Workflow

### Commit

```bash
# 1. Verificar usuário
gh auth status

# 2. Ver mudanças
git status
git diff

# 3. Stage
git add <files>

# 4. Commit (SEM Co-Authored-By!)
git commit -m "feat: short description"
```

### Pull Request

```bash
# 1. Push
git push -u origin <branch>

# 2. Criar PR (SEM menção de IA)
gh pr create --title "feat: description" --body "## Summary
- [bullet points]

## Test Plan
- [como testar]"
```

## Validações

Antes de cada commit:
- [ ] `gh auth status` executado
- [ ] Mensagem ≤ 50 caracteres
- [ ] Prefixo conventional commit
- [ ] Sem ponto final
- [ ] Minúsculo após prefixo
- [ ] SEM Co-Authored-By
- [ ] SEM menção de IA
