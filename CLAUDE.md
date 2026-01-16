# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Plugin privado para Claude Code com agentes especializados para workflow Next.js + Supabase + TypeScript.

## Estrutura

```
.claude-plugin/marketplace.json  # Configuracao do marketplace local
plugins/tamuras-claude-code/
  agents/                        # Agentes especializados (.md)
  hooks/                         # Scripts para hooks
```

## Arquitetura do Plugin

**Marketplace local** em `.claude-plugin/marketplace.json` referencia plugins em `plugins/`.

**Agentes** (`agents/*.md`):
- Frontmatter com `name`, `description`, `tools`, `model`
- Corpo define persona, workflow e output format
- Invocados automaticamente via Task tool quando prompt do usuario match description

## Agentes (18 total)

### Development (Build)
| Nome | Trigger | Funcao | Modelo |
|------|---------|--------|--------|
| `fullstack-builder` | "build feature", "criar feature" | Implementa features end-to-end (DB → API → UI) | Opus |
| `frontend` | "frontend", "componente", "ui" | Cria componentes React + Tailwind + shadcn | Sonnet |

### Quality (Review)
| Nome | Trigger | Funcao | Modelo |
|------|---------|--------|--------|
| `code-reviewer` | "review code", "revisar PR" | Review 5D: arch, security, perf, tests | Opus |
| `code-reviewer-tester` | "review", "testes e2e", "smoke test" | Review + gera testes e2e/smoke | Sonnet |
| `architecture` | "arquitetura", "estrutura" | Analisa e sugere melhorias arquiteturais | Sonnet |

### Exploration & Planning
| Nome | Trigger | Funcao | Modelo |
|------|---------|--------|--------|
| `codebase-explorer` | "explorar código", "mapear estrutura" | Explora codebase otimizado, usa Memento | Haiku |
| `task-planner` | "quebrar tarefas", "task breakdown" | Quebra planos em tarefas executáveis | Sonnet |

### Git & DevOps
| Nome | Trigger | Funcao | Modelo |
|------|---------|--------|--------|
| `git` | "git", "commit", "push", "pr" | Git workflow (max 50 chars, sem Co-Authored-By) | Haiku |
| `context-cleaner` | "limpar cache", "cleanup" | Limpa cache ~/.claude/ (debug, plans, todos) | Haiku |

### Auditoria
| Nome | Trigger | Funcao |
|------|---------|--------|
| `performance` | "audit performance", "lighthouse" | Core Web Vitals, bundle size |
| `security` | "security audit", "OWASP", "RLS" | OWASP Top 10, AI guardrails |
| `responsive` | "check mobile", "responsividade" | Mobile-first, breakpoints |
| `visual-research` | "pesquisa visual", "moodboard" | Moodboards, referências |
| `visual-researcher` | "referências UI", "Dribbble" | Curadoria Dribbble/Behance/Figma |

### Testing (Pipeline de 3 Agents)
| Nome | Trigger | Funcao |
|------|---------|--------|
| `test-planner` | "plan tests", "mapear jornadas" | Explora app, gera plano em Markdown |
| `test-runner` | "run tests", "executar testes" | Executa jornadas, valida UI + DB |
| `test-healer` | "fix tests", "heal tests" | Auto-repara testes quebrados |

### Fluxo Completo de Desenvolvimento
```
┌─────────────────────────────────────────────────────────────┐
│  1. BUILD                                                   │
│     fullstack-builder → Implementa feature                  │
│     db-architect → Cria migrations                          │
├─────────────────────────────────────────────────────────────┤
│  2. REVIEW                                                  │
│     code-reviewer → Review multi-dimensional                │
│     security → Audit de seguranca + AI guardrails           │
├─────────────────────────────────────────────────────────────┤
│  3. TEST                                                    │
│     test-planner → Gera plano                               │
│     test-runner → Executa, valida UI + DB                   │
│     test-healer → Auto-repara falhas                        │
├─────────────────────────────────────────────────────────────┤
│  4. OPTIMIZE                                                │
│     performance → Audit de performance                      │
│     prompt-optimizer → Melhora prompts/CLAUDE.md            │
└─────────────────────────────────────────────────────────────┘
```

## Filosofia

- Agentes sao **consultivos**: analisam, documentam, geram plano
- Usuario **aprova** e executa fixes na thread principal
- Outputs versionados em `audits/[tipo]/YYYY-MM-DD_HH-MM-SS.md`
- Header obrigatorio: `**Gerado em:** YYYY-MM-DD HH:MM:SS`
- **Pre-Context**: Agentes leem docs existentes antes de glob/grep

## Instalacao do Plugin

```bash
/plugin marketplace add /Users/eugtamura/Dev/tamuras-claude-code
/plugin install tamuras-claude-code
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
Agentes tentam ler `docs/ai-context/project-structure.md` e `docs/ai-context/docs-overview.md` se existirem.

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
