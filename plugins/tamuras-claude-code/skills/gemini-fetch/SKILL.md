# Gemini Fetch - Fallback para sites bloqueados

Quando WebFetch falhar ou o site for conhecido como bloqueado (Reddit, Twitter/X, LinkedIn, etc), use o Gemini CLI via tmux como fallback.

## Pre-requisitos

- `gemini` CLI instalado (`npm install -g @anthropic-ai/gemini-cli` ou via homebrew)
- `tmux` instalado

## Sites conhecidos como bloqueados

Reddit, Twitter/X, LinkedIn, Facebook, Instagram, Medium (paywall), Quora

## Workflow

### 1. Tentar WebFetch primeiro

Sempre tente WebFetch primeiro. Se falhar com erro de acesso/bloqueio, ou se o site estiver na lista acima, use o fallback Gemini.

### 2. Fallback via Gemini CLI + tmux

Use sessoes tmux para interagir com Gemini CLI de forma nao-interativa:

```bash
# Criar sessao tmux dedicada
SESSION="gemini-fetch-$$"
tmux new-session -d -s "$SESSION" -x 250 -y 50

# Enviar comando para Gemini
PROMPT="Fetch and summarize the content from: URL_AQUI. Return the full text content, not just a summary."
tmux send-keys -t "$SESSION" "gemini \"$PROMPT\"" Enter

# Aguardar resposta (polling com timeout)
TIMEOUT=60
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
  sleep 3
  ELAPSED=$((ELAPSED + 3))
  OUTPUT=$(tmux capture-pane -t "$SESSION" -p)
  # Gemini terminou quando aparece o prompt novamente ou ">" no final
  if echo "$OUTPUT" | grep -qE '^\$|^>|gemini>'; then
    break
  fi
done

# Capturar output
tmux capture-pane -t "$SESSION" -p -S -500

# Limpar sessao
tmux kill-session -t "$SESSION" 2>/dev/null
```

### 3. Padroes de uso

**Fetch simples:**
```bash
SESSION="gf-$$"
tmux new-session -d -s "$SESSION" -x 250 -y 50
tmux send-keys -t "$SESSION" "gemini 'Fetch the content from https://reddit.com/r/ClaudeAI/... and return the main post text and top comments'" Enter
sleep 15
tmux capture-pane -t "$SESSION" -p -S -500
tmux kill-session -t "$SESSION"
```

**Pesquisa em site bloqueado:**
```bash
SESSION="gf-$$"
tmux new-session -d -s "$SESSION" -x 250 -y 50
tmux send-keys -t "$SESSION" "gemini 'Search Reddit for discussions about Claude Code skills. Return the top 5 most relevant posts with links and summaries.'" Enter
sleep 30
tmux capture-pane -t "$SESSION" -p -S -500
tmux kill-session -t "$SESSION"
```

**Multi-turn (para respostas longas):**
```bash
SESSION="gf-$$"
tmux new-session -d -s "$SESSION" -x 250 -y 50

# Primeira pergunta
tmux send-keys -t "$SESSION" "gemini 'Fetch https://reddit.com/r/ClaudeAI/comments/... and return full content'" Enter
sleep 20
PART1=$(tmux capture-pane -t "$SESSION" -p -S -500)

# Follow-up se necessario
tmux send-keys -t "$SESSION" "Now summarize the key points and sentiment" Enter
sleep 15
PART2=$(tmux capture-pane -t "$SESSION" -p -S -500)

tmux kill-session -t "$SESSION"
```

## Regras

1. **Sempre tente WebFetch primeiro** - so use Gemini como fallback
2. **Timeout de 60s** - nao espere mais que isso por resposta
3. **Limpe sessoes tmux** - sempre mate a sessao ao terminar
4. **Nao use para sites que WebFetch consegue acessar** - e mais lento
5. **Informe o usuario** que esta usando Gemini como fallback
6. **Capture output suficiente** - use `-S -500` para capturar 500 linhas do historico
7. **Valide que Gemini esta instalado** antes de tentar: `which gemini || command -v gemini`
