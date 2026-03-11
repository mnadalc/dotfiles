---
name: tanstack-query-best-practices
description: TanStack Query best practices for projects using TanStack Query. Use this skill when writing queries, mutations, cache logic, or data-fetching patterns with TanStack Query.
license: MIT
metadata:
  author: mnadalc
  version: '1.0.0'
  source: 'https://tkdodo.eu/blog'
---

# TanStack Query Best Practices

Best practices extracted from TkDodo's blog.

## When to Apply

Reference these guidelines when:

- Creating or refactoring `queryOptions` / `useQuery` / `useMutation` calls
- Designing query key hierarchies and cache invalidation strategies
- Integrating Supabase client calls with TanStack Query
- Implementing optimistic updates or real-time sync (Supabase Realtime)
- Writing route loaders that prefetch data in TanStack Start
- Handling forms backed by server state
- Reviewing TypeScript types around query/mutation hooks
- Testing components that depend on server state

## Rule Categories

| Priority | Category                  | Prefix      |
| -------- | ------------------------- | ----------- |
| 1        | Query Architecture        | `arch-`     |
| 2        | Query Keys                | `keys-`     |
| 3        | Data Fetching & Loaders   | `fetch-`    |
| 4        | Mutations & Cache Updates | `mutation-` |
| 5        | TypeScript                | `ts-`       |
| 6        | State Management          | `state-`    |
| 7        | Performance               | `perf-`     |
| 8        | Testing                   | `test-`     |
| 9        | Real-Time & Supabase      | `realtime-` |

---

## 1. Query Architecture (`arch-`)

### arch-use-query-options

**Use `queryOptions()` as the primary abstraction, not custom hooks.**

Custom hooks lock you into a specific hook (`useQuery`) and only work inside components. `queryOptions()` is a plain function that works everywhere: components, loaders, event handlers, server functions.

```typescript
// features/invoices/queries.ts
import { queryOptions } from '@tanstack/react-query';
import { supabase } from '~/lib/supabase';

export function invoiceOptions(id: string) {
  return queryOptions({
    queryKey: ['invoices', 'detail', id],
    queryFn: async () => {
      const { data, error } = await supabase.from('invoices').select('*').eq('id', id).single();
      if (error) throw error;
      return data;
    },
  });
}
```

Then consume flexibly at usage sites:

```typescript
// In a component
const invoice = useQuery(invoiceOptions(id));

// In a route loader (TanStack Start)
const loader = async ({ params }) => {
  await queryClient.ensureQueryData(invoiceOptions(params.id));
};

// With suspense
const invoice = useSuspenseQuery(invoiceOptions(id));

// Imperative prefetch
queryClient.prefetchQuery(invoiceOptions(id));
```

### arch-keep-abstractions-simple

Keep `queryOptions` factories minimal and non-configurable. Let consumers compose via spread:

```typescript
const { data } = useQuery({
  ...invoiceOptions(id),
  staleTime: 1000 * 60 * 5,
  select: (invoice) => invoice.total,
});
```

### arch-colocate-by-feature

Place query functions and key factories inside feature directories, not in a global `/queries` folder:

```
features/
  invoices/
    queries.ts      # queryOptions + key factory
    components/
    hooks/
  projects/
    queries.ts
```

---

## 2. Query Keys (`keys-`)

### keys-use-factory-pattern

Create a key factory per feature domain. Structure keys from general to specific:

```typescript
export const invoiceKeys = {
  all: ['invoices'] as const,
  lists: () => [...invoiceKeys.all, 'list'] as const,
  list: (filters: InvoiceFilters) => [...invoiceKeys.lists(), filters] as const,
  details: () => [...invoiceKeys.all, 'detail'] as const,
  detail: (id: string) => [...invoiceKeys.details(), id] as const,
};
```

### keys-include-all-dependencies

Every variable used in `queryFn` must appear in `queryKey`. Think of it like `useEffect` dependencies:

```typescript
// WRONG: status used in queryFn but not in key
queryKey: ["invoices"],
queryFn: () => fetchInvoices(status)

// CORRECT
queryKey: ["invoices", "list", { status }],
queryFn: () => fetchInvoices(status)
```

### keys-leverage-fuzzy-invalidation

Use the hierarchical structure for granular invalidation:

```typescript
// Invalidate everything invoice-related
queryClient.invalidateQueries({ queryKey: invoiceKeys.all });

// Invalidate only lists (preserves detail cache)
queryClient.invalidateQueries({ queryKey: invoiceKeys.lists() });

// Invalidate one specific detail
queryClient.invalidateQueries({ queryKey: invoiceKeys.detail(id) });
```

---

## 3. Data Fetching & Loaders (`fetch-`)

### fetch-prefetch-in-loaders

In TanStack Start route loaders, use `ensureQueryData` to prefetch. This fetches only if data is missing or stale:

```typescript
// routes/invoices/$id.tsx
import { createFileRoute } from '@tanstack/react-router';
import { invoiceOptions } from '~/features/invoices/queries';

export const Route = createFileRoute('/invoices/$id')({
  loader: ({ context: { queryClient }, params }) =>
    queryClient.ensureQueryData(invoiceOptions(params.id)),
  component: InvoiceDetail,
});
```

### fetch-set-stale-time-strategically

Default `staleTime` is `0` (always stale). Adjust per domain:

```typescript
// Data that rarely changes
queryOptions({ staleTime: 1000 * 60 * 10 }); // 10 min

// Data using Supabase Realtime (server pushes updates)
queryOptions({ staleTime: Infinity });

// Global default for less aggressive refetching
new QueryClient({
  defaultOptions: {
    queries: { staleTime: 1000 * 60 }, // 1 min
  },
});
```

### fetch-supabase-query-fn-must-throw

The Supabase client does not throw on errors; it returns `{ data, error }`. Always convert to thrown errors so TanStack Query can track the error state:

```typescript
queryFn: async () => {
  const { data, error } = await supabase
    .from("projects")
    .select("id, name, status");
  if (error) throw error;
  return data;
},
```

### fetch-use-placeholder-over-initial-data

Prefer `placeholderData` for UI-only previews; reserve `initialData` for genuinely valid cached data:

- `initialData` persists in cache, respects `staleTime`, and prevents refetch if fresh.
- `placeholderData` is never cached, always triggers background refetch, and exposes `isPlaceholderData` flag.

```typescript
// Show previous list while new filters load
useQuery({
  ...invoiceListOptions(filters),
  placeholderData: keepPreviousData,
});

// Seed detail from existing list cache
useQuery({
  ...invoiceOptions(id),
  initialData: () => queryClient.getQueryData(invoiceKeys.lists())?.find((inv) => inv.id === id),
  initialDataUpdatedAt: () => queryClient.getQueryState(invoiceKeys.lists())?.dataUpdatedAt,
});
```

### fetch-check-data-first-then-error

Follow the data-first status check pattern to respect stale-while-revalidate:

```typescript
// CORRECT: stale data shows even during background refetch errors
if (query.data) return <InvoiceList data={query.data} />;
if (query.error) return <ErrorMessage error={query.error} />;
return <Skeleton />;

// WRONG: error replaces stale data during retries
if (query.isPending) return <Skeleton />;
if (query.isError) return <ErrorMessage />;
return <InvoiceList data={query.data} />;
```

---

## 4. Mutations & Cache Updates (`mutation-`)

### mutation-separate-callbacks

Place cache logic in `useMutation` definition; place UI logic in `mutate()` call site:

```typescript
// Hook (reusable)
export function useDeleteInvoice() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('invoices').delete().eq('id', id);
      if (error) throw error;
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: invoiceKeys.all });
    },
  });
}

// Component (UI-specific)
deleteInvoice.mutate(id, {
  onSuccess: () => navigate({ to: '/invoices' }),
  onError: (err) => toast.error(err.message),
});
```

### mutation-prefer-mutate-over-mutateAsync

Use `mutate` with callbacks for most cases. `mutateAsync` requires manual error handling (`.catch()`). Only use `mutateAsync` when you need to `await` the result (e.g., sequential mutations).

### mutation-invalidate-broadly-update-specifically

After mutations, invalidate related queries so lists/aggregates refresh. For known detail caches, update directly:

```typescript
onSuccess: (updatedInvoice) => {
  // Direct update for the detail (instant)
  queryClient.setQueryData(
    invoiceKeys.detail(updatedInvoice.id),
    updatedInvoice
  );
  // Invalidate lists (background refetch)
  queryClient.invalidateQueries({ queryKey: invoiceKeys.lists() });
},
```

### mutation-optimistic-updates-sparingly

Only use optimistic updates when the UX demands instant feedback (toggles, likes). For most CRUD with Supabase, prefer invalidation — it's simpler and avoids duplicating server logic.

When you do need them:

```typescript
useMutation({
  mutationKey: ['invoices'],
  mutationFn: updateInvoice,
  onMutate: async (newData) => {
    await queryClient.cancelQueries({ queryKey: invoiceKeys.detail(newData.id) });
    const previous = queryClient.getQueryData(invoiceKeys.detail(newData.id));
    queryClient.setQueryData(invoiceKeys.detail(newData.id), (old) => ({
      ...old,
      ...newData,
    }));
    return { previous };
  },
  onError: (_err, newData, context) => {
    queryClient.setQueryData(invoiceKeys.detail(newData.id), context?.previous);
  },
  onSettled: (_data, _err, newData) => {
    queryClient.invalidateQueries({ queryKey: invoiceKeys.detail(newData.id) });
  },
});
```

### mutation-handle-concurrent-optimistic-updates

When multiple mutations can fire concurrently on the same data, check `isMutating` before invalidating to avoid reverting optimistic changes:

```typescript
onSettled: () => {
  if (queryClient.isMutating({ mutationKey: ["invoices"] }) === 1) {
    queryClient.invalidateQueries({ queryKey: invoiceKeys.all });
  }
},
```

---

## 5. TypeScript (`ts-`)

### ts-infer-dont-annotate

Let TypeScript infer query types from `queryFn` return types. Type the Supabase response, not the generics:

```typescript
// CORRECT: types flow from queryFn
export function projectOptions(id: string) {
  return queryOptions({
    queryKey: projectKeys.detail(id),
    queryFn: async (): Promise<Project> => {
      const { data, error } = await supabase
        .from("projects")
        .select("*")
        .eq("id", id)
        .single();
      if (error) throw error;
      return data;
    },
  });
}

// WRONG: manually specifying generics
useQuery<Project, PostgrestError>(...)
```

### ts-avoid-destructuring-for-narrowing

Keep the query result object intact for discriminated union narrowing:

```typescript
// CORRECT: TypeScript narrows data to non-undefined
const query = useQuery(projectOptions(id));
if (query.isSuccess) {
  console.log(query.data.name); // Project, not Project | undefined
}

// WRONG: destructuring breaks narrowing
const { data, isSuccess } = useQuery(projectOptions(id));
if (isSuccess) {
  console.log(data.name); // data is still Project | undefined
}
```

### ts-use-skipToken-for-conditional-queries

Use `skipToken` instead of `enabled: false` for type-safe dependent queries:

```typescript
import { skipToken } from '@tanstack/react-query';

const invoices = useQuery({
  queryKey: invoiceKeys.list({ projectId }),
  queryFn: projectId ? () => fetchInvoicesByProject(projectId) : skipToken,
});
```

### ts-register-default-error-type

Register the Supabase error type globally to avoid repeating it:

```typescript
// lib/query.ts
import type { PostgrestError } from '@supabase/supabase-js';

declare module '@tanstack/react-query' {
  interface Register {
    defaultError: PostgrestError;
  }
}
```

---

## 6. State Management (`state-`)

### state-dont-copy-to-local-state

Never copy query data into `useState`. You lose background updates:

```typescript
// WRONG
const { data } = useQuery(projectOptions(id));
const [project, setProject] = useState(data); // stale forever

// CORRECT: use query data directly
const { data: project } = useQuery(projectOptions(id));
```

### state-derive-dont-sync

Instead of syncing server state with `useEffect`, derive computed values:

```typescript
const useSelectedProject = () => {
  const { data: projects } = useQuery(projectListOptions());
  const { selectedId, setSelectedId } = useProjectStore();

  const validSelection = projects?.find((p) => p.id === selectedId) ? selectedId : null;

  return [validSelection, setSelectedId] as const;
};
```

### state-treat-query-as-async-state-manager

TanStack Query owns server/async state. Do not replicate it in Zustand, Redux, or Context. Use those stores only for true client state (UI preferences, form drafts, local selections).

### state-forms-pattern

For forms backed by server data:

- Use `defaultValues` from query data to initialize the form
- Set `staleTime` high or `Infinity` to avoid background updates overwriting user edits
- Invalidate on mutation success, then reset the form

```typescript
const { data } = useQuery({
  ...projectOptions(id),
  staleTime: Infinity, // don't refetch while editing
});

const form = useForm({ defaultValues: data });

const mutation = useMutation({
  mutationFn: updateProject,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: projectKeys.detail(id) });
    form.reset(); // re-sync with fresh server state
  },
});
```

---

## 7. Performance (`perf-`)

### perf-use-select-for-partial-subscriptions

Use `select` to subscribe to specific fields. Components re-render only when selected data changes:

```typescript
const { data: total } = useQuery({
  ...invoiceListOptions(filters),
  select: (invoices) => invoices.reduce((sum, inv) => sum + inv.amount, 0),
});
```

### perf-stabilize-select-functions

Inline `select` functions recreate on every render. Move them outside or memoize:

```typescript
// Outside component (stable reference)
const selectInvoiceTotal = (invoices: Invoice[]): number =>
  invoices.reduce((sum, inv) => sum + inv.amount, 0);

// In component
useQuery({
  ...invoiceListOptions(filters),
  select: selectInvoiceTotal,
});
```

### perf-structural-sharing

TanStack Query preserves referential identity for unchanged parts of the response. This works automatically with JSON-serializable data. Disable with `structuralSharing: false` for very large datasets where the diffing cost outweighs the benefit.

### perf-dont-disable-refetch-flags

Do not disable `refetchOnWindowFocus` or `refetchOnMount` globally. Instead, increase `staleTime` to reduce refetch frequency while keeping the safety net of automatic revalidation.

---

## 8. Testing (`test-`)

### test-isolate-query-client

Create a fresh `QueryClient` per test to prevent cache leaks:

```typescript
function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false },
    },
  });
}

function createWrapper() {
  const queryClient = createTestQueryClient();
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
}
```

### test-disable-retries

Always set `retry: false` in tests. Default 3 retries with exponential backoff cause slow, flaky tests.

### test-mock-at-network-level

Use MSW (Mock Service Worker) to mock Supabase HTTP responses instead of mocking the Supabase client directly. This tests the full integration path.

### test-await-query-resolution

Always wait for the query to resolve before asserting:

```typescript
const { result } = renderHook(() => useInvoices(), {
  wrapper: createWrapper(),
});
await waitFor(() => expect(result.current.isSuccess).toBe(true));
expect(result.current.data).toHaveLength(3);
```

---

## 9. Real-Time & Supabase (`realtime-`)

### realtime-invalidate-on-subscription-events

Use Supabase Realtime channels to invalidate queries instead of pushing full payloads:

```typescript
useEffect(() => {
  const channel = supabase
    .channel('invoices-changes')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'invoices' }, (payload) => {
      // Invalidate — let TanStack Query refetch
      queryClient.invalidateQueries({ queryKey: invoiceKeys.all });

      // For specific row changes, target the detail
      if (payload.new && 'id' in payload.new) {
        queryClient.invalidateQueries({
          queryKey: invoiceKeys.detail(payload.new.id),
        });
      }
    })
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
}, [queryClient]);
```

### realtime-set-infinite-stale-time-with-subscriptions

When Supabase Realtime pushes updates, set `staleTime: Infinity` so TanStack Query only refetches on invalidation from subscription events, not on window focus or mount.

### realtime-partial-cache-updates

For high-frequency changes (e.g., presence, counters), patch the cache directly instead of refetching the entire dataset:

```typescript
.on("postgres_changes", { event: "UPDATE", schema: "public", table: "invoices" },
  (payload) => {
    queryClient.setQueryData(
      invoiceKeys.detail(payload.new.id),
      payload.new
    );
  }
)
```

---

## Error Handling

### error-global-handler

Configure a global error handler at the `QueryCache` level for toast notifications. Avoid `onError` on individual `useQuery` calls (it fires per observer, causing duplicates):

```typescript
new QueryClient({
  queryCache: new QueryCache({
    onError: (error, query) => {
      // Only toast on background refetch failures (data already shown)
      if (query.state.data !== undefined) {
        toast.error(`Update failed: ${error.message}`);
      }
    },
  }),
});
```

### error-use-error-boundaries-for-critical-failures

Use `throwOnError` to propagate errors to React error boundaries for full-page failures. Use a function to selectively escalate:

```typescript
useQuery({
  ...projectOptions(id),
  throwOnError: (error) => error.code === 'PGRST116', // row not found
});
```

---

## Quick Reference: Supabase + TanStack Query Checklist

- [ ] `queryFn` always throws on Supabase `error` (never silently returns `null`)
- [ ] Query keys include all variables used in the Supabase query
- [ ] `queryOptions()` factories live in `features/*/queries.ts`
- [ ] Key factories use hierarchical `as const` pattern
- [ ] Route loaders use `ensureQueryData` for SSR prefetch
- [ ] `staleTime` is set per domain (not left at default `0` for everything)
- [ ] Mutations invalidate via key factory, not hardcoded strings
- [ ] `mutate` preferred over `mutateAsync` unless chaining
- [ ] Server state never copied to `useState`
- [ ] `select` used for partial subscriptions in list views
- [ ] Supabase Realtime invalidates queries, not replaces cache directly
- [ ] Global error handler at `QueryCache` level
- [ ] Tests use isolated `QueryClient` with `retry: false`
- [ ] TypeScript types inferred from `queryFn`, not manually annotated
- [ ] `skipToken` used instead of `enabled: false` for type safety
