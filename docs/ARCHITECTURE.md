# Architecture

**Gerado em:** 2026-01-08 12:00:00

## Overview

Plugin privado para Claude Code com 11 agentes especializados para workflow Next.js + Supabase + TypeScript.

## Directory Structure

```
tamuras-claude-code/
├── .claude-plugin/
│   └── marketplace.json      # Registry local
├── plugins/
│   └── tamuras-claude-code/
│       ├── .claude-plugin/
│       │   └── plugin.json   # Configuracao do plugin
│       ├── agents/           # 11 Subagents especializados
│       │   ├── fullstack-builder.md
│       │   ├── db-architect.md
│       │   ├── code-reviewer.md
│       │   ├── prompt-optimizer.md
│       │   ├── performance.md
│       │   ├── security.md
│       │   ├── responsive.md
│       │   ├── visual-research.md
│       │   ├── test-planner.md
│       │   ├── test-runner.md
│       │   └── test-healer.md
│       └── hooks/
│           └── inject-context.sh
├── docs/
│   ├── ARCHITECTURE.md       # Este arquivo
│   └── TOKEN-OPTIMIZATION.md # Estrategias de otimizacao
└── CLAUDE.md                 # Entry point para agentes
```

## Agents (11 total)

### Development (Build)

| Agent | Arquivo | Tools | Funcao |
|-------|---------|-------|--------|
| fullstack-builder | agents/fullstack-builder.md | Bash, Glob, Grep, Read, Write, Edit | Implementa features end-to-end (DB → API → UI) |
| db-architect | agents/db-architect.md | Glob, Grep, Read, Write, Bash, Supabase MCP | Migrations seguras, RLS, performance |

### Quality (Review)

| Agent | Arquivo | Tools | Funcao |
|-------|---------|-------|--------|
| code-reviewer | agents/code-reviewer.md | Glob, Grep, Read, Write, Bash | Review 5D: arch, security, perf, tests, reliability |
| prompt-optimizer | agents/prompt-optimizer.md | Glob, Grep, Read, Write | Analisa falhas LLM, melhora CLAUDE.md |

### Auditoria

| Agent | Arquivo | Tools | Funcao |
|-------|---------|-------|--------|
| performance | agents/performance.md | Bash, Glob, Grep, Read, Write | Audit Core Web Vitals, bundle |
| security | agents/security.md | Glob, Grep, Read, Write | OWASP, RLS, AI guardrails |
| responsive | agents/responsive.md | Glob, Grep, Read, Write, Playwright | Breakpoints, touch, mobile |
| visual-research | agents/visual-research.md | WebSearch, WebFetch, Read, Write, Playwright | Moodboards, referencias |

### Testing Pipeline (Playwright + Supabase MCP)

| Agent | Arquivo | Tools | Funcao |
|-------|---------|-------|--------|
| test-planner | agents/test-planner.md | Glob, Grep, Read, Write, Playwright, Supabase | Explora app, gera plano de testes |
| test-runner | agents/test-runner.md | Bash, Glob, Grep, Read, Write, Playwright, Supabase | Executa jornadas, valida UI + DB |
| test-healer | agents/test-healer.md | Glob, Grep, Read, Write, Playwright, Supabase | Auto-repara testes quebrados |

### Testing Pipeline Flow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  test-planner   │────▶│   test-runner   │────▶│   test-healer   │
│                 │     │                 │     │                 │
│ - Explora app   │     │ - Executa specs │     │ - Analisa falhas│
│ - Identifica    │     │ - Valida UI+DB  │     │ - Propoe fixes  │
│   jornadas      │     │ - Screenshots   │     │ - Auto-repara   │
│ - Gera plano MD │     │ - Gera report   │     │ - Re-valida     │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │
        ▼                       ▼                       ▼
  test-plans/            audits/testing/         audits/healing/
  [feature]/             [role]/                 YYYY-MM-DD.md
  YYYY-MM-DD.md          YYYY-MM-DD.md
```

### Hooks

| Hook | Arquivo | Event |
|------|---------|-------|
| inject-context | hooks/inject-context.sh | SessionStart |

## Data Flow

```
Usuario instala plugin
        ↓
/plugin marketplace add [path]
/plugin install tamuras-claude-code
        ↓
Agents disponiveis via Task tool
        ↓
Usuario trigger ("audit performance")
        ↓
Agent inicia com Pre-Context:
  1. Le CLAUDE.md do projeto
  2. Identifica docs/
  3. Le docs relevantes
  4. So faz glob/grep se necessario
        ↓
Gera audit em audits/[tipo]/YYYY-MM-DD_HH-MM-SS.md
```

## Fluxo Completo de Desenvolvimento

```
┌─────────────────────────────────────────────────────────────┐
│  1. BUILD                                                   │
│     fullstack-builder → Implementa feature (DB → API → UI) │
│     db-architect → Cria migrations seguras + RLS            │
├─────────────────────────────────────────────────────────────┤
│  2. REVIEW                                                  │
│     code-reviewer → Review 5D (arch, sec, perf, test, rel) │
│     security → Audit OWASP + AI guardrails                  │
├─────────────────────────────────────────────────────────────┤
│  3. TEST                                                    │
│     test-planner → Gera plano de jornadas                   │
│     test-runner → Executa, valida UI + DB                   │
│     test-healer → Auto-repara falhas                        │
├─────────────────────────────────────────────────────────────┤
│  4. OPTIMIZE                                                │
│     performance → Audit Core Web Vitals                     │
│     prompt-optimizer → Melhora prompts/CLAUDE.md            │
└─────────────────────────────────────────────────────────────┘
```

## Design Decisions

| Decisao | Razao |
|---------|-------|
| Agentes consultivos | Usuario aprova antes de executar fixes |
| Pre-Context obrigatorio | Reduz tokens evitando glob/grep redundantes |
| Fallback ai-context | Suporta projetos sem docs estruturado |
| Timestamp no filename | Permite multiplas audits por dia |
| Fullstack vs separado | Backend + Frontend juntos reduz problemas de integracao |
| 3 agents de teste | Separa responsabilidades: planejar, executar, corrigir |
| Type-safe com Zod | Schema como single source of truth para tipos |
