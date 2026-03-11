# Styling — Reference

## Grid Stacking (instead of `position: absolute`)

When overlapping elements (image with overlay, loading spinner on content, stacked cards), use CSS Grid to place all children in the same cell.

### Tailwind — descendant selector (preferred)

Keeps children clean — no extra classes needed on each child:

```tsx
<div className="grid [&>*]:col-start-1 [&>*]:row-start-1">
  <img src={src} alt={alt} />
  <div className="place-self-center">Overlay text</div>
</div>
```

### Tailwind — explicit classes on children

When only some children should stack:

```tsx
<div className="grid">
  <img className="col-start-1 row-start-1" src={src} alt={alt} />
  <div className="col-start-1 row-start-1 place-self-end">Caption</div>
</div>
```

### CSS — named grid area

```css
.stack {
  display: grid;
  grid-template-areas: 'stack';
}
.stack > * {
  grid-area: stack;
}
```

### CSS — shorthand with `grid-area`

`grid-area: 1/1;` is shorthand for `grid-row: 1; grid-column: 1;`:

```css
.stack {
  display: grid;
}
.stack > * {
  grid-area: 1/1;
}
```

## Positioning children within the stack

Use `place-self` to position individual children within the shared grid cell:

```tsx
<div className="grid [&>*]:col-start-1 [&>*]:row-start-1">
  <img src={src} alt={alt} />
  <div className="place-self-start start">Top left</div>
  <div className="place-self-center">Center</div>
  <div className="place-self-end">Bottom right</div>
  <div className="self-center justify-self-end">Center right</div>
</div>
```

Tailwind `place-self` utilities: `place-self-center`, `place-self-start`, `place-self-end`, `place-self-stretch`
