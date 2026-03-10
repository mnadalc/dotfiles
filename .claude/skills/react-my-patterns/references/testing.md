# Testing — Reference

Full test file showing `renderComponent` helper, `userEvent.setup()`, MSW, and `describe`/`it` structure:

```tsx
// __tests__/Feature.test.tsx
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { http, HttpResponse } from "msw";
import { setupServer } from "msw/node";

import FeatureComponent from "../index";
import { mockFeatureItems } from "./mocks";

const server = setupServer(
  http.get("/feature-items", () => HttpResponse.json(mockFeatureItems)),
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

const renderComponent = () => {
  const user = userEvent.setup();
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });

  render(
    <QueryClientProvider client={queryClient}>
      <FeatureComponent />
    </QueryClientProvider>,
  );

  return { user };
};

describe("Feature", () => {
  it("renders item cards after loading", async () => {
    renderComponent();

    const itemTitle = await screen.findByText(/my item/i);
    expect(itemTitle).toBeInTheDocument();
  });

  it("opens drawer when clicking a card", async () => {
    const { user } = renderComponent();

    const itemCard = await screen.findByText(/my item/i);
    await user.click(itemCard);

    const drawerTitle = screen.getByRole('heading', { name: /edit feature item/i });
    expect(drawerTitle).toBeInTheDocument();
  });

  it("handles API error gracefully", async () => {
    server.use(
      http.get("/feature-items", () =>
        HttpResponse.json({ error: "Server error" }, { status: 500 }),
      ),
    );

    renderComponent();

    const errorMessage = await screen.findByText(/error/i);
    expect(errorMessage).toBeInTheDocument();
  });
});
```

## Scoping queries with `within`

When multiple similar elements exist, use `within` to narrow the search to a specific container:

```tsx
import { within } from "@testing-library/react";

// Find a specific row, then query inside it
const row = screen.getByRole("row", { name: /apples/i });
expect(within(row).getByText(/\$2\.50/i)).toBeInTheDocument();
```

## Custom matcher functions

When text is split across elements (e.g. `<p>Hello <strong>world</strong></p>`), use a matcher function:

```tsx
screen.getByText((content, node) => {
  const hasText = (n: Element) => n.textContent === "Hello world";
  const nodeHasText = hasText(node);
  const childrenDontHaveText = Array.from(node.children).every(
    (child) => !hasText(child),
  );
  return nodeHasText && childrenDontHaveText;
});
```

The `childrenDontHaveText` check ensures you match the outermost element that contains the full text, not a parent `<div>` wrapping it.

## Mock data file (`__tests__/mocks/index.ts`)

```tsx
import type { FeatureItem } from "../../types/types";

export const mockFeatureItems: FeatureItem[] = [
  {
    id: "1",
    name: "My Item",
    icon: "widgets",
    metaData: { author: "admin" },
  },
  {
    id: "2",
    name: "Another Item",
    icon: "settings",
    metaData: { author: "user" },
  },
];
```
