# Pre-Tool Hooks (Claude Code 2.1.0+)

Hooks que injetam contexto e modificam inputs antes de chamadas de ferramentas.

## Recursos Utilizados (2.1.0+)

| Recurso | Descrição | Usado em |
|---------|-----------|----------|
| `once: true` | Executa só 1x por sessão | pretool-fetch |
| Input Modification | Modifica comando antes de executar | pretool-git, pretool-explorer |
| Wildcards | Permissões com `Bash(npm *)` | settings.example.json |

## Hooks Disponíveis

| Hook | Trigger | Função | Modifica Input? |
|------|---------|--------|-----------------|
| `pretool-supabase.sh` | `mcp__supabase__*` | Regras RLS, queries, migrations | Não |
| `pretool-git.sh` | `git commit`, `gh pr` | Trunca msg >50ch, remove Co-Authored-By | **Sim** |
| `pretool-fetch.sh` | `WebFetch`, `WebSearch` | Injeta data atual (Brasil) | Não |
| `pretool-playwright.sh` | `mcp__playwright__*` | Restringe domínios externos | Não |
| `pretool-explorer.sh` | `Task` (Explore) | Redireciona para codebase-explorer | **Sim** |

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

## Testando

```bash
# Hook de data
./pretool-fetch.sh
# Output: Data atual: 2026-01-22 ...

# Hook de git (simular commit longo)
echo 'git commit -m "feat: this is a very long commit message that should be truncated"' | ./pretool-git.sh
# Output: JSON com updatedInput

# Hook de explorer
echo '{"subagent_type": "Explore", "prompt": "explorar projeto"}' | ./pretool-explorer.sh
# Output: JSON com codebase-explorer
```

## Estrutura

```
hooks/
├── inject-context.sh       # SessionStart - contexto inicial
├── pretool-supabase.sh     # + pretool-supabase.md
├── pretool-git.sh          # + pretool-git.md (Input Modification)
├── pretool-fetch.sh        # Data dinâmica Brasil (once: true)
├── pretool-playwright.sh   # Restrição domínios
├── pretool-explorer.sh     # Redirecionamento (Input Modification)
├── settings.example.json   # Exemplo de configuração
└── README.md               # Esta documentação
```
