# Supabase Rules

## NUNCA USAR
- `list_tables` do MCP - muito verboso, prefira schemas conhecidos
- `DELETE FROM table` sem WHERE
- `DROP TABLE` sem backup/confirmação
- Queries em tabelas de sistema (pg_*)
- `TRUNCATE` sem confirmação explícita

## SEMPRE
- RLS em toda tabela nova
- Auth check antes de mutations
- Usar tipos gerados do Database schema
- Testar policies com diferentes roles

## Padrão de Query

```typescript
// Correto
const { data } = await supabase
  .from('users')
  .select('id, name')
  .eq('id', userId)
  .single()

// Errado (select * implícito)
const { data } = await supabase.from('users')
```

## Migrations

### Estrutura
```sql
-- Nome: YYYYMMDDHHMMSS_descricao.sql

-- Up
CREATE TABLE ...;

-- Policies (SEMPRE junto com tabela)
ALTER TABLE ... ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_read_own"
ON table_name FOR SELECT
USING (auth.uid() = user_id);
```

### Checklist Migration
- [ ] RLS habilitado
- [ ] Policies criadas
- [ ] Índices necessários
- [ ] Foreign keys com ON DELETE

## Edge Functions

```typescript
// Sempre validar auth
const { data: { user }, error } = await supabase.auth.getUser()
if (error || !user) {
  return new Response('Unauthorized', { status: 401 })
}
```

## Realtime

```typescript
// Sempre cleanup na desmontagem
const channel = supabase.channel('changes')
  .on('postgres_changes', { ... }, handler)
  .subscribe()

// Cleanup
return () => supabase.removeChannel(channel)
```
