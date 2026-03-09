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

    const itemTitle = await screen.findByText("My Item");
    expect(itemTitle).toBeInTheDocument();
  });

  it("opens drawer when clicking a card", async () => {
    const { user } = renderComponent();

    const itemCard = await screen.findByText("My Item");
    await user.click(itemCard);

    const drawerTitle = screen.getByText("Edit feature item");
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
