# Context & Variants — Reference

## App Context with Provider Pattern

```tsx
type AppContextValue = {
  user: User;
};

const AppContext = createContext<AppContextValue | undefined>(undefined);

export const AppProvider = ({ children }: { children: ReactNode }) => {
  const [context, setContext] = useState<AppContextValue>(INITIAL_CONTEXT);
  return (
    <AppContext.Provider value={{ context, setContext }}>
      {children}
    </AppContext.Provider>
  );
};

export const useAppContext = () => {
  const context = useContext(AppContext);

  if (!context) {
    throw new Error("useAppContext must be used within AppProvider");
  }
  return context;
};
```

## Button Variant Map Pattern

```tsx
export const VARIANT_CLASS: Record<ButtonVariant, string> = {
  primary: "text-neutral-100 bg-interactive hover:bg-interactive-hover",
  secondary: "bg-transparent border border-neutral-400",
  danger: "text-neutral-100 bg-error hover:bg-error-hover",
  icon: "bg-transparent rounded-full p-1",
};
```
