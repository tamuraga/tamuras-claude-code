# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Plugin privado para Claude Code com agentes e comandos especializados para workflow Next.js + Supabase + TypeScript.

## Estrutura

```
.claude-plugin/marketplace.json  # Configuracao do marketplace local
plugins/tamuras-claude-code/
  commands/                      # Slash commands (.md)
  agents/                        # Agentes especializados (.md)
  hooks/                         # Scripts para hooks
```

## Arquitetura do Plugin

**Marketplace local** em `.claude-plugin/marketplace.json` referencia plugins em `plugins/`.

**Comandos** (`commands/*.md`):
- Frontmatter YAML com `name`, `description`
- Corpo define o prompt expandido ao executar `/comando`

**Agentes** (`agents/*.md`):
- Frontmatter com `name`, `description`, `tools`, `model`
- Corpo define persona, workflow e output format
- Invocados automaticamente via Task tool quando prompt do usuario match description

## Componentes

| Tipo | Nome | Trigger |
|------|------|---------|
| Comando | `/qa` | QA checklist adaptativo |
| Comando | `/worktree` | Gerencia git worktrees |
| Comando | `/gen-context` | Gera docs/ai-context/ para otimizar tokens |
| Agente | `performance` | "audit performance", "lighthouse" |
| Agente | `security` | "security audit", "OWASP", "RLS" |
| Agente | `responsive` | "check mobile", "responsividade" |
| Agente | `visual-research` | "pesquisa visual", "moodboard" |

## Filosofia

- Agentes sao **consultivos**: analisam, documentam, geram plano
- Usuario **aprova** e executa fixes na thread principal
- Outputs versionados em `audits/[tipo]/YYYY-MM-DD_HH-MM-SS.md`
- Header obrigatorio: `**Gerado em:** YYYY-MM-DD HH:MM:SS`
- **Pre-Context**: Agentes leem docs existentes antes de glob/grep

## Instalacao do Plugin

```bash
/plugin marketplace add /home/gabrieltamura/Apps/active/tamuras-claude-code
/plugin install tamuras-claude-code
```

## Adicionando Novos Comandos

Criar `plugins/tamuras-claude-code/commands/nome.md`:
```markdown
---
name: nome
description: Descricao curta para o registro
---

Prompt expandido aqui...
```

## Adicionando Novos Agentes

Criar `plugins/tamuras-claude-code/agents/nome.md`:
```markdown
---
name: nome
description: Triggers naturais do usuario
tools: Bash, Glob, Grep, Read, Write
model: sonnet
---

Voce e um [Persona]. [Objetivo].

## Workflow
1. ...

## Output Format
Gere arquivo em `audits/[tipo]/YYYY-MM-DD_HH-MM-SS.md`
```

## Otimizacao de Tokens

Agentes usam **Pre-Context** para reduzir glob/grep:

### Projetos com docs/ estruturado (recomendado)
Agentes leem automaticamente:
1. `CLAUDE.md` do projeto (raiz ou .claude/)
2. Tabela de referencias para `docs/`
3. Docs relevantes (`docs/arquitetura/`, `docs/setup/`)

### Projetos sem docs/ estruturado (fallback)
```bash
/gen-context
```
Cria `docs/ai-context/project-structure.md` e `docs-overview.md`

### Hook opcional
Em `settings.local.json` do projeto:
```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "/path/to/plugin/hooks/inject-context.sh"
      }]
    }]
  }
}
```
