# State Setter Props — Reference

When a parent passes 3+ thin callback props that only wrap local `setState`, pass `state + setState` directly instead. Keep explicit action callbacks for mutations, navigation, or side-effects.

**When to apply:**

- 3+ thin wrapper props like `onTitleChange`, `onSlugChange`, `onStatusChange` that only call `setState`
- Child is only editing parent-local form or UI state
- **Not** for mutations, navigation, analytics, or other side-effect callbacks

**Single-action rule:** If the child only needs 1 local state action, a specific setter (`setShowAddForm`, `setDeleteTarget`) is fine. Don't force `state + setState` for a single change.

## Incorrect — too many thin wrapper props

```tsx
function Parent() {
  const [form, setForm] = useState({
    title: "",
    slug: "",
    status: "draft" as "draft" | "published",
  });

  return (
    <BasicsSection
      title={form.title}
      slug={form.slug}
      status={form.status}
      onTitleChange={(title) => setForm((prev) => ({ ...prev, title }))}
      onSlugChange={(slug) => setForm((prev) => ({ ...prev, slug }))}
      onStatusChange={(status) => setForm((prev) => ({ ...prev, status }))}
    />
  );
}
```

## Preferred — pass state + setState

```tsx
type FormState = {
  title: string;
  slug: string;
  status: "draft" | "published";
};

function Parent() {
  const [form, setForm] = useState<FormState>({
    title: "",
    slug: "",
    status: "draft",
  });

  return <BasicsSection form={form} setForm={setForm} />;
}

function BasicsSection({
  form,
  setForm,
}: {
  form: FormState;
  setForm: React.Dispatch<React.SetStateAction<FormState>>;
}) {
  return (
    <>
      <input
        value={form.title}
        onChange={(e) => {
          const title = e.currentTarget.value;
          setForm((prev) => ({ ...prev, title }));
        }}
      />
      <input
        value={form.slug}
        onChange={(e) => {
          const slug = e.currentTarget.value;
          setForm((prev) => ({ ...prev, slug }));
        }}
      />
      <select
        value={form.status}
        onChange={(e) => {
          const status = e.currentTarget.value as FormState["status"];
          setForm((prev) => ({ ...prev, status }));
        }}
      >
        <option value="draft">Draft</option>
        <option value="published">Published</option>
      </select>
    </>
  );
}
```
