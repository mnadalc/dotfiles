# Compound Components — Reference

## Basic `Object.assign` Pattern

**React <19:**

```tsx
const HeaderComponent = forwardRef<HTMLDivElement, Props>(
  ({ children, className }, ref) => {
    return (
      <div ref={ref} className={cn("base-styles", className)}>
        {children}
      </div>
    );
  },
);
HeaderComponent.displayName = "PageHeader";

const Body = ({ children, className = "" }: CommonProps) => (
  <div className={cn("body-styles", className)}>{children}</div>
);

const PageHeader = Object.assign(HeaderComponent, { Body });
export default PageHeader;
```

**React 19+:**

```tsx
const HeaderComponent = ({ children, className, ref }: Props & { ref?: Ref<HTMLDivElement> }) => (
  <div ref={ref} className={cn("base-styles", className)}>
    {children}
  </div>
);

const Body = ({ children, className = "" }: CommonProps) => (
  <div className={cn("body-styles", className)}>{children}</div>
);

const PageHeader = Object.assign(HeaderComponent, { Body });
export default PageHeader;
```

## Compound Component with Internal Context (Card)

If really needed, use `Children.forEach` to extract sub-components and render them in a grid layout, plus a context to share `disabled` state:

```tsx
// CardComponent.tsx
const CardContext = createContext({ disabled: false });

const CardComponent = forwardRef<HTMLDivElement, CardComponentProps>(
  (
    { children, className, disabled = false, selected = false, ...props },
    ref,
  ) => {
    const elements = { icon: null, header: null, content: null, actions: null };

    Children.forEach(children, (child) => {
      if (isValidElement(child)) {
        if (child.type === Card.Icon) elements.icon = child;
        if (child.type === Card.Header) elements.header = child;
        if (child.type === Card.Content) elements.content = child;
        if (child.type === Card.Actions) elements.actions = child;
      }
    });

    return (
      <CardContext.Provider value={{ disabled }}>
        <div className={cn("group w-80 ...", className)} {...props}>
          <div className="grid h-full w-full">
            <div className="col-start-1 row-start-1 flex gap-x-2">
              {elements.icon}
              <div className="flex flex-1 flex-col gap-y-1">
                {elements.header}
                {elements.content}
              </div>
            </div>
            <div>{elements.actions}</div>
          </div>
        </div>
      </CardContext.Provider>
    );
  },
);
CardComponent.displayName = "Card";

const Card = Object.assign(CardComponent, {
  Icon: CardIcon,
  Header,
  Content,
  Actions,
});
export default Card;
```

Usage:

```tsx
<Card selected={isSelected} disabled={false}>
  <Card.Icon icon="widgets" />
  <Card.Header>Title</Card.Header>
  <Card.Content>Body text</Card.Content>
  <Card.Actions>
    <Button>Edit</Button>
  </Card.Actions>
</Card>
```

## Compound Component with Primitives (Drawer)

Wraps a third-party primitive (vaul) while maintaining the compound pattern:

```tsx
const DrawerComponent = React.forwardRef<...>(
  ({ children, direction = "right", ...props }, ref) => (
    <DrawerContext.Provider value={{ onClose: props.onClose }}>
      <DrawerPrimitive.Root direction={direction} {...props}>
        <DrawerPortal>
          <DrawerOverlay />
          <DrawerPrimitive.Content ref={ref} className={cn("fixed ...", className)}>
            {children}
          </DrawerPrimitive.Content>
        </DrawerPortal>
      </DrawerPrimitive.Root>
    </DrawerContext.Provider>
  ),
);

const Header = ({ className = "", children }) => {
  const { onClose } = useContext(DrawerContext);
  return (
    <>
      <div className={cn("flex h-14 items-center ...", className)}>
        <DrawerTitle>{children}</DrawerTitle>
        {onClose && (
          <DrawerClose asChild>
            <Button onClick={onClose} variant="icon">
              <Icon icon="x" />
            </Button>
          </DrawerClose>
        )}
      </div>
      <hr />
    </>
  );
};

const Body = ({ className = "", children }) => (
  <DrawerPrimitive.Description asChild>
    <div className={cn("h-full overflow-y-auto px-5 py-6", className)}>
      {children}
    </div>
  </DrawerPrimitive.Description>
);

const Footer = ({ className = "", children }) => (
  <div className={cn("inline-flex w-full px-6 pb-6 pt-10", className)}>
    {children}
  </div>
);

const Drawer = Object.assign(DrawerComponent, { Header, Body, Footer });
export default Drawer;
```
