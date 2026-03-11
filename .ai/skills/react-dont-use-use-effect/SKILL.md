---
name: dont-use-use-effect
description: Enforce best practices for React Effects (useEffect). Use this skill whenever writing or reviewing React code that contains useEffect, whenever creating React components with derived state, data transformations, event handling, state synchronization, or external system integration. Also trigger when the user asks about useEffect best practices, Effect cleanup, dependency arrays, React performance, useEffectEvent, or when you see patterns like setting state inside useEffect based on props/state changes, chaining multiple useEffects, using useEffect for event-driven logic, missing cleanup functions, or suppressing the dependency linter. If you're about to write a useEffect, consult this skill first to check if there's a better pattern. Even when useEffect IS correct, this skill covers cleanup, dependencies, useEffectEvent, and lifecycle best practices.
---

# React Effects: When to Use, When to Avoid, and How to Write Them Well

This skill covers three concerns:

1. **When NOT to use useEffect** — common anti-patterns and their fixes
2. **When useEffect IS correct** — synchronizing with external systems
3. **How to write Effects well** — cleanup, dependencies, lifecycle, and useEffectEvent

## Core Mental Model

There are three types of logic in React components:

- **Rendering code** (top level): pure computation of JSX. No side effects.
- **Event handlers**: run in response to specific user interactions (clicks, submits, drags). Can have side effects.
- **Effects**: run because the component was _displayed_ (or re-displayed with different reactive values). Used to synchronize with external systems.

### The Decision Heuristic

Before writing `useEffect`, ask: **"Why does this code need to run?"**

| Reason                                                         | Where it belongs                                      |
| -------------------------------------------------------------- | ----------------------------------------------------- |
| User did something (click, submit, drag)                       | **Event handler**                                     |
| Component appeared on screen / needs sync with external system | **Effect**                                            |
| Props/state changed and I want to derive new values            | **Compute during render** (no Effect, no extra state) |

---

## Part 1: When NOT to Use useEffect

### 1. Derived / Redundant State

If a value can be calculated from existing props or state, don't put it in state. Compute during render.

```tsx
// 🔴 Redundant state + unnecessary Effect
const [fullName, setFullName] = useState('');
useEffect(() => {
  setFullName(firstName + ' ' + lastName);
}, [firstName, lastName]);

// ✅ Compute during render
const fullName = firstName + ' ' + lastName;
```

This avoids an extra render pass (React renders with stale value, then Effect fires and triggers re-render).

### 2. Expensive Derived Values

Use `useMemo` for genuinely expensive computations — not useEffect + setState.

```tsx
// 🔴 Effect for caching
const [visibleTodos, setVisibleTodos] = useState([]);
useEffect(() => {
  setVisibleTodos(getFilteredTodos(todos, filter));
}, [todos, filter]);

// ✅ useMemo (only if computation >1ms — measure with console.time())
const visibleTodos = useMemo(() => getFilteredTodos(todos, filter), [todos, filter]);
```

Note: React Compiler can auto-memoize in many cases, reducing the need for manual `useMemo`.

### 3. Resetting All State When a Prop Changes

Use `key` to reset the entire component subtree — React treats different keys as different component instances.

```tsx
// 🔴 Resetting state in an Effect
useEffect(() => {
  setComment('');
}, [userId]);

// ✅ Use key — all state resets automatically
<Profile userId={userId} key={userId} />;
```

### 4. Adjusting Partial State on Prop Change

Prefer deriving the value during render. Store an ID, compute the object.

```tsx
// 🔴 Effect to null out selection when items change
useEffect(() => {
  setSelection(null);
}, [items]);

// ✅ Derive it
const [selectedId, setSelectedId] = useState(null);
const selection = items.find((item) => item.id === selectedId) ?? null;
```

If you absolutely must compare previous props, the `prevItems` pattern (setState during render) works but is rarely needed.

### 5. Event-Specific Logic in Effects

If code runs because the user _did something_, it belongs in the event handler — not an Effect watching state.

```tsx
// 🔴 Fires on mount if product is already in cart (bug)
useEffect(() => {
  if (product.isInCart) showNotification('Added!');
}, [product]);

// ✅ Call from the event handler
function handleBuyClick() {
  addToCart(product);
  showNotification(`Added ${product.name}!`);
}
```

### 6. Chains of Effects

Multiple Effects where each sets state that triggers the next = cascading re-renders + fragile logic.

```tsx
// 🔴 Chain: setCard → Effect → setGoldCardCount → Effect → setRound
useEffect(() => {
  if (card?.gold) setGoldCardCount((c) => c + 1);
}, [card]);
useEffect(() => {
  if (goldCardCount > 3) {
    setRound((r) => r + 1);
    setGoldCardCount(0);
  }
}, [goldCardCount]);

// ✅ Derive during render + consolidate in event handler
const isGameOver = round > 5;
function handlePlaceCard(nextCard) {
  setCard(nextCard);
  if (nextCard.gold) {
    if (goldCardCount < 3) setGoldCardCount(goldCardCount + 1);
    else {
      setGoldCardCount(0);
      setRound(round + 1);
    }
  }
}
```

### 7. Notifying Parent of State Changes

Don't useEffect to call parent's onChange after state update — causes two render passes.

```tsx
// 🔴 Two render passes
useEffect(() => {
  onChange(isOn);
}, [isOn, onChange]);

// ✅ Update both in the same event
function updateToggle(nextIsOn) {
  setIsOn(nextIsOn);
  onChange(nextIsOn);
}
```

Even better: make the component fully controlled (parent owns state).

### 8. Passing Data to Parent

Data should flow **down**. If both parent and child need data, fetch in the parent.

```tsx
// 🔴 Data flows up via Effect
useEffect(() => {
  if (data) onFetched(data);
}, [data]);

// ✅ Parent fetches, passes down
// Parent: const data = useSomeAPI(); <Child data={data} />
```

### 9. Subscribing to External Stores

Use `useSyncExternalStore` instead of manual subscribe/unsubscribe in Effects.

```tsx
// 🔴 Manual subscription
useEffect(() => {
  const handler = () => setIsOnline(navigator.onLine);
  window.addEventListener('online', handler);
  window.addEventListener('offline', handler);
  return () => {
    /* cleanup */
  };
}, []);

// ✅ Purpose-built hook
const isOnline = useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot);
```

### 10. App Initialization

Don't rely on `useEffect(fn, [])` for one-time init — StrictMode double-mounts in dev.

```tsx
// 🔴 Runs twice in dev
useEffect(() => {
  checkAuthToken();
}, []);

// ✅ Module-level guard
let didInit = false;
function App() {
  useEffect(() => {
    if (!didInit) {
      didInit = true;
      checkAuthToken();
    }
  }, []);
}

// ✅ Or: top-level module code
if (typeof window !== 'undefined') {
  checkAuthToken();
}
```

---

## Part 2: When useEffect IS Correct

Effects synchronize your component with **external systems** — things outside React's rendering model:

- **Connecting/disconnecting** to a chat server, WebSocket, or third-party service
- **Controlling non-React DOM** elements (video play/pause, map zoom, dialog showModal)
- **Subscribing to browser APIs** (intersection observer, resize, online/offline)
- **Analytics/tracking** on component mount
- **Data fetching** (with cleanup) when framework data-fetching isn't available

### Example: Synchronizing with external DOM

```tsx
function VideoPlayer({ src, isPlaying }) {
  const ref = useRef(null);
  useEffect(() => {
    if (isPlaying) ref.current.play();
    else ref.current.pause();
  }, [isPlaying]);
  return <video ref={ref} src={src} loop playsInline />;
}
```

The browser `<video>` element has no `isPlaying` prop — you must imperatively call `.play()/.pause()`. This is synchronization with an external system, so an Effect is correct.

---

## Part 3: Writing Effects Well

### Cleanup

Every Effect that "starts" something should return a cleanup function that "stops" it. React calls cleanup before re-running the Effect with new values and when the component unmounts.

```tsx
useEffect(() => {
  const connection = createConnection(serverUrl, roomId);
  connection.connect();
  return () => connection.disconnect(); // cleanup
}, [roomId]);
```

Common cleanup patterns:

- **Connections**: connect → disconnect
- **Event listeners**: addEventListener → removeEventListener
- **Animations**: set value → reset to initial
- **Data fetching**: start fetch → ignore stale response
- **Timers**: setInterval/setTimeout → clearInterval/clearTimeout
- **Dialog**: showModal → close

### StrictMode Double-Mount

In development, React mounts → unmounts → mounts every component to verify cleanup works. If your Effect breaks on double-mount, it's missing cleanup — don't suppress with refs, fix the cleanup.

```tsx
// 🚩 Wrong: ref guard to prevent double-run hides the real bug
const didRun = useRef(false);
useEffect(() => {
  if (didRun.current) return;
  didRun.current = true;
  connection.connect(); // never cleaned up!
}, []);

// ✅ Right: proper cleanup
useEffect(() => {
  const conn = createConnection();
  conn.connect();
  return () => conn.disconnect();
}, []);
```

### Dependencies

Dependencies are not something you "choose" — they're derived from the reactive values your Effect reads. The linter enforces this.

```tsx
// No deps → runs after every render
useEffect(() => {
  /* ... */
});

// Empty deps → runs only on mount
useEffect(() => {
  /* ... */
}, []);

// Specific deps → runs on mount + when deps change
useEffect(() => {
  /* ... */
}, [roomId, serverUrl]);
```

**Never suppress the linter** (`eslint-disable-next-line react-hooks/exhaustive-deps`). If a dependency causes unwanted re-runs, the fix is to change the Effect code so it doesn't need that dependency — not to lie about deps.

Common strategies to reduce dependencies:

- Move object/function creation _inside_ the Effect
- Extract static values outside the component
- Use `useEffectEvent` for non-reactive logic read from within Effects

### Reactive vs Non-Reactive Logic: useEffectEvent

Sometimes an Effect needs to _read_ a reactive value without _reacting_ to it. Use `useEffectEvent` to extract non-reactive logic.

```tsx
// 🔴 theme causes reconnection (bad)
useEffect(() => {
  const connection = createConnection(serverUrl, roomId);
  connection.on('connected', () => {
    showNotification('Connected!', theme); // reads theme
  });
  connection.connect();
  return () => connection.disconnect();
}, [roomId, theme]); // theme shouldn't cause reconnect

// ✅ useEffectEvent: reads latest theme without reacting to it
const onConnected = useEffectEvent(() => {
  showNotification('Connected!', theme);
});

useEffect(() => {
  const connection = createConnection(serverUrl, roomId);
  connection.on('connected', () => onConnected());
  connection.connect();
  return () => connection.disconnect();
}, [roomId]); // only roomId triggers reconnect
```

**Rules for useEffectEvent:**

- Only call from inside Effects (or other Effect Events)
- Never pass to other components or hooks
- Always omit from dependency arrays (they're not reactive)
- Don't use it to avoid _legitimate_ dependencies — only for genuinely non-reactive reads

Another common use case — reading latest values in timers or intervals without restarting them:

```tsx
const onTick = useEffectEvent(() => {
  setCount(count + 1); // always reads latest count
});

useEffect(() => {
  const id = setInterval(() => onTick(), 1000);
  return () => clearInterval(id);
}, []); // timer never restarts
```

### Data Fetching: Always Handle Race Conditions

```tsx
useEffect(() => {
  let ignore = false;
  fetchResults(query, page).then((json) => {
    if (!ignore) setResults(json);
  });
  return () => {
    ignore = true;
  };
}, [query, page]);
```

For production apps, prefer TanStack Query, SWR, or framework-level data fetching over raw Effects. They handle caching, deduplication, SSR, and waterfall avoidance.

### Effect Lifecycle ≠ Component Lifecycle

Think of each Effect's lifecycle independently: it **starts synchronizing** (setup runs) and **stops synchronizing** (cleanup runs). This can happen multiple times during a component's life as dependencies change. Don't think in terms of mount/update/unmount — think in terms of start/stop synchronization.

### Each Effect = One Synchronization Process

Don't combine unrelated synchronization logic into one Effect. Split them:

```tsx
// 🔴 Two unrelated concerns in one Effect
useEffect(() => {
  logVisit(url);
  const connection = createConnection(roomId);
  connection.connect();
  return () => connection.disconnect();
}, [url, roomId]);

// ✅ Separate Effects for separate synchronization processes
useEffect(() => {
  logVisit(url);
}, [url]);
useEffect(() => {
  const connection = createConnection(roomId);
  connection.connect();
  return () => connection.disconnect();
}, [roomId]);
```

### Custom Hooks: Extract Effects Into Declarative APIs

Minimize raw `useEffect` calls in components. Extract into purpose-built custom hooks with declarative APIs:

```tsx
// 🔴 Abstract "lifecycle" hooks — anti-pattern
function useMount(fn) {
  useEffect(fn, []);
}

// ✅ Declarative, purpose-built hooks
function useChatRoom(roomId) {
  /* Effect inside */
}
function useOnlineStatus() {
  /* useSyncExternalStore inside */
}
function useData(url) {
  /* fetch Effect with cleanup inside */
}
```

Good custom hooks constrain what they do (useChatRoom can only connect to a room). Avoid abstract wrappers around useEffect that don't add semantic meaning.

---

## Quick Checklist

Before writing a `useEffect`:

- [ ] Can I compute this during render? → remove state + Effect, use a `const`
- [ ] Expensive computation? → `useMemo`, not Effect + setState
- [ ] Reset state on prop change? → use `key`
- [ ] Responding to user action? → event handler
- [ ] Chaining Effects? → consolidate in event handler or derive during render
- [ ] Syncing parent/child state? → lift state up or make component controlled
- [ ] External store subscription? → `useSyncExternalStore`
- [ ] Data fetching? → add cleanup; prefer TanStack Query / framework solutions

When writing a `useEffect`:

- [ ] Does it have proper cleanup? (connect/disconnect, subscribe/unsubscribe)
- [ ] Does it survive StrictMode double-mount?
- [ ] Are all reactive values in the dependency array? (never suppress linter)
- [ ] Does it mix reactive and non-reactive logic? → extract with `useEffectEvent`
- [ ] Does it combine unrelated concerns? → split into separate Effects
- [ ] Can it be extracted into a custom hook with a declarative API?
