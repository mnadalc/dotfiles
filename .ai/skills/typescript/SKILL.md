---
name: typescript-best-practices
description: Strict TypeScript best practices for application code. Use this skill when writing, reviewing, or refactoring TypeScript — especially types, interfaces, generics, React component props, runtime validation, and tsconfig.
license: MIT
metadata:
  version: "1.0.0"
  source: "https://www.totaltypescript.com/articles"
---

# TypeScript Best Practices (Strict Mode)

Best practices extracted from Matt Pocock's Total TypeScript blog, adapted for a **strict TypeScript**.

## When to Apply

Reference these guidelines when:

- Writing or reviewing TypeScript types, interfaces, and generics
- Typing React component props and hooks
- Configuring `tsconfig.json`
- Deciding between type-time and runtime validation
- Optimizing TypeScript compiler performance
- Handling environment variables and global types
- Working with discriminated unions and pattern matching

## Rule Categories

| Priority | Category             | Prefix     |
| -------- | -------------------- | ---------- |
| 1        | Type Design          | `type-`    |
| 2        | No `any` Policy      | `any-`     |
| 3        | React & JSX Typing   | `react-`   |
| 4        | Generics             | `generic-` |
| 5        | Runtime Validation   | `runtime-` |
| 6        | TSConfig             | `config-`  |
| 7        | Performance          | `perf-`    |
| 8        | Patterns & Utilities | `pattern-` |

---

## 1. Type Design (`type-`)

### type-prefer-type-over-interface

Default to `type` aliases. Only use `interface` when you need object inheritance via `extends` (which is faster than `&` intersections).

Reason: interfaces allow accidental **declaration merging** (two interfaces with the same name silently merge), and they lack an **implicit index signature** that types provide.

```typescript
// DEFAULT: use type
type Invoice = {
  id: string;
  amount: number;
  status: "draft" | "sent" | "paid";
};

// EXCEPTION: use interface when extending (perf benefit)
interface ButtonProps extends ComponentProps<"button"> {
  variant: "primary" | "ghost";
}
```

Enable ESLint `no-redeclare` to catch accidental interface merging.

### type-use-discriminated-unions

Model state with discriminated unions, not bags of optionals. Each branch carries only the properties valid for that state:

```typescript
// WRONG: allows impossible states
type RequestState = {
  status: "idle" | "loading" | "success" | "error";
  data?: Invoice[];
  error?: Error;
};

// CORRECT: each state is explicit
type RequestState =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: Invoice[] }
  | { status: "error"; error: Error };
```

Use `status` (or `type`, `kind`) as the discriminant. Narrow with `if`/`switch` on that property.

### type-derive-vs-decouple

**Derive** types when they share a common concern and one should stay in sync with the other:

```typescript
type User = { id: string; name: string; email: string; role: Role };
type UserSummary = Pick<User, "id" | "name">;
```

**Decouple** types when they serve different concerns (e.g., DB row vs UI component props):

```typescript
// DB type (from Supabase)
type DbProject = Database["public"]["Tables"]["projects"]["Row"];

// UI type (independent — can evolve separately)
type ProjectCardProps = {
  title: string;
  description: string;
  avatarUrl: string;
};
```

Rule of thumb: if updating one must always update the other, derive. If they can change independently, decouple.

### type-no-enums

Do not use TypeScript enums. Use `as const` objects or union literals instead:

```typescript
// WRONG
enum Status {
  Draft,
  Active,
  Archived,
}

// CORRECT: union literal
type Status = "draft" | "active" | "archived";

// CORRECT: as const object (when you need runtime values + type)
const STATUS = {
  Draft: "draft",
  Active: "active",
  Archived: "archived",
} as const;

type Status = (typeof STATUS)[keyof typeof STATUS];
```

Enums have 71+ open bugs, inconsistent numeric/string behavior, and break structural typing.

### type-avoid-non-null-assertion

Avoid the `!` (non-null assertion) operator. It silences the compiler without any runtime safety. Instead, narrow with a type guard, early return, or assertion function:

```typescript
// WRONG: trusting blindly
const user = users.find((u) => u.id === id)!;

// CORRECT: narrow with an early return
const user = users.find((u) => u.id === id);
if (!user) return;

// CORRECT: narrow with an assertion function
const user = users.find((u) => u.id === id);
assertDefined(user, `User ${id} not found`);
```

### type-colocate-types

- **Single-use types**: keep in the same file where they're consumed.
- **Shared across a feature**: move to `features/invoices/types.ts`.
- **Shared app-wide**: move to `src/types/shared.ts`.
- **Shared across monorepo packages**: put in a dedicated `packages/types/` package.

### type-declare-return-types

Declare explicit return types for top-level module functions (not components). This makes intent clear and helps AI tooling and IDE navigation:

```typescript
// Top-level function: declare return type
export function calculateTotal(items: LineItem[]): number {
  return items.reduce((sum, item) => sum + item.amount, 0);
}

// React component: skip return type (always JSX)
export const InvoiceCard = ({ invoice }: InvoiceCardProps) => {
  return <div>{invoice.title}</div>;
};
```

### type-method-property-syntax

Use function property syntax in types/interfaces, never method shorthand. Method shorthand enables unsafe bivariant parameter checking:

```typescript
// WRONG: bivariant (unsafe)
type Handler = {
  handle(event: ClickEvent): void;
};

// CORRECT: contravariant (safe)
type Handler = {
  handle: (event: ClickEvent) => void;
};
```

Enforce with ESLint rule `@typescript-eslint/method-signature-style` set to `"property"`.

---

## 2. No `any` Policy (`any-`)

### any-ban-with-exceptions

Enable `@typescript-eslint/no-explicit-any`. Ban `any` from the codebase. Acceptable exceptions (use `eslint-disable` with a comment explaining why):

**Exception 1 — Type argument constraints** for generic utilities:

```typescript
// any[] is necessary here because unknown[] is too restrictive
// for function parameter positions (contravariance)
type Parameters<T extends (...args: any[]) => any> = T extends (
  ...args: infer P
) => any
  ? P
  : never;
```

**Exception 2 — Conditional return types** in generic functions where TS can't narrow:

```typescript
function toggle<T extends "on" | "off">(
  value: T,
): T extends "on" ? "off" : "on" {
  return (value === "on" ? "off" : "on") as any; // eslint-disable-line
  // Unit test covers correctness
}
```

Everything else: use `unknown` and narrow, or restructure the code.

### any-types-dont-exist-at-runtime

Never rely on TypeScript types for runtime safety. Types are erased at compile time. All external data (API responses, URL params, form inputs, localStorage) must be validated at runtime (see `runtime-` rules).

Type assertions (`as`) are lies to the compiler — they bypass checking with zero runtime effect. Avoid them except in the two exceptions above.

---

## 3. React & JSX Typing (`react-`)

### react-interface-extends-for-props

When extending native HTML element props, use `interface extends` (not `type &`). Intersections are significantly slower for the TS compiler on complex HTML attribute types:

```typescript
// WRONG: slow in large codebases
type InputProps = ComponentProps<"input"> & { label: string };

// CORRECT: fast
interface InputProps extends ComponentProps<"input"> {
  label: string;
}
```

### react-use-ComponentProps

Use `ComponentProps` (from React) to extract props from native elements or third-party components:

```typescript
import { type ComponentProps } from "react";

// Native element
type ButtonProps = ComponentProps<"button">;

// Third-party component
type DialogProps = ComponentProps<typeof Dialog>;

// With ref
type InputProps = ComponentPropsWithRef<"input">;
```

### react-discriminated-union-props

Use discriminated unions for component variants instead of optional prop soup:

```typescript
type AlertProps =
  | { variant: "info"; message: string }
  | { variant: "action"; message: string; onAction: () => void };
```

### react-type-events-properly

Use React's event types, not native DOM events:

```typescript
const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
  console.log(e.target.value);
};

// Or let TypeScript infer from inline handlers:
<input onChange={(e) => console.log(e.target.value)} />
```

### react-use-ElementRef-for-refs

Use `React.ElementRef` to strongly type refs:

```typescript
import { useRef, type ElementRef } from "react";

const inputRef = useRef<ElementRef<"input">>(null);
const dialogRef = useRef<ElementRef<typeof Dialog>>(null);
```

---

## 4. Generics (`generic-`)

### generic-mental-model

There is no such thing as "a generic". There are **generic types**, **generic functions**, and **generic classes**. They declare **type parameters** (slots). Consumers fill those slots with **type arguments** (values).

### generic-let-inference-work

Don't manually pass type arguments when TypeScript can infer them from runtime values:

```typescript
// WRONG: redundant type argument
const result = useState<string>("hello");

// CORRECT: inferred from "hello"
const result = useState("hello");
```

Only pass explicit type arguments when inference can't work (e.g., no runtime value to infer from).

### generic-use-const-type-parameters

Use `<const T>` to preserve literal types in function arguments (TS 5.0+):

```typescript
function createRoute<const T extends string>(path: T) {
  return { path };
}

const route = createRoute("/invoices/:id");
// route.path is "/invoices/:id", not string
```

### generic-object-property-order

When an object literal has generic-dependent properties, place the property that establishes the generic type **first**:

```typescript
// CORRECT: produce sets the type, consume reads it
createHandler({
  produce: () => ({ id: "123" }),
  consume: (data) => console.log(data.id), // data inferred correctly
});

// WRONG: consume evaluated before produce — data is unknown
createHandler({
  consume: (data) => console.log(data.id),
  produce: () => ({ id: "123" }),
});
```

---

## 5. Runtime Validation (`runtime-`)

### runtime-validate-at-boundaries

Use Zod (or similar) to validate data at **system boundaries** — where untrusted data enters your application:

- Supabase RPC/Edge Function request bodies
- URL search params and route params
- Form submissions
- `localStorage` / `sessionStorage` reads
- Third-party API responses
- WebSocket messages

Do NOT validate internal function calls or data flowing between your own modules.

### runtime-use-t3-env

Use `t3-env` + Zod to validate environment variables at startup:

```typescript
import { createEnv } from "@t3-oss/env-core";
import { z } from "zod";

export const env = createEnv({
  server: {
    DATABASE_URL: z.string().url(),
    SUPABASE_SERVICE_ROLE_KEY: z.string().min(1),
  },
  clientPrefix: "VITE_",
  client: {
    VITE_SUPABASE_URL: z.string().url(),
    VITE_SUPABASE_ANON_KEY: z.string().min(1),
  },
  runtimeEnv: import.meta.env,
});
```

This fails fast on startup if any variable is missing or malformed.

### runtime-safeParse-for-user-input

Use `.safeParse()` (not `.parse()`) for user-facing validation to return structured errors instead of throwing:

```typescript
const result = InvoiceSchema.safeParse(formData);
if (!result.success) {
  return { errors: result.error.flatten().fieldErrors };
}
// result.data is fully typed
```

### runtime-skip-validation-for-own-api

In a TanStack Start full-stack app where frontend and backend deploy together, skip Zod validation of your own server function responses. The blast radius of version drift is minimal — users just need to refresh.

---

## 6. TSConfig (`config-`)

### config-strict-baseline

Always enable these base options:

```jsonc
{
  "compilerOptions": {
    // Base
    "esModuleInterop": true,
    "skipLibCheck": true,
    "target": "es2022",
    "allowJs": true,
    "resolveJsonModule": true,
    "moduleDetection": "force",
    "isolatedModules": true,
    "verbatimModuleSyntax": true,

    // Strictness
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,

    // Non-transpiling (bundler handles emit)
    "module": "preserve",
    "noEmit": true,

    // Environment
    "lib": ["es2022", "dom", "dom.iterable"],
  },
}
```

### config-noUncheckedIndexedAccess

`noUncheckedIndexedAccess` is critical: it forces you to check that array/object lookups are defined before using them, preventing `undefined` runtime crashes:

```typescript
const items = ["a", "b", "c"];
const first = items[0]; // string | undefined (must check)

if (first !== undefined) {
  console.log(first.toUpperCase()); // safe
}
```

### config-verbatimModuleSyntax

Requires explicit `import type` / `export type` for type-only imports. Prevents bundler issues and makes the boundary between types and runtime values explicit:

```typescript
import type { Invoice } from "./types"; // erased at build
import { formatCurrency } from "./utils"; // kept at build
```

---

## 7. Performance (`perf-`)

### perf-interface-extends-over-intersection

Use `interface extends` instead of `type &` for combining object types. Intersections are slower because TS must flatten and check all members on every use. Interfaces are cached internally:

```typescript
// SLOW
type Combined = BaseProps & ExtraProps & MoreProps;

// FAST
interface Combined extends BaseProps, ExtraProps, MoreProps {}
```

This is most impactful when extending complex types like `React.HTMLAttributes<>`.

### perf-annotate-return-types-for-exported-functions

Adding return type annotations to exported functions helps the TS compiler avoid re-inferring types across module boundaries:

```typescript
export function getInvoice(id: string): Promise<Invoice> {
  return supabase
    .from("invoices")
    .select("*")
    .eq("id", id)
    .single()
    .then(/* ... */);
}
```

### perf-diagnose-with-traces

When the editor feels slow, profile:

```bash
tsc --generateTrace ./trace-output
```

Open the trace in Chrome DevTools (Performance tab) or `@typescript/analyze-trace` to find bottleneck types.

### perf-avoid-deep-conditional-types

Deeply nested conditional types (`A extends B ? C extends D ? ...`) exponentially increase check time. Flatten when possible or break into smaller named types.

---

## 8. Patterns & Utilities (`pattern-`)

### pattern-satisfies-operator

Use `satisfies` to validate a value conforms to a type while preserving its inferred (narrower) type:

```typescript
// Validates shape but preserves literal types
const routes = {
  home: { path: "/", search: {} },
  invoice: { path: "/invoices/:id", search: { tab: "details" } },
} as const satisfies Record<
  string,
  { path: string; search: Record<string, string> }
>;

// routes.invoice.path is "/invoices/:id", not string
```

Use cases:

- `as const satisfies Type` for validated immutable config objects
- Validating function arguments inline without losing inference
- Enforcing structure on route definitions, theme tokens, etc.

### pattern-type-predicates

Use type predicates for filtering and narrowing. TS 5.5+ infers them automatically from simple guards:

```typescript
// TS 5.5+ infers the predicate automatically
function isDefined<T>(value: T | undefined | null): value is T {
  return value != null;
}

const items = [1, undefined, 3, null, 5];
const defined = items.filter(isDefined); // number[]
```

### pattern-assertion-functions

Use assertion functions to narrow types via throwing:

```typescript
function assertIsAuthenticated(user: User | null): asserts user is User {
  if (!user) throw new Error("Not authenticated");
}

// After this call, user is narrowed to User
assertIsAuthenticated(currentUser);
console.log(currentUser.email); // safe
```

### pattern-branded-types

Use branded types for security-critical values that must not be confused with plain strings/numbers:

```typescript
type UserId = string & { readonly __brand: "UserId" };
type ProjectId = string & { readonly __brand: "ProjectId" };

function getProject(id: ProjectId): Promise<Project> {
  /* ... */
}

// Cannot accidentally pass a UserId where ProjectId is expected
const userId = "abc" as UserId;
getProject(userId); // ERROR
```

### pattern-exclude-and-extract

Use `Exclude` to remove members from unions and `Extract` to keep specific members:

```typescript
type Event =
  | { type: "click"; x: number; y: number }
  | { type: "focus" }
  | { type: "change"; value: string };

type NonClickEvent = Exclude<Event, { type: "click" }>;
type ClickEvent = Extract<Event, { type: "click" }>;
```

### pattern-object-keys-safely

`Object.keys()` returns `string[]` by design. Use a type predicate or generic function to iterate safely:

```typescript
// Type predicate approach (recommended)
function isKeyOf<T extends object>(obj: T, key: PropertyKey): key is keyof T {
  return key in obj;
}

Object.keys(config).forEach((key) => {
  if (isKeyOf(config, key)) {
    console.log(config[key]); // properly typed
  }
});
```

### pattern-array-reduce-typing

When `Array.reduce` builds an object, pass the type argument to avoid `{}` inference:

```typescript
const grouped = items.reduce<Record<string, Invoice[]>>((acc, item) => {
  (acc[item.status] ??= []).push(item);
  return acc;
}, {});
```

### pattern-const-prefer

Prefer `const` over `let`. `const` infers literal types; `let` widens to the base type:

```typescript
const status = "active"; // type: "active"
let status2 = "active"; // type: string
```

Use `const` by default. Only use `let` when reassignment is genuinely needed.

---

## Quick Reference Checklist

- [ ] `strict: true` + `noUncheckedIndexedAccess` + `verbatimModuleSyntax` in tsconfig
- [ ] Default to `type`, use `interface` only for `extends`
- [ ] No `any` — use `unknown` and narrow (ESLint `no-explicit-any`)
- [ ] No `!` (non-null assertion) — narrow with guards, early returns, or assertion functions
- [ ] No enums — use `as const` objects or union literals
- [ ] Discriminated unions for state modeling (not optional property bags)
- [ ] `interface extends` for React component props (not `type &`)
- [ ] `ComponentProps<"element">` for native element prop extraction
- [ ] Explicit return types on exported module functions (not components)
- [ ] Function property syntax in types, not method shorthand
- [ ] `satisfies` to validate without widening
- [ ] `skipToken` over `enabled: false` for conditional queries
- [ ] Zod at system boundaries only (not internal code)
- [ ] `t3-env` for environment variable validation
- [ ] `.safeParse()` for user input, `.parse()` for trusted data
- [ ] Branded types for security-critical IDs
- [ ] `const` by default, `let` only when reassignment is needed
- [ ] Co-locate types; share only when consumed by 2+ modules
- [ ] Derive related types; decouple unrelated concerns
