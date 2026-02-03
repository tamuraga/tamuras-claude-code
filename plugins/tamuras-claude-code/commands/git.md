# Commit Rules

Aplique estas regras SEMPRE ao fazer commits.

## Regras de Commit

### Mensagem
- **MAXIMO 80 caracteres** no titulo
- Conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
- **Minusculo** apos o prefixo
- **Sem ponto final**
- Sem emojis
- **SEM `Co-Authored-By`** ou mencao de IA

### Branch Naming (Gitflow)
- `feature/` - novas features
- `bugfix/` - correcoes de bugs
- `hotfix/` - correcoes urgentes em prod
- `release/` - preparacao de release
- `refactor/` - refatoracoes
- `docs/` - documentacao

### Organizacao por Arquivos
- Commits **atomicos**: 1 commit por preocupacao logica
- Se mudou 3 coisas diferentes, faca 3 commits separados
- Agrupar por funcionalidade, nao por tipo de arquivo

### Workflow
1. `gh auth status` (verificar usuario)
2. `git status` + `git diff` (entender mudancas)
3. Separar mudancas em commits logicos se necessario
4. Stage arquivos relacionados: `git add <files>`
5. Commit semantico: `git commit -m "tipo: descricao"`
6. **NUNCA** usar HEREDOC, `cat <<EOF`, ou mensagem multi-linha

### Exemplos validos
- `feat: add user authentication with OAuth` (42 chars)
- `fix: resolve login redirect loop on expired session` (52 chars)
- `refactor: extract validation logic to shared utils` (51 chars)
- `chore: update dependencies and fix peer warnings` (49 chars)

### Exemplos INVALIDOS
- `feat: Add X` (maiusculo apos prefixo)
- `fix: bug.` (ponto final)
- Mensagem > 80 chars
- `feat: stuff` (vago demais)

### Pull Request
```bash
git push -u origin <branch>
gh pr create --title "feat: description" --body "## Summary
- [bullet points]

## Test Plan
- [como testar]"
```

### Validacoes
- [ ] `gh auth status` executado
- [ ] Mensagem <= 80 caracteres
- [ ] Prefixo conventional commit
- [ ] Sem ponto final
- [ ] Minusculo apos prefixo
- [ ] SEM Co-Authored-By
- [ ] SEM mencao de IA
