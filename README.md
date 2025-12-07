# Tamura's Claude Code

Plugin privado com agentes e comandos para workflow Next.js + Supabase + TypeScript.

## Instalacao

```bash
# Adiciona como source local
/plugin marketplace add /home/gabrieltamura/Apps/active/tamuras-claude-code

# Instala
/plugin install tamuras-claude-code
```

Ou via GitHub privado:
```bash
/plugin marketplace add github:gabrieltamura/tamuras-claude-code
/plugin install tamuras-claude-code
```

## Conteudo

### Comando

| Nome | Descricao |
|------|-----------|
| `/qa` | Checklist QA adaptativo - busca QA.md, roda build/lint/types |

### Agentes

| Nome | Descricao | Output |
|------|-----------|--------|
| `performance` | Core Web Vitals, bundle size, queries | `audits/performance/YYYY-MM-DD.md` |
| `security` | RLS, OWASP Top 10, Server Actions | `audits/security/YYYY-MM-DD.md` |
| `responsive` | Mobile-first, breakpoints, touch | `audits/responsive/YYYY-MM-DD.md` |
| `visual-research` | Moodboard, referencias UI | `audits/visual-research/[tema]/YYYY-MM-DD.md` |

## Uso

```bash
# Comando
/qa

# Agentes (na conversa)
"audit performance do projeto"
"security audit"
"check mobile responsividade"
"pesquisa visual para dashboard analytics"
```

## Stack Alvo

- Next.js 15+ (App Router)
- Supabase (Auth, DB, Storage)
- TypeScript (strict)
- Tailwind CSS
- shadcn/ui

## Filosofia

- Agentes sao **consultivos**: analisam, documentam, geram plano
- Usuario **aprova** e executa fixes na thread principal
- Audits **versionados** por data em `audits/[tipo]/`
