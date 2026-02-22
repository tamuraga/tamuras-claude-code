# Review CLAUDE.md

Analise todos os arquivos CLAUDE.md deste projeto e sugira melhorias.

## Workflow

### Fase 1: Coletar CLAUDE.md files

Busque todos os arquivos CLAUDE.md do projeto:

```
Glob("**/CLAUDE.md")
Glob("**/.claude-plugin/CLAUDE.md")
```

Leia cada um completamente.

### Fase 2: Analisar Projeto Real

Verifique o estado real do projeto para comparar com o que os CLAUDE.md descrevem:

1. **Agentes existentes**: `Glob("plugins/*/agents/*.md")` - compare com tabela de agentes
2. **Skills existentes**: `Glob("plugins/*/skills/*/SKILL.md")` - compare com contagem declarada
3. **Hooks existentes**: `Glob("plugins/*/hooks/*.sh")` - compare com tabela de hooks
4. **Stack real**: Leia `package.json` (se existir) para validar dependencias mencionadas
5. **Estrutura real**: `Bash("ls -la")` no root para validar arvore descrita

### Fase 3: Diagnosticar Problemas

Verifique cada CLAUDE.md para:

| Problema | Como Detectar |
|----------|---------------|
| **Tamanho excessivo** | >150 linhas = alerta amarelo, >300 = vermelho |
| **Agentes fantasma** | Mencionados no CLAUDE.md mas sem arquivo .md correspondente |
| **Contagem desatualizada** | "18 agentes" mas so existem 9 no disco |
| **Instrucoes duplicadas** | Mesmo conteudo em CLAUDE.md root e sub-CLAUDE.md |
| **Info desatualizada** | Versoes, paths, nomes de arquivos que nao existem |
| **Falta de instrucoes** | Convencoes importantes do projeto nao documentadas |
| **Estrutura confusa** | Secoes sem heading, tabelas quebradas, formatacao inconsistente |

### Fase 4: Gerar Relatorio

Para cada problema encontrado, reporte:

```
## [Arquivo]: path/to/CLAUDE.md

### Problemas

| # | Linha | Tipo | Descricao | Sugestao |
|---|-------|------|-----------|----------|
| 1 | 27 | Contagem desatualizada | "18 agentes" mas existem 10 | Atualizar para "10 agentes" |
| 2 | 66-68 | Agente fantasma | test-runner mencionado mas nao existe | Remover ou criar agente |

### Metricas
- Linhas: X
- Secoes: X
- Score: X/10
```

## Output

Apresente o relatorio diretamente na conversa (nao gere arquivo).

Finalize com um resumo:

```
## Resumo

- **Arquivos analisados**: X
- **Problemas encontrados**: X
- **Criticos**: X (agentes fantasma, info incorreta)
- **Melhorias sugeridas**: X (organizacao, clareza)
```
