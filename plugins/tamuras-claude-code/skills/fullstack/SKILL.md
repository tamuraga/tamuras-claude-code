# Fullstack Rules

Aplique estas regras ao desenvolver features fullstack end-to-end.

## Stack

```
Next.js 15+ (App Router)
├── React 19 (Server + Client Components)
├── TypeScript 5+ (strict mode)
├── Supabase (Auth, DB, Storage)
├── Vercel AI SDK (streaming, useChat)
├── Zod (validação + tipos)
├── TailwindCSS + shadcn/ui
└── Server Actions (mutations)
```

## Princípios

- **Type-safety first**: Tipos compartilhados entre todas as camadas
- **Single source of truth**: Schema Zod define validação e tipos
- **Vertical slices**: Feature completa de uma vez (DB → API → UI)
- **Security by default**: Auth check + validação em toda mutation

## Ordem de Implementação

1. Schema Zod (tipos derivados, nunca manuais)
2. Migration SQL (RLS policies)
3. Database queries (lib/db/)
4. Server Actions (lib/actions/)
5. UI Components (app/)

## Schema First (Zod como SSoT)

```typescript
// lib/schemas/feature.ts
import { z } from 'zod'

export const createFeatureSchema = z.object({
  name: z.string().min(1).max(100),
  type: z.enum(['typeA', 'typeB']),
})

export const featureSchema = createFeatureSchema.extend({
  id: z.string().uuid(),
  userId: z.string().uuid(),
  createdAt: z.date(),
})

// Tipos derivados (NUNCA definir manualmente!)
export type CreateFeatureInput = z.infer<typeof createFeatureSchema>
export type Feature = z.infer<typeof featureSchema>
```

## Server Actions

```typescript
// lib/actions/feature.ts
'use server'

import { revalidatePath } from 'next/cache'
import { getSession } from '@/lib/auth'
import { createFeatureSchema } from '@/lib/schemas/feature'

export async function createFeatureAction(formData: FormData) {
  // 1. Auth
  const session = await getSession()
  if (!session) throw new Error('Unauthorized')

  // 2. Validate
  const validated = createFeatureSchema.parse(Object.fromEntries(formData))

  // 3. Execute
  const feature = await createFeature(session.user.id, validated)

  // 4. Revalidate
  revalidatePath('/features')

  return feature
}
```

## Migration Pattern

```sql
-- RLS obrigatório
ALTER TABLE features ENABLE ROW LEVEL SECURITY;

-- Policies por operação
CREATE POLICY "Users can view own features"
  ON features FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own features"
  ON features FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

## Checklist

### Database
- [ ] Migration criada
- [ ] RLS policies configuradas
- [ ] Indexes para queries frequentes

### Types & Validation
- [ ] Zod schema como SSoT
- [ ] Tipos exportados do schema
- [ ] Validação no Server Action

### API/Actions
- [ ] Auth check presente
- [ ] Validação com Zod
- [ ] Error handling
- [ ] Revalidation paths

### UI
- [ ] Loading states
- [ ] Error handling
- [ ] Form validation
- [ ] Responsive
