# Web Platform First — Reference

## Form — Uncontrolled with FormData

The common case: no live processing needed, just collect values on submit. Use `defaultValue` for initial values and the `FormData` API to read them. The `form` attribute connects submit buttons that live outside the `<form>` tag.

```tsx
const FeatureDrawer = () => {
  const [saving, setSaving] = useState(false);
  const updateMutation = useUpdateFeatureItemMutation();

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setSaving(true);

    const formData = new FormData(e.currentTarget);
    const values = Object.fromEntries(formData);

    updateMutation.mutate(values, {
      onSuccess: () => handleClose(),
      onSettled: () => setSaving(false),
    });
  };

  return (
    <Drawer open={open} onClose={handleClose}>
      <Drawer.Header>Edit item</Drawer.Header>
      <Drawer.Body>
        <form id="featureForm" onSubmit={handleSubmit}>
          <Input name="title" defaultValue={item?.title} />
          <Input name="slug" defaultValue={item?.slug} />
          <select name="status" defaultValue={item?.status}>
            <option value="draft">Draft</option>
            <option value="published">Published</option>
          </select>
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

Key points:
- `defaultValue` makes inputs uncontrolled — no `onChange` or `useState` needed
- `FormData` + `Object.fromEntries` extracts all named fields at once
- `form="featureForm"` on the button submits the form from outside the `<form>` tag
- `type="submit"` triggers the form's `onSubmit` — no `onClick` handler needed

## Form — Controlled (When Needed)

Use controlled inputs only when you need live processing: real-time validation, deriving one field from another, or conditional UI based on input state.

```tsx
const SettingsForm = () => {
  const [form, setForm] = useState<FormState>({
    title: "",
    slug: "",
  });

  return (
    <form onSubmit={handleSubmit}>
      <Input
        name="title"
        value={form.title}
        onChange={(e) => {
          const title = e.currentTarget.value;
          setForm((prev) => ({
            ...prev,
            title,
            slug: toSlug(title), // derives slug in real time
          }));
        }}
      />
      <Input
        name="slug"
        value={form.slug}
        onChange={(e) =>
          setForm((prev) => ({ ...prev, slug: e.currentTarget.value }))
        }
      />
      <Button type="submit">Save</Button>
    </form>
  );
};
```

**Decision rule**: if no field depends on another and you don't need live feedback, use uncontrolled + `FormData`. If fields are interdependent or you need instant validation, use controlled.

## Modal with Native `<dialog>`

Use the `<dialog>` element directly — it provides backdrop, focus trapping, and escape-to-close out of the box.

```tsx
const Modal = ({ children }: { children: ReactNode }) => {
  const dialogRef = useRef<HTMLDialogElement>(null);

  const open = () => dialogRef.current?.showModal();
  const close = () => dialogRef.current?.close();

  return { dialogRef, open, close };
};

// Usage
const MyComponent = () => {
  const dialogRef = useRef<HTMLDialogElement>(null);

  return (
    <>
      <Button onClick={() => dialogRef.current?.showModal()}>
        Open modal
      </Button>

      <dialog
        ref={dialogRef}
        className="rounded-lg p-0 backdrop:bg-black/50"
        onClose={() => {
          // fires on escape key or .close()
        }}
      >
        <div className="p-6">
          <h2 className="text-lg font-semibold">Confirm action</h2>
          <p className="mt-2">Are you sure you want to proceed?</p>
          <div className="mt-4 flex justify-end gap-2">
            <Button
              variant="secondary"
              onClick={() => dialogRef.current?.close()}
            >
              Cancel
            </Button>
            <Button onClick={handleConfirm}>Confirm</Button>
          </div>
        </div>
      </dialog>
    </>
  );
};
```

What you get for free:
- `::backdrop` pseudo-element for the overlay (styleable via CSS/Tailwind)
- Focus trapping — tab stays inside the dialog
- Escape key closes it automatically
- `onClose` event fires on both escape and `.close()`
- Proper accessibility (`role="dialog"`, `aria-modal="true"` automatic)

## URL as State Manager

Prefer URL search params for UI state that should be shareable, bookmarkable, or survive page refreshes — tabs, filters, search queries, pagination.

```tsx
const FeatureList = () => {
  const [searchParams, setSearchParams] = useSearchParams();

  const tab = searchParams.get("tab") ?? "all";
  const search = searchParams.get("q") ?? "";
  const page = Number(searchParams.get("page") ?? "1");

  const handleTabChange = (newTab: string) => {
    setSearchParams((prev) => {
      prev.set("tab", newTab);
      prev.delete("page"); // reset pagination on tab change
      return prev;
    });
  };

  const handleSearch = (query: string) => {
    setSearchParams((prev) => {
      if (query) {
        prev.set("q", query);
      } else {
        prev.delete("q");
      }
      prev.delete("page");
      return prev;
    });
  };

  return (
    <>
      <Tabs value={tab} onChange={handleTabChange} />
      <SearchInput value={search} onChange={handleSearch} />
      <ItemGrid items={filteredItems} />
      <Pagination page={page} />
    </>
  );
};
```

**When to use URL state vs `useState`:**

| URL search params | `useState` |
|---|---|
| Filters, search, tabs, pagination | Modal open/closed, hover state |
| User expects to share/bookmark the view | Purely visual, transient UI state |
| State should survive page refresh | State is ephemeral within a session |
