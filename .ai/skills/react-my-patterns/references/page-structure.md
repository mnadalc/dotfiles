# Page Structure — Reference

## Entry point + Provider wrapping + layout

```tsx
// index.tsx — entry point
const FeatureComponent = () => (
  <FeatureProvider>
    <FeaturePage />
  </FeatureProvider>
);
export default FeatureComponent;

// components/FeaturePage.tsx — layout
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

// components/FeatureBody.tsx — data fetching with useSuspenseQuery
const FeatureBody = () => {
  const { state, dispatch } = useContext(FeatureContext);
  const { data } = useSuspenseQuery(getFeatureQuery());

  const items = data || [];

  return (
    <div className="flex flex-wrap gap-4">
      {items.map((item) => (
        <Card
          key={item.id}
          onClick={() => dispatch({ type: "SELECT", payload: item })}
        >
          <Card.Icon icon={item.icon} />
          <Card.Header>{item.name}</Card.Header>
          <Card.Content>{item.description}</Card.Content>
        </Card>
      ))}
    </div>
  );
};
```

## Query hook pattern

```tsx
const useExperimentsQuery = () => {
  const useGetExperimentsQuery = () =>
    useQuery({ queryKey: ["experiments"], queryFn: fetchExperiments });
  return { useGetExperimentsQuery };
};
```
