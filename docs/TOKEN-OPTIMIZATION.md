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

## System Prompt Patching

Claude Code permite sobrescrever partes do system prompt via `CLAUDE.md`, reduzindo overhead em ~50%.

### Como funciona
- Instrucoes no `CLAUDE.md` tem prioridade sobre defaults do Claude Code
- Evita duplicacao entre system prompt padrao e instrucoes customizadas
- Resultado: menos tokens no context window = mais espaco para codigo

### Boas praticas
- Manter `CLAUDE.md` conciso (<150 linhas no root)
- Usar sub-CLAUDE.md em subdiretorios para contexto localizado
- Revisar periodicamente com `/review-claudemd` para remover duplicacoes

## Lazy-Load MCP Tools

MCP servers carregam todas as tools no startup, consumindo tokens do context.

### Otimizacao

```bash
# Ativa lazy-load: tools so aparecem quando relevantes
export ENABLE_TOOL_SEARCH=true
```

**Impacto**: Reduz context window inicial significativamente em projetos com muitos MCP servers (Supabase, Playwright, Context7, etc).

### Quando usar
- Projeto com 3+ MCP servers configurados
- Context window ficando apertado em sessoes longas
- Agentes especializados que so precisam de subset de tools

## Subagents em Background

Tasks longas podem rodar em background, liberando a thread principal.

### Pattern

```
Task tool com run_in_background: true
  → Agente roda independente
  → Resultado disponivel via TaskOutput
  → Thread principal continua livre
```

### Casos de uso
- Auditorias (performance, security) enquanto desenvolve
- Exploracao de codebase enquanto implementa
- Multiplos reviews em paralelo

### Cuidados
- Background agents nao tem acesso ao contexto atualizado da thread principal
- Resultados precisam ser verificados quando coletados
- Evitar mais de 3 agents simultaneos (overhead de coordenacao)

## Estabilidade com DISABLE_AUTOUPDATER

```bash
export DISABLE_AUTOUPDATER=1
```

**Por que**: Atualizacoes automaticas podem invalidar patches e customizacoes no system prompt. Desabilitar garante estabilidade entre sessoes.

### Quando usar
- Apos aplicar patches no system prompt via CLAUDE.md
- Em projetos com hooks customizados que dependem de behavior especifico
- Durante sprints criticos onde estabilidade > features novas

## Referencias

- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Claude Code Development Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code)
