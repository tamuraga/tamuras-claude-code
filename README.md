# tamuras-claude-code

Custom AI agents, hooks, and skills for Claude Code. Optimized for Next.js + Supabase + TypeScript workflows.

## What is this?

A plugin for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that adds:

- **10 specialized agents** — architecture review, security audit, fullstack builder, test planning, and more
- **4 slash commands** — `/dev`, `/git`, `/gemini-fetch`, `/review-claudemd`
- **14 hooks** — automatic context injection, safety guards, token optimization

## Installation

```bash
# Clone the repo
git clone https://github.com/tamuraga/tamuras-claude-code.git

# Add as a local plugin source
/plugin marketplace add /path/to/tamuras-claude-code

# Install
/plugin install tamuras-claude-code
```

## Structure

```
plugins/tamuras-claude-code/
  agents/    # specialized agents (.md)
  hooks/     # lifecycle & pretool scripts
  skills/    # slash commands (/name)
docs/        # architecture, token optimization
```

## Agents

Agents are consultive — they analyze, document, and generate plans. The user approves and executes in the main thread.

| Agent | Trigger | What it does | Model |
|-------|---------|--------------|-------|
| fullstack-builder | "build feature", "criar feature" | End-to-end DB → API → UI | opus |
| frontend | "frontend", "componente", "ui" | React + Tailwind + shadcn | sonnet |
| code-reviewer | "review code", "revisar PR" | 5-dimensional review (arch, security, perf, tests, reliability) | opus |
| architecture | "arquitetura", "estrutura" | Architectural analysis and suggestions | sonnet |
| codebase-explorer | "explorar codigo", "mapear estrutura" | Codebase exploration with Memento | haiku |
| task-planner | "quebrar tarefas", "task breakdown" | Breaks plans into executable tasks | sonnet |
| test-planner | "plan tests", "mapear jornadas" | Explores app, generates test plan | sonnet |
| security | "security audit", "OWASP", "RLS" | OWASP Top 10, AI guardrails | sonnet |
| visual-researcher | "referencias UI", "Dribbble" | UI curation from Dribbble/Behance/Figma | sonnet |
| context-cleaner | "limpar cache", "cleanup" | Cleans ~/.claude/ cache | haiku |

## Skills

| Command | Description |
|---------|-------------|
| `/dev` | Next.js + Supabase development rules |
| `/git` | Optimized git workflow |
| `/gemini-fetch` | Web fetch via Gemini API |
| `/review-claudemd` | Analyzes CLAUDE.md and suggests improvements |

## Hooks

### Lifecycle

| Hook | Event | Purpose |
|------|-------|---------|
| session-start.sh | SessionStart | Injects CLAUDE.md, README, docs, audits, git log |
| prompt-submit.sh | UserPromptSubmit | Context reminder + anti-exploration |
| subagent-start.sh | SubagentStart | Injects context into subagents |
| subagent-stop.sh | SubagentStop | Consolidates Explore results into audits/ |
| precompact.sh | PreCompact | Saves handoff YAML before compaction |
| session-end.sh | SessionEnd | Ledger + handoff + updates docs |
| notification.sh | Notification | Native macOS notification |

### Pretool guards

| Hook | Matcher | Purpose |
|------|---------|---------|
| pretool-supabase.sh | `mcp__supabase__` | Blocks list_tables, destructive SQL; injects RLS rules |
| pretool-playwright.sh | `mcp__playwright__` | Closed context, minimizes actions |
| pretool-context7.sh | `mcp__context7__` | Injects versions from package.json |
| pretool-fetch.sh | `WebFetch\|WebSearch` | Injects current date in searches |
| pretool-explore.sh | `Task` | Injects context and focuses Explore subagent |
| pretool-bash-guard.sh | `Bash` | Blocks rm -rf, sudo, DROP, git push --force |
| pretool-mcp-limiter.sh | `mcp__` | Rate-limits heavy MCPs (browser) |

Matcher order: specific first (`mcp__supabase__`), generic last (`mcp__`).

## Adding a new agent

Create `plugins/tamuras-claude-code/agents/name.md` with:

```yaml
---
name: agent-name
description: "trigger phrases here"
tools: [Glob, Grep, Read, Write]
model: sonnet
---
```

Then define persona, workflow, and output format in the body.

## Target stack

- Next.js 15+ (App Router)
- Supabase (Auth, DB, Storage)
- TypeScript (strict)
- Tailwind CSS + shadcn/ui

## Docs

- [Architecture](docs/ARCHITECTURE.md)
- [Token Optimization](docs/TOKEN-OPTIMIZATION.md)

## License

MIT
