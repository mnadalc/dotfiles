---
name: react-my-patterns
description: Enforce React conventions — compound components, web-platform-first patterns, state management priority ladder, Zod schema-first typing, Tailwind styling with cn(), accessibility. Use when creating, modifying or refactoring React components, pages, or hooks.
---

# React Patterns

Follow these conventions when writing React code.

> **React version note:** These patterns target React <19. For React 19+ with the compiler: use `ref` as a regular prop (no `forwardRef`), drop `displayName`, and skip manual `useMemo`/`useCallback` — the compiler handles memoization.

## Compound Components

Build composable UI with the `Object.assign` pattern:

- Use `Object.assign(MainComponent, { Sub1, Sub2 })` to attach sub-components
- React <19: use `forwardRef` and set `displayName`
- React 19+: accept `ref` as a regular prop, no `forwardRef` or `displayName` needed
- Sub-components are plain functions
- Share state between parent and subs via a local Context when needed
- Parent can use `Children.forEach` to extract and reposition sub-components in a layout
- See [references/compound-components.md](references/compound-components.md) for code examples

## Props Philosophy

- **Minimal props** — pages receive zero props; derive state from URL params, hooks, and context
- **Common prop shape**: `{ children: ReactNode; className?: string }` aliased as `CommonProps`
- **Variants via union types**, not boolean flags: `variant: 'primary' | 'secondary' | 'icon'`
- **Type guards** for discriminated unions: `function isIconVariant(props): props is IconVariant`
- **State setter props** — when a parent passes 3+ thin callback props that only wrap local `setState`, pass `state + setState` directly instead. Keep explicit action callbacks for mutations, navigation, or side-effects. For 1 prop, keep the specific setter. For 2, use judgment. See [references/state-setter-props.md](references/state-setter-props.md) example.

## State Management

**Priority order** — always try the simplest option first:

1. **URL state** (`useSearchParams`) — tabs, filters, search, pagination. Shareable, bookmarkable, survives refresh
2. **Stateless / derived** — compute values from existing data instead of storing them. Avoid `useState` when you can derive
3. **`useState`** — simple local UI state (modals, toggles). Avoid `useEffect` to sync state — it's almost always a sign of unnecessary complexity
4. **`useReducer`** — complex local state with multiple related actions
5. **React Context** — scoped shared state (permissions, toast, feature-level state)
6. **External library** (Zustand) — last resort, only when Context genuinely falls short

**Avoid `useEffect` for state synchronization.** If you find yourself writing `useEffect` to keep two pieces of state in sync, rethink the data flow — derive one from the other, lift state up, or use a reducer. (`useEffect` is fine for side-effects like observers, event listeners, or subscriptions — just not for syncing state.)

**Server/async data** lives outside this ladder — use **React Query** (`useQuery`, `useSuspenseQuery`) with `queryOptions` helpers.

## Page Structure

- Entry point (`index.tsx`) wraps with Provider, page component handles layout
- Data fetching components use `useSuspenseQuery` wrapped in `<Suspense>`
- See [references/page-structure.md](references/page-structure.md) for full example

## File Organization

### Feature/page folder

```
feature-name/
  index.tsx                 # Entry point with Provider wrapping
  types/
    types.ts                # Zod schemas and type definitions
  utils/
    actions.ts              # Permission action constants
    feature-name.ts         # Type guards and filtering utilities
  components/
    FeaturePage.tsx          # Main layout (PageHeader + PageBody + Suspense)
    FeatureHeader.tsx        # Header with description and actions
    FeatureBody.tsx          # Main content area
    FeatureDrawer.tsx        # Side panel for editing
    SubComponent/
      SubComponent.tsx       # Nested component folders when needed
  hooks/
    useFeatureHook.tsx       # Reducer or custom hook for local state
    FeatureProvider.tsx      # Context provider
  api/
    getFeatureQuery.ts       # React Query queryOptions
    useUpdateMutation.tsx    # React Query mutations
  __tests__/
    Feature.test.tsx
    mocks/
      index.ts
```

### Shared component folder

```
ComponentName/
  ComponentName.tsx       # Main + sub-components + Object.assign
  VariantName.tsx         # Specialized variants (optional)
  __tests__/
    ComponentName.test.tsx
```

- Co-locate tests in `__tests__/`
- Keep compound sub-components in the same file unless they're large
- Variants (e.g., `SplitButton.tsx`, `InputPill.tsx`) get their own files

## Styling

- **Tailwind** with the `cn()` utility (clsx + tailwind-merge) if possible, otherwise use regular tailwind classes
- Variant classes defined as const maps: `VARIANT_CLASS: Record<Variant, string>`
- Always accept and merge `className` prop: `cn('defaults', className)`
- Conditional classes: `cn('base', { 'border-error': error, 'pl-8': leadingIcon })`
- **Avoid `!important`** (CSS) and `!` prefix (Tailwind) — fix specificity issues at the source
- **Avoid `z-index`** — restructure DOM order or use stacking contexts instead
- **Stack elements with CSS Grid, not `position: absolute`** — use grid area stacking for overlays, spinners on content, image captions, etc.
- See [references/styling.md](references/styling.md) for grid stacking patterns

## Web Platform First

Before building a custom abstraction, check if the browser already provides it. Use native HTML elements and Web APIs — they're battle-tested, accessible, and zero-bundle-cost. But respect React's rendering model: access the DOM through refs, not `document`.

**Principle**: if an HTML element or Web API does what you need, use it. Only build custom when the native solution genuinely falls short.

**Use freely in React:**

- HTML elements with built-in behavior: `<form>`, `<dialog>`, `<details>`, `<datalist>`, `<select>`, `popover` attribute
- `FormData` for collecting form values, `URLSearchParams` for query strings
- `Intl` for date/number/currency formatting (no libraries needed)
- `IntersectionObserver`, `ResizeObserver`, `MutationObserver` (via refs + `useEffect`)
- `AbortController` for cancelling fetch requests
- `localStorage` / `sessionStorage` for persistence
- CSS capabilities: `::backdrop`, `:has()`, `@container`, scroll-snap

**Avoid in React** (code smells):

- `document.querySelector` / `getElementById` — use `useRef` instead
- `document.createElement` — React should manage DOM creation
- `element.style.x = ...` — use `className` or `style` props
- `addEventListener` on `document`/`window` directly — use `useEffect` with cleanup

**Key patterns:**

- **Forms**: `<form onSubmit>` + `<button type="submit">`, never submit via `onClick`. Use the `form` attribute to connect submit buttons outside the `<form>` tag
- **Controlled vs uncontrolled**: prefer uncontrolled inputs (`defaultValue` + `FormData`) when no live processing is needed. Use controlled (`value` + `onChange`) only for real-time validation, derived state, or conditional UI
- **Modals**: use native `<dialog>` with `.showModal()` / `.close()` — gets backdrop, focus trap, and escape-to-close for free
- **URL as state**: see State Management priority #1
- See [references/web-platform.md](references/web-platform.md) for examples

## Conditional Rendering

- Always use ternary: `condition ? <Component /> : null`
- Never use `condition && <Component />` (risk of rendering falsy values like `0`)

## TypeScript Conventions

- Prefer `type` over `interface` for object shapes and props
- Use `import type { X }` for type-only imports
- Use discriminated unions with type guard functions

## Naming Conventions

- `SCREAMING_SNAKE_CASE` for constant config objects (`VARIANT_CLASS`, `COLUMN_CONFIG`)
- `handle*` for event handlers (`handleClose`, `handleSubmit`)
- `is*/has*` for booleans (`isSelected`, `hasPermission`)
- PascalCase for component files (`FeatureBody.tsx`)
- camelCase for utility files (`actions.ts`, `featureUtils.ts`)

## Import Order

Organize imports top-to-bottom:

1. React (`import React`, `import { useState }`)
2. Third-party libraries (`@tanstack/react-query`, `zod`, etc.)
3. Internal utils and shared code (`@/utils`, `@/components`)
4. Local components and hooks (`./components/`, `./hooks/`)
5. Types — separate `import type` statements

## Export Conventions

- **Default exports** for components (one component per file)
- **Named exports** for hooks and utilities
- Barrel files use: `export { default as ComponentName } from './ComponentName'`

## Testing Patterns

**Philosophy: quality over coverage.** Don't chase 100% coverage — test behavior that matters and avoid redundant assertions. Every test should justify its existence.

- Use `@testing-library/react` with `userEvent.setup()` (not `fireEvent`)
- Structure: `describe` blocks per component/feature, `it` blocks per behavior
- Create a `renderComponent()` helper for DRY test setup (wraps providers, default props)
- API mocking with MSW (`setupServer`, `http.get`, etc.)
- **Never test styles** — don't assert on classNames, inline styles, or computed styles

**Querying:**

- **Use `screen` for all queries** — no destructuring from `render()`
- **Query priority**: `*ByRole` > `*ByLabelText` > `*ByText` > `*ByTestId` (last resort)
- **Use case-insensitive regex for text matching** — always prefer `/text/i` over `'Text'`: `getByRole('heading', { name: /my heading/i })`, `findByText(/error/i)`
- **Use `within` to scope queries** — when multiple similar elements exist, narrow the search: `within(screen.getByRole('row', { name: /apples/i })).getByText(/price/i)`
- **Use custom matcher functions** — when text is split across elements: `screen.getByText((content, node) => node.textContent === 'Hello world')`
- **Never use `container.querySelector()`** — use semantic queries instead

**Async:**

- **Use `find*` queries for async elements** — not `waitFor` + `get*`
- **Single assertion per `waitFor`** — and never perform side effects inside `waitFor`

**Other rules:**

- Extract screen queries into named variables before using them in assertions or interactions
- Don't wrap `render()` or `userEvent` in `act()` — they handle it internally
- Don't add redundant ARIA roles to semantic HTML (`<button>` already has `role="button"`)
- Mock data lives in `__tests__/mocks/` directory
- See [references/testing.md](references/testing.md) for a full test file

## Error Handling

- All render errors should be caught by an **Error Boundary** component. The error UI (error page, toast, fallback) is project-specific
- Wrap feature-level routes or page components with an Error Boundary so a single component crash doesn't take down the whole app
- API errors in React Query: handle via `onError` callbacks or query error states — not try/catch in components
- **Wrap `await` calls in `try/catch/finally`** — `catch` for error handling, `finally` for cleanup (resetting loading states), success logic at end of `try`:

```tsx
setError(null);
setIsLoading(true);

try {
	const result = await someAsyncOperation();
	onSuccess(result);
} catch (error) {
	setError(error instanceof Error ? error.message : "Something went wrong.");
} finally {
	setIsLoading(false);
}
```

## Zod Schema-First Typing

- For **API responses and form data**: define a Zod schema first, then infer the TypeScript type with `z.infer<typeof Schema>`
- Never duplicate types manually when a Zod schema exists — always derive from the schema
- **React component props** use regular `type` definitions — no Zod schemas needed for props

## Custom Hook Extraction

- **`useReducer` hooks**: always extract into their own file — co-locate the reducer, actions, and types in the same file
- **Reused hooks**: if a hook is used in multiple components, give it its own file in `hooks/`
- **Single-use hooks**: if only used by one component, keep it inline or in the same file — no need for a separate file
- **Length rule**: if inline logic becomes long enough to obscure the component's JSX, extract it regardless of reuse

## Accessibility

- Always add meaningful `aria-label`, `aria-describedby`, `aria-labelledby` attributes to interactive elements
- Use semantic HTML elements (`<nav>`, `<main>`, `<section>`, `<button>`, `<dialog>`) — this is the foundation of accessibility
- Ensure all interactive elements are keyboard-accessible (focusable, operable with Enter/Space/Escape as appropriate)
- Icon-only buttons must have an `aria-label` describing the action
