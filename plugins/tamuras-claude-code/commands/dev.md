# Development Rules

Aplique estas regras ao desenvolver neste projeto.

## Stack

- Next.js 15+ (App Router)
- React 19 (Server Components)
- TypeScript 5+ (strict mode)
- Tailwind CSS + shadcn/ui + Radix UI
- Supabase (Auth, DB, Storage)
- Zod (validacao + tipos)
- Server Actions (mutations)

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
├── forms/
└── [feature]/           # Feature-specific

lib/
├── actions/             # Server Actions
├── db/                  # Database queries
├── schemas/             # Zod schemas (SSoT)
├── hooks/               # Custom hooks
└── utils/

types/                   # Type definitions
```

## Naming Conventions

- Diretorios: kebab-case (auth-wizard/)
- Componentes: PascalCase (UserProfile.tsx)
- Hooks: camelCase prefixo use (useAuth.ts)
- Actions: camelCase (createUser.ts)
- Schemas: camelCase (userSchema.ts)
- Named exports (nunca default export)
- Nomes descritivos com verbos auxiliares (isLoading, hasError, canDelete)

## TypeScript

- interface sobre type para objetos
- Evitar any, unknown, e type assertions (as, !)
- Evitar enums -> usar maps/objects as const
- Tipos derivados de Zod (z.infer<typeof schema>)
- Generics em funcoes e componentes reutilizaveis

## React & Server Components

- Server Components por padrao
- 'use client' APENAS para: useState, useEffect, event handlers, Browser APIs
- Minimizar use client, useEffect, setState
- function keyword para componentes (nao const)
- Suspense com fallback em client components
- Dynamic loading para componentes nao-criticos

## Server Actions & Validation (Zod SSoT)

- Schema Zod e Single Source of Truth (tipos derivados, nunca manuais)
- Toda Server Action: auth check -> validate -> execute -> revalidate
- Retornar tipo consistente (ActionResponse)
- revalidatePath/revalidateTag apos mutations

## Ordem de Implementacao

1. Schema Zod (tipos derivados, nunca manuais)
2. Migration SQL (RLS policies)
3. Database queries (lib/db/)
4. Server Actions (lib/actions/)
5. UI Components (app/)

## UI & Styling

- Tailwind mobile-first (p-4 md:p-6 lg:p-8)
- shadcn/ui + Radix UI para componentes
- HTML semantico + ARIA
- WebP para imagens, lazy loading, size data
- Framer Motion para animacoes (se disponivel)

## Forms

```typescript
'use client'

import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'

export function LoginForm() {
  const { register, handleSubmit, formState: { errors } } = useForm({
    resolver: zodResolver(schema),
  })
}
```

## Performance

- Otimizar Web Vitals (LCP, CLS, FID)
- Wrap client components em Suspense
- Imagens otimizadas (next/image, WebP, lazy)
- Dynamic imports para code splitting
- Evitar re-renders desnecessarios (useCallback, useMemo quando necessario)

## Error Handling

- Early returns e guard clauses
- Error boundaries (error.tsx) em cada rota
- Mensagens user-friendly (nao stack traces)
- Evitar else desnecessario apos early return
- try/catch em Server Actions com retorno tipado

## Database (Supabase)

- RLS obrigatorio em todas as tabelas
- Policies por operacao (SELECT, INSERT, UPDATE, DELETE)
- Indexes para queries frequentes
- auth.uid() para user scoping
- Nunca expor service_role no client

## Migration Pattern

```sql
ALTER TABLE features ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own features"
  ON features FOR SELECT
  USING (auth.uid() = user_id);
```

## Organizacao de Arquivo

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

## Principios

- SOLID principles
- Composition over inheritance
- Vertical slices por feature
- Minimal dependencies
- Iteration over duplication
