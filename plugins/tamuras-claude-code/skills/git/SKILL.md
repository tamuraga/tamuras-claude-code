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

### Validacoes
- [ ] `gh auth status` executado
- [ ] Mensagem <= 80 caracteres
- [ ] Prefixo conventional commit
- [ ] Sem ponto final
- [ ] Minusculo apos prefixo
- [ ] SEM Co-Authored-By
- [ ] SEM mencao de IA
