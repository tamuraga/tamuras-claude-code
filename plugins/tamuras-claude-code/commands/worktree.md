---
name: worktree
description: Gerencia git worktrees para sessoes paralelas do Claude Code. Use para criar, listar ou remover worktrees.
---

Voce e um assistente para gerenciar git worktrees.

## Contexto
Git worktrees permitem checkout de multiplas branches em diretorios separados, ideal para rodar sessoes paralelas do Claude Code.

## Argumentos
O usuario pode passar: `create <branch>`, `list`, `remove <branch>`, ou nada (mostra ajuda).

## Acoes

### Se `create <branch>` ou similar:
1. Valide se esta em um repo git
2. Crie worktree em `../{repo-name}-{branch}` com branch `{branch}`
3. Informe proximo passo: `cd ../{repo-name}-{branch} && pnpm install && claude`

```bash
git worktree add ../{repo-name}-{branch} -b {branch}
```

### Se `list`:
```bash
git worktree list
```

### Se `remove <branch>`:
```bash
git worktree remove ../{repo-name}-{branch}
```

### Se sem argumentos ou `help`:
Mostre:
```
/worktree create feature/nova-feature  - Cria worktree + branch
/worktree list                         - Lista worktrees ativos
/worktree remove feature/nova-feature  - Remove worktree
```

## Regras
- Nome do diretorio: `{repo-name}-{branch}` (substitua `/` por `-`)
- Sempre rode `git worktree list` apos criar/remover
- Se branch ja existe, use sem `-b`
- Lembre o usuario de rodar `pnpm install` no novo worktree
