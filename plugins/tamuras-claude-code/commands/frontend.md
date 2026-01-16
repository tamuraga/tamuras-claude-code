# Frontend Rules

Aplique estas regras ao desenvolver componentes React.

## Stack

- React 19 (Server Components)
- TypeScript 5+ (strict)
- Tailwind CSS (mobile-first)
- shadcn/ui + Radix UI
- react-hook-form + Zod

## TypeScript

- Usar `interface` sobre `type` para objetos
- Evitar `any` e `unknown`
- Evitar type assertions (`as` ou `!`)
- Tipos genéricos em funções e componentes

## Componentes

```typescript
// Usar function, não const
export function UserCard({ user }: UserCardProps) {}

// Named exports, não default
export function Component() {}  // ✅
export default function Component() {}  // ❌
```

## React Server Components

```typescript
// ✅ Server Component (padrão)
export async function UserList() {
  const users = await getUsers()
  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>
}

// ✅ Client Component (apenas quando necessário)
'use client'
export function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>
}
```

### Quando usar 'use client'

- ✅ `useState`, `useEffect`, `useReducer`
- ✅ Event handlers (`onClick`, `onChange`)
- ✅ Browser APIs (`window`, `document`)
- ❌ Fetch de dados (use Server Component)

## Naming Conventions

```typescript
// Event handlers: handleXxx
const handleClick = () => {}
const handleSubmit = (e: FormEvent) => {}

// Boolean props: is/has/can/should
interface Props {
  isLoading: boolean
  hasError: boolean
  canDelete: boolean
}

// Callbacks: onXxx
interface Props {
  onClick: () => void
  onSubmit: (data: FormData) => void
}
```

## Estrutura de Arquivo

```typescript
// 1. Imports
// 2. Types/Interfaces
// 3. Component (named export)
// 4. Subcomponents
// 5. Helpers
```

## Tailwind Mobile-First

```typescript
// ✅ Mobile-first (min-width)
<div className="p-4 md:p-6 lg:p-8">
  <h1 className="text-lg md:text-xl lg:text-2xl">Title</h1>
</div>

// ❌ Desktop-first
<div className="p-8 sm:p-6 xs:p-4">
```

## Hooks

- Chamar apenas no nível superior
- `useCallback` para funções passadas como props
- `useMemo` para computações custosas
- Hooks customizados prefixados com `use`

## Forms

```typescript
'use client'

import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'

export function LoginForm() {
  const { register, handleSubmit, formState: { errors } } = useForm({
    resolver: zodResolver(schema),
  })
  // ...
}
```

## Acessibilidade

- HTML semântico
- Atributos ARIA apropriados
- Navegação por teclado
- Contraste de cor adequado
