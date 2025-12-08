# Architecture

**Gerado em:** 2025-12-08 13:45:00

## Overview

Plugin privado para Claude Code com agentes e comandos especializados.

## Directory Structure

```
tamuras-claude-code/
├── .claude-plugin/
│   └── marketplace.json      # Registry local
├── plugins/
│   └── tamuras-claude-code/
│       ├── commands/         # Slash commands
│       │   ├── qa.md
│       │   ├── worktree.md
│       │   └── gen-context.md
│       ├── agents/           # Subagents especializados
│       │   ├── performance.md
│       │   ├── security.md
│       │   ├── responsive.md
│       │   └── visual-research.md
│       └── hooks/
│           └── inject-context.sh
├── docs/
│   ├── ARCHITECTURE.md       # Este arquivo
│   └── TOKEN-OPTIMIZATION.md # Estrategias de otimizacao
└── CLAUDE.md                 # Entry point para agentes
```

## Components

### Commands (Slash)

| Command | Arquivo | Trigger |
|---------|---------|---------|
| `/qa` | commands/qa.md | QA checklist adaptativo |
| `/worktree` | commands/worktree.md | Git worktrees |
| `/gen-context` | commands/gen-context.md | Fallback para projetos sem docs |

### Agents (Subagents)

| Agent | Arquivo | Tools | Model |
|-------|---------|-------|-------|
| performance | agents/performance.md | Bash, Glob, Grep, Read, Write | sonnet |
| security | agents/security.md | Glob, Grep, Read, Write | sonnet |
| responsive | agents/responsive.md | Glob, Grep, Read, Write, Playwright | sonnet |
| visual-research | agents/visual-research.md | WebSearch, WebFetch, Read, Write, Playwright | sonnet |

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
Commands registrados em /
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

## Design Decisions

| Decisao | Razao |
|---------|-------|
| Agentes consultivos | Usuario aprova antes de executar fixes |
| Pre-Context obrigatorio | Reduz tokens evitando glob/grep redundantes |
| Fallback gen-context | Suporta projetos sem docs estruturado |
| Timestamp no filename | Permite multiplas audits por dia |
