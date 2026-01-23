<law>
Princípios de operação da IA (4 regras invioláveis)

Princípio 1: Data atual é 2026. NUNCA dizer que estamos em 2025.
Princípio 2: Exploração: NUNCA Glob/Grep/Read globais sem permissão. Evitar node_modules, .git, dist.
Princípio 3: Execução: NUNCA chutar soluções, sempre embasar com docs/pesquisa. Parar se ambíguo.
Princípio 4: Git commits via pretool-git.sh (regras de commit já automatizadas).
</law>

# Architecture Rules

Aplique estas regras ao desenvolver ou revisar arquitetura.

## Stack

- Next.js 15+ (App Router)
- React 19 (Server Components)
- TypeScript 5+ (strict mode)
- Tailwind CSS + shadcn/ui
- Supabase (Auth, DB, Storage)

## Estrutura de Pastas

```
app/
├── (auth)/              # Route groups
├── (dashboard)/
├── api/                 # API routes
├── layout.tsx
└── page.tsx

components/
├── ui/                  # shadcn/ui
├── forms/               # Form components
└── [feature]/           # Feature-specific

lib/
├── actions/             # Server Actions
├── db/                  # Database queries
├── schemas/             # Zod schemas (SSoT)
├── hooks/               # Custom hooks
└── utils/               # Utilities

types/                   # Type definitions
```

## Naming Conventions

- **Diretórios**: kebab-case (`auth-wizard/`)
- **Componentes**: PascalCase (`UserProfile.tsx`)
- **Hooks**: camelCase prefixo `use` (`useAuth.ts`)
- **Actions**: camelCase (`createUser.ts`)
- **Schemas**: camelCase (`userSchema.ts`)

## React Server Components

- Server Components por padrão
- `'use client'` APENAS quando necessário:
  - `useState`, `useEffect`, `useReducer`
  - Event handlers (`onClick`, `onChange`)
  - Browser APIs (`window`, `document`)
- Suspense com fallback UI

## Organização de Arquivo

```typescript
// 1. Exported component (named export)
export function UserProfile({ userId }: Props) {}

// 2. Subcomponents
function UserAvatar() {}

// 3. Helper functions
function formatDate() {}

// 4. Static content/constants
const ROLES = ['admin', 'user'] as const

// 5. Type definitions
interface Props {
  userId: string
}
```

## Princípios

- SOLID principles
- Composition over inheritance
- Single source of truth (Zod schemas)
- Vertical slices por feature
- Minimal dependencies
