# Pre-Tool Hooks (Claude Code 2.1.0+)

Hooks que injetam contexto, modificam inputs e mantêm continuidade entre sessões.

## Recursos Utilizados (2.1.0+)

| Recurso | Descrição | Usado em |
|---------|-----------|----------|
| `once: true` | Executa só 1x por sessão | pretool-fetch |
| Input Modification | Modifica comando antes de executar | pretool-git, pretool-explorer |
| Wildcards | Permissões com `Bash(npm *)` | settings.example.json |
| Block Decision | Bloqueia execução com JSON | pretool-typescript |

## Hooks Disponíveis

### Pre-Tool Hooks (Antes de Ferramentas)

| Hook | Trigger | Função | Modifica Input? |
|------|---------|--------|-----------------|
| `pretool-supabase.sh` | `mcp__supabase__*` | Regras RLS, queries, migrations | Não |
| `pretool-git.sh` | `git commit`, `gh pr` | Trunca msg >50ch, remove Co-Authored-By | **Sim** |
| `pretool-fetch.sh` | `WebFetch`, `WebSearch` | Injeta data atual (Brasil) | Não |
| `pretool-playwright.sh` | `mcp__playwright__*` | Restringe domínios externos | Não |
| `pretool-explorer.sh` | `Task` (Explore) | Redireciona para codebase-explorer | **Sim** |
| `pretool-typescript.sh` | `Edit\|Write` (.ts/.tsx) | Valida TypeScript antes de editar | **Bloqueia** |

### Hooks de Continuidade (Novos)

| Hook | Trigger | Função |
|------|---------|--------|
| `statusline.sh` | `UserPromptSubmit` | Mostra % contexto usado (🟢🟡🔴) |
| `precompact-handoff.sh` | `PreCompact` | Salva snapshot YAML antes de compactar |
| `session-ledger.sh` | `SessionStart`, `PostToolUse` | Mantém ledger de arquivos e decisões |

---

## Hooks de Continuidade (Detalhes)

### 1. StatusLine (`statusline.sh`)

Exibe indicador visual de uso de contexto a cada prompt:

```
🟢 Contexto: 35%           # Saudável
🟡 Contexto: 72%           # Considerar handoff
🔴 Contexto: 85% ⚠️ CRÍTICO # Executar /compact
```

### 2. PreCompact Handoff (`precompact-handoff.sh`)

Antes de compactação, gera arquivo YAML em `thoughts/handoffs/`:

```yaml
project: meu-projeto
timestamp: "2026-01-22_10-30-15"
session_id: abc123

context:
  last_files_modified:
    - src/components/Button.tsx
    - src/hooks/useAuth.ts

decisions:
  - "(preencher manualmente)"

next_steps:
  - "(preencher manualmente)"
```

### 3. Session Ledger (`session-ledger.sh`)

Mantém arquivo `thoughts/ledgers/CONTINUITY_<projeto>.md`:

- **SessionStart**: Carrega ledger existente ou cria novo
- **PostToolUse**: Registra arquivos modificados automaticamente

```markdown
# Continuity Ledger: meu-projeto

**Criado:** 2026-01-22 10:30

## Arquivos Modificados
- `src/Button.tsx` (10:35)
- `src/useAuth.ts` (10:42)

## Decisões Importantes
- Usar Zustand para state management

## Próximos Passos
- [ ] Implementar logout
```

### 4. TypeScript Preflight (`pretool-typescript.sh`)

Valida TypeScript antes de editar arquivos `.ts`/`.tsx`:

**Otimizações:**
- `--incremental`: Cache para builds rápidos (~100-300ms após primeira)
- `--skipLibCheck`: Ignora tipos de node_modules
- Single file: Valida apenas o arquivo sendo editado

**Comportamento:**
- Se há erros → **Bloqueia** edição + mostra erros
- Se OK → Permite edição normalmente

---

## Input Modification (2.1.0+)

Hooks podem retornar JSON para modificar o comando:

```json
{
  "updatedInput": true,
  "command": "comando-modificado",
  "reason": "Motivo da modificação"
}
```

### Exemplo: pretool-git.sh

```
Input:  git commit -m "feat: add very long commit message that exceeds fifty characters limit"
Output: git commit -m "feat: add very long commit message that exce..."
Reason: "Mensagem truncada de 72 para 50 chars"
```

### Exemplo: pretool-explorer.sh

```
Input:  Task(subagent_type="Explore", prompt="explorar código")
Output: Task(subagent_type="tamuras-claude-code:codebase-explorer", prompt="explorar código")
Reason: "Redirecionado para codebase-explorer"
```

---

## Instalação

### 1. Copiar settings.example.json

```bash
PLUGIN_PATH="/Users/eugtamura/Dev/tamuras-claude-code/plugins/tamuras-claude-code"

# Para projeto específico
cp "$PLUGIN_PATH/hooks/settings.example.json" /seu/projeto/.claude/settings.local.json

# Ou global
cp "$PLUGIN_PATH/hooks/settings.example.json" ~/.claude/settings.json
```

### 2. Ajustar caminhos

Substituir `/path/to/tamuras-claude-code` pelo caminho real do plugin.

### 3. Tornar executáveis

```bash
chmod +x "$PLUGIN_PATH/hooks/"*.sh
```

---

## Testando

```bash
PLUGIN_PATH="/Users/eugtamura/Dev/tamuras-claude-code/plugins/tamuras-claude-code"

# StatusLine
./hooks/statusline.sh
# Output: 🟢 Contexto: 0%

# Ledger (SessionStart)
HOOK_EVENT=SessionStart ./hooks/session-ledger.sh
# Output: 📋 Novo ledger criado...

# Handoff
./hooks/precompact-handoff.sh
# Output: ✅ Handoff salvo: thoughts/handoffs/...

# TypeScript (simular edição)
echo '{"file_path": "/path/to/file.ts"}' | ./hooks/pretool-typescript.sh
# Output: (nada se OK, JSON se erro)

# Hook de data
./hooks/pretool-fetch.sh
# Output: Data atual: 2026-01-22 ...

# Hook de git (simular commit longo)
echo 'git commit -m "feat: this is a very long commit message that should be truncated"' | ./hooks/pretool-git.sh
# Output: JSON com updatedInput
```

---

## Estrutura

```
hooks/
├── inject-context.sh       # SessionStart - contexto inicial
├── statusline.sh           # UserPromptSubmit - % contexto (NOVO)
├── precompact-handoff.sh   # PreCompact - snapshot YAML (NOVO)
├── session-ledger.sh       # SessionStart/PostToolUse - ledger (NOVO)
├── pretool-typescript.sh   # PreToolUse - TypeScript check (NOVO)
├── pretool-supabase.sh     # + pretool-supabase.md
├── pretool-git.sh          # + pretool-git.md (Input Modification)
├── pretool-fetch.sh        # Data dinâmica Brasil (once: true)
├── pretool-playwright.sh   # Restrição domínios
├── pretool-explorer.sh     # Redirecionamento (Input Modification)
├── settings.example.json   # Exemplo de configuração
└── README.md               # Esta documentação

thoughts/
├── ledgers/                # Ledgers de continuidade por projeto
│   └── CONTINUITY_<projeto>.md
└── handoffs/               # Snapshots antes de compactação
    └── handoff-<projeto>-<timestamp>.yaml
```

---

## Integração com claude-mem

Os sistemas se **complementam**, não há conflito:

| Sistema | Função | Quando |
|---------|--------|--------|
| **claude-mem** | Memória semântica | Cross-sessão, busca por similaridade |
| **Ledger** | Estado estruturado | Intra-sessão, carrega no início |
| **Handoff** | Snapshot antes de compactar | PreCompact, formato YAML |

O `codebase-explorer` continua usando claude-mem para busca de contexto histórico.
