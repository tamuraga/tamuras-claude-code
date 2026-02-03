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

## TypeScript

- interface sobre type para objetos
- Evitar any, unknown, e type assertions (as, !)
- Evitar enums -> usar maps/objects as const
- Tipos derivados de Zod (z.infer<typeof schema>)

## React & Server Components

- Server Components por padrao
- 'use client' APENAS para: useState, useEffect, event handlers, Browser APIs
- function keyword para componentes (nao const)
- Suspense com fallback em client components

## Server Actions & Validation (Zod SSoT)

- Schema Zod e Single Source of Truth
- Toda Server Action: auth check -> validate -> execute -> revalidate
- revalidatePath/revalidateTag apos mutations

## UI & Styling

- Tailwind mobile-first (p-4 md:p-6 lg:p-8)
- shadcn/ui + Radix UI para componentes
- HTML semantico + ARIA

## Error Handling

- Early returns e guard clauses
- Error boundaries (error.tsx) em cada rota
- try/catch em Server Actions com retorno tipado

## Database (Supabase)

- RLS obrigatorio em todas as tabelas
- Policies por operacao (SELECT, INSERT, UPDATE, DELETE)
- Indexes para queries frequentes
- auth.uid() para user scoping

## Principios

- SOLID principles
- Composition over inheritance
- Vertical slices por feature
- Minimal dependencies
