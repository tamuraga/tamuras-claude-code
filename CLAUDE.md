# CLAUDE.md

Plugin privado para Claude Code com agentes especializados para workflow Next.js + Supabase + TypeScript.

## Estrutura

```
.claude-plugin/marketplace.json  # marketplace local
plugins/tamuras-claude-code/
  agents/    # agentes especializados (.md)
  hooks/     # scripts para hooks
  skills/    # skills invocaveis (/nome)
```

## Arquitetura

marketplace local em `.claude-plugin/marketplace.json` referencia plugins em `plugins/`.

agentes (`agents/*.md`): frontmatter com name, description, tools, model. corpo define persona, workflow e output format. invocados via Task tool quando prompt match description.

## Skills (4)

| nome | invocacao | funcao |
|------|-----------|--------|
| dev | `/dev` | regras de desenvolvimento Next.js + Supabase |
| git | `/git` | git workflow otimizado |
| gemini-fetch | `/gemini-fetch` | fetch via Gemini API |
| review-claudemd | `/review-claudemd` | analisa CLAUDE.md e sugere melhorias |

## Agentes (10)

### build
| nome | trigger | funcao | modelo |
|------|---------|--------|--------|
| fullstack-builder | "build feature", "criar feature" | end-to-end DB -> API -> UI | opus |
| frontend | "frontend", "componente", "ui" | React + Tailwind + shadcn | sonnet |

### review
| nome | trigger | funcao | modelo |
|------|---------|--------|--------|
| code-reviewer | "review code", "revisar PR" | review 5D: arch, security, perf, tests | opus |
| architecture | "arquitetura", "estrutura" | analisa e sugere melhorias arquiteturais | sonnet |

### exploration & planning
| nome | trigger | funcao | modelo |
|------|---------|--------|--------|
| codebase-explorer | "explorar codigo", "mapear estrutura" | explora codebase, usa Memento | haiku |
| task-planner | "quebrar tarefas", "task breakdown" | quebra planos em tarefas executaveis | sonnet |

### testing
| nome | trigger | funcao | modelo |
|------|---------|--------|--------|
| test-planner | "plan tests", "mapear jornadas" | explora app, gera plano de testes | sonnet |

### audit
| nome | trigger | funcao | modelo |
|------|---------|--------|--------|
| security | "security audit", "OWASP", "RLS" | OWASP Top 10, AI guardrails | sonnet |
| visual-researcher | "referencias UI", "Dribbble" | curadoria Dribbble/Behance/Figma | sonnet |

### devops
| nome | trigger | funcao | modelo |
|------|---------|--------|--------|
| context-cleaner | "limpar cache", "cleanup" | limpa cache ~/.claude/ | haiku |

## Filosofia

- agentes sao consultivos: analisam, documentam, geram plano
- usuario aprova e executa fixes na thread principal
- outputs versionados em `audits/[tipo]/YYYY-MM-DD_HH-MM-SS.md`
- HEADER OBRIGATORIO: `**Gerado em:** YYYY-MM-DD HH:MM:SS`
- agentes leem docs existentes antes de glob/grep

## Hooks (14 scripts)

### lifecycle
| hook | evento | funcao |
|------|--------|--------|
| session-start.sh | SessionStart | injeta CLAUDE.md, README, docs/*, audits/*, git log |
| prompt-submit.sh | UserPromptSubmit | lembrete de contexto + anti-exploracao |
| subagent-start.sh | SubagentStart | injeta contexto em subagentes |
| subagent-stop.sh | SubagentStop | consolida resultado de Explore em audits/ |
| precompact.sh | PreCompact | salva handoff YAML antes de compactar |
| session-end.sh | SessionEnd | ledger + handoff + atualiza docs |
| notification.sh | Notification | notificacao macOS nativa |

### pretool (7 matchers)
| hook | matcher | funcao |
|------|---------|--------|
| pretool-supabase.sh | `mcp__supabase__` | BLOQUEIA list_tables, SQL destrutivo; injeta regras RLS |
| pretool-playwright.sh | `mcp__playwright__` | contexto fechado, minimiza acoes |
| pretool-context7.sh | `mcp__context7__` | injeta versoes do package.json |
| pretool-fetch.sh | `WebFetch\|WebSearch` | injeta data atual nas buscas |
| pretool-explore.sh | `Task` | injeta contexto e foca subagente Explore |
| pretool-bash-guard.sh | `Bash` | ⚠️ BLOQUEIA rm -rf, sudo, DROP, git push --force |
| pretool-mcp-limiter.sh | `mcp__` | rate-limit MCPs pesados (browser) |

ordem dos matchers: especificos primeiro (`mcp__supabase__`), genericos por ultimo (`mcp__`).

## Novo Agente

criar `plugins/tamuras-claude-code/agents/nome.md` com frontmatter (name, description, tools, model) e corpo (persona, workflow, output format).

## Otimizacao

hooks injetam contexto automaticamente (CLAUDE.md, docs, audits, git log) para reduzir exploracoes. agentes recebem contexto no SubagentStart. ver `docs/TOKEN-OPTIMIZATION.md` para detalhes.
