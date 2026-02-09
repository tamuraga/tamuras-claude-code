---
description: Instalar MCP servers com guia interativo
allowed-tools: Bash(claude mcp:*), AskUserQuestion, Read, Grep, Glob
---

## MCPs já instalados
!`claude mcp list 2>/dev/null || echo "Nenhum MCP instalado"`

## Catálogo de MCPs

### Raciocínio
| # | Nome | Tipo | Comando/URL | Descrição |
|---|------|------|-------------|-----------|
| 1 | sequential-thinking | npx | npx -y @anthropic-ai/sequential-thinking-mcp | Raciocínio passo a passo para problemas complexos |

### Documentação & Conhecimento
| # | Nome | Tipo | Comando/URL | Descrição |
|---|------|------|-------------|-----------|
| 2 | context7 | npx | npx -y @upstash/context7-mcp | Docs atualizadas de libs populares (React, Next.js, etc) |
### Browser & Frontend
| # | Nome | Tipo | Comando/URL | Descrição |
|---|------|------|-------------|-----------|
| 3 | playwright | npx | npx @playwright/mcp@latest | Automação de browser, screenshots, testes E2E |

### Database
| # | Nome | Tipo | Comando/URL | Descrição |
|---|------|------|-------------|-----------|
| 4 | supabase | http | https://mcp.supabase.com/mcp | Supabase: auth, database, storage |

### DevOps & Versionamento
| # | Nome | Tipo | Comando/URL | Descrição |
|---|------|------|-------------|-----------|
| 5 | github | http | https://api.githubcopilot.com/mcp/ | Issues, PRs, Actions, releases (requer GITHUB_PERSONAL_ACCESS_TOKEN) |

### Cloud & Infra
| # | Nome | Tipo | Comando/URL | Descrição |
|---|------|------|-------------|-----------|
| 6 | vercel | npx | npx -y @vercel/mcp@latest | Deploy, domains, env vars |

### Pagamentos
| # | Nome | Tipo | Comando/URL | Descrição |
|---|------|------|-------------|-----------|
| 7 | stripe | http | https://mcp.stripe.com | Pagamentos, clientes, invoices |

### Arquivos
| # | Nome | Tipo | Comando/URL | Descrição |
|---|------|------|-------------|-----------|
| 8 | filesystem | npx | npx -y @anthropic-ai/filesystem-mcp | Operações avançadas de arquivos |

### Código & IDE
| # | Nome | Tipo | Comando/URL | Descrição |
|---|------|------|-------------|-----------|
| 9 | serena | uvx | uvx --from git+https://github.com/oraios/serena serena start-mcp-server | LSP-powered code navigation e refactoring |

## Instruções

Siga estes passos em ordem. Responda sempre em português (pt-BR).

### Passo 1 - Mostrar lista
Mostre a lista de MCPs disponíveis organizada por categoria, de forma limpa e legível.
- Se algum MCP já estiver instalado (veja seção "MCPs já instalados"), marque com ✓ ao lado do nome.
- MCPs que requerem API keys ou tokens, indique com 🔑.

### Passo 2 - Perguntar qual instalar
Use AskUserQuestion para perguntar qual MCP o usuário quer instalar. Ofereça as opções mais populares (context7, playwright, supabase, github) como choices, e permita que o usuário escolha outros.

### Passo 3 - Perguntar o escopo
Use AskUserQuestion para perguntar onde instalar:
- **Global** (`-s user`): Disponível em todos os projetos
- **Projeto** (`-s project`): Só no diretório atual (.mcp.json)

### Passo 4 - Config de auth (se necessário)
Se o MCP escolhido requer API key ou token (github, greptile, etc), informe o usuário qual variável de ambiente precisa configurar e como obter.

### Passo 5 - Instalar
Execute o comando correto baseado no tipo do MCP:

Para MCPs tipo **npx**:
```
claude mcp add <nome> -s <escopo> -- <comando completo>
```

Para MCPs tipo **uvx**:
```
claude mcp add <nome> -s <escopo> -- <comando completo>
```

Para MCPs tipo **http**:
```
claude mcp add <nome> -s <escopo> --transport http <url>
```

Para MCPs tipo **sse**:
```
claude mcp add <nome> -s <escopo> --transport sse <url>
```

### Passo 6 - Confirmar
Execute `claude mcp list` para confirmar que foi instalado com sucesso.
Pergunte se o usuário quer instalar mais algum MCP.
