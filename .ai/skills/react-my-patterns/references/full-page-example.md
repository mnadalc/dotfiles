# Full Page Example — Reference

Shows the complete feature architecture: entry point with Provider, layout with Suspense, context-driven state, compound components, reducer pattern, and React Query.

## Entry point (index.tsx)

```tsx
const FeatureComponent = () => (
  <FeatureProvider>
    <FeaturePage />
  </FeatureProvider>
);
export default FeatureComponent;
```

## Context Provider (hooks/FeatureProvider.tsx)

```tsx
export const FeatureContext = createContext<{
  state: State;
  dispatch: Dispatch<Action>;
}>({ state: initialState, dispatch: () => {} });

export const FeatureProvider = ({ children }: { children: ReactNode }) => {
  const [state, dispatch] = useFeatureHook();

  return (
    <FeatureContext.Provider value={{ state, dispatch }}>
      {children}
    </FeatureContext.Provider>
  );
};
```

## Reducer hook (hooks/useFeatureHook.tsx)

```tsx
export type State = {
  users: string[];
  selectedItem:
    | FeatureItem
    | DraftSchema<FeatureItemSchema>
    | undefined;
};

export type Action =
  | { type: "SET_USERS"; payload: string[] }
  | {
      type: "SELECT_ITEM";
      payload: FeatureItem | DraftSchema<FeatureItemSchema>;
    }
  | { type: "UNSELECT_ITEM" }
  | { type: "RESET" };

const reducer = (state: State, action: Action): State => {
  switch (action.type) {
    case "SET_USERS":
      return { ...state, users: action.payload };
    case "SELECT_ITEM":
      return { ...state, selectedItem: action.payload };
    case "UNSELECT_ITEM":
      return { ...state, selectedItem: undefined };
    case "RESET":
      return initialState;
    default:
      return state;
  }
};

export const useFeatureHook = () => useReducer(reducer, initialState);
```

## Page layout (components/FeaturePage.tsx)

```tsx
const FeaturePage = () => (
  <>
    <FeatureHeader />
    <FeatureDrawer />
    <PageBody>
      <Suspense fallback={<CenteredSpinner />}>
        <FeatureBody />
      </Suspense>
    </PageBody>
  </>
);
```

## Header with compound components (components/FeatureHeader.tsx)

```tsx
const FeatureHeader = () => {
  const permissions = usePermissions<FeatureActionsType>();

  return (
    <PageHeader>
      <PageHeader.Header>Feature items</PageHeader.Header>
      <PageHeader.Body>
        <p>Manage your feature items.</p>
      </PageHeader.Body>
      <PageHeader.Footer>
        <PageOptions />
      </PageHeader.Footer>
    </PageHeader>
  );
};
```

## Body with useSuspenseQuery (components/FeatureBody.tsx)

```tsx
const FeatureBody = () => {
  const { state, dispatch } = useContext(FeatureContext);
  const { data: featureItems = [] } = useSuspenseQuery(getFeatureItemsQuery());

  const grouped = getGroupedFeatureItems(featureItems, searchQuery);

  return (
    <div className="flex flex-wrap gap-4 p-5">
      {[...grouped.entries()].map(([category, items]) => (
        <div key={category}>
          <h3 className="mb-2 text-sm font-semibold">{category}</h3>
          {items.map((item) => (
            <Card
              key={item.id}
              onClick={() =>
                dispatch({ type: "SELECT_ITEM", payload: item })
              }
              selected={state.selectedItem?.id === item.id}
            >
              <Card.Icon icon={item.icon} />
              <Card.Header>
                <p>{item.name}</p>
              </Card.Header>
              <Card.Content>
                <p>{item.metaData?.author}</p>
              </Card.Content>
            </Card>
          ))}
        </div>
      ))}
    </div>
  );
};
```

## Drawer with form (components/FeatureDrawer.tsx)

```tsx
const FeatureDrawer = () => {
  const { state, dispatch } = useContext(FeatureContext);
  const [saving, setSaving] = useState(false);
  const updateMutation = useUpdateFeatureItemMutation();
  const { open: openToast } = useToast();

  const open = !!state.selectedItem;
  const handleClose = () => dispatch({ type: "UNSELECT_ITEM" });

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();

    if (e instanceof FormEvent) {
      setSaving(true);

      const formData = new FormData(e.target as HTMLFormElement);
      updateMutation.mutate(
        { ...Object.fromEntries(formData) },
        {
          onSuccess: () => {
            openToast("success", "Item updated");
            handleClose();
          },
          onError: () => openToast("error", "Failed to update"),
          onSettled: () => setSaving(false),
        },
      );
    }
  };

  return (
    <Drawer open={open} onClose={handleClose}>
      <Drawer.Header>Edit feature item</Drawer.Header>
      <Drawer.Body>
        <form id="featureForm" onSubmit={onSubmit}>
          <Accordion title="General settings" expanded>
            <Accordion.Line title="Name">
              <Input
                name="name"
                defaultValue={state.selectedItem?.name}
              />
            </Accordion.Line>
          </Accordion>
        </form>
      </Drawer.Body>
      <Drawer.Footer>
        <Button variant="secondary" onClick={handleClose}>
          Cancel
        </Button>
        <Button type="submit" form="featureForm" loading={saving}>
          Save
        </Button>
      </Drawer.Footer>
    </Drawer>
  );
};
```

## API layer (api/getFeatureItemsQuery.ts)

```tsx
const getFeatureItemsQuery = () =>
  queryOptions({
    queryKey: ["featureItems"],
    queryFn: async () => {
      const response = await fetch("/feature-items");
      return FeatureItemSchema.array().parse(response);
    },
  });

export default getFeatureItemsQuery;
```

## Mutations (api/useUpdateFeatureItemMutation.tsx)

```tsx
const useUpdateFeatureItemMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: FeatureItem) =>
      fetch("/feature-items", { method: "PUT", body: data }),
    onSuccess: () =>
      queryClient.invalidateQueries({ queryKey: ["featureItems"] }),
  });
};

export default useUpdateFeatureItemMutation;
```
