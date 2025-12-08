# Token Optimization

**Gerado em:** 2025-12-08 13:45:00

## Problema

Agentes gastam tokens excessivos com glob/grep para descobrir estrutura do projeto.

## Solucao: Pre-Context

Agentes leem documentacao existente antes de explorar.

### Fluxo Otimizado

```
Agente inicia
    ↓
1. Le CLAUDE.md do projeto
    ↓
2. Identifica tabela de docs (se existir)
    ↓
3. Le docs relevantes para a tarefa:
   - performance: DATABASE.md, API.md
   - security: DATABASE.md, SERVER_ACTIONS.md, SECURITY.md
   - responsive: UI_COMPONENTS.md, MOBILE.md
   - visual-research: UI_COMPONENTS.md, MAIN.md
    ↓
4. So faz glob/grep se info nao documentada
    ↓
Economia estimada: 40-60% tokens
```

## Cenarios

### Projeto com docs/ estruturado

```
projeto/
├── CLAUDE.md (com tabela de refs)
├── docs/
│   ├── arquitetura/
│   │   ├── DATABASE.md
│   │   ├── API.md
│   │   └── ...
│   └── setup/
│       ├── SECURITY.md
│       └── ...
```

**Fluxo**: Agente le docs existentes, zero glob inicial.

### Projeto sem docs/ (fallback)

```bash
/gen-context
```

Gera:
- `docs/ai-context/project-structure.md` - arvore + stack
- `docs/ai-context/docs-overview.md` - indice de docs

## Hook SessionStart (opcional)

Injeta contexto no inicio da sessao:

```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "/path/to/hooks/inject-context.sh"
      }]
    }]
  }
}
```

## Tecnicas Complementares

| Tecnica | Economia | Quando usar |
|---------|----------|-------------|
| Pre-Context docs | 40-60% | Sempre |
| Model tiering (haiku) | 40-60% | Exploracao simples |
| Markdown como memoria | 50-60% | Subagents em cadeia |
| /clear + catchup | Preserva contexto | Sessoes longas |

## Referencias

- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Claude Code Development Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code)
