# cmux Browser Automation Reference

The `cmux browser` command group provides full browser automation against cmux browser surfaces.
Use it to navigate, interact with DOM elements, inspect pages, evaluate JS, and manage session data.

## Opening a Browser Pane

```bash
# Open a browser in a new split pane
cmux browser open-split https://example.com

# Open in the current surface
cmux browser open https://example.com
```

## Targeting a Surface

Most subcommands need a target surface. Pass it positionally or with `--surface`:

```bash
cmux browser identify                              # discover focused surface IDs
cmux browser surface:2 url                          # positional
cmux browser --surface surface:2 url                # flag (equivalent)
```

## Navigation

```bash
cmux browser surface:2 navigate https://example.org/docs --snapshot-after
cmux browser surface:2 back
cmux browser surface:2 forward
cmux browser surface:2 reload --snapshot-after
cmux browser surface:2 url
cmux browser surface:2 focus-webview
cmux browser surface:2 is-webview-focused
```

## Waiting

Block until a condition is met:

```bash
cmux browser surface:2 wait --load-state complete --timeout-ms 15000
cmux browser surface:2 wait --selector "#checkout" --timeout-ms 10000
cmux browser surface:2 wait --text "Order confirmed"
cmux browser surface:2 wait --url-contains "/dashboard"
cmux browser surface:2 wait --function "window.__appReady === true"
```

## DOM Interaction

All mutating actions support `--snapshot-after` for verification.

```bash
# Clicking
cmux browser surface:2 click "button[type='submit']" --snapshot-after
cmux browser surface:2 dblclick ".item-row"
cmux browser surface:2 hover "#menu"
cmux browser surface:2 focus "#email"

# Checkboxes
cmux browser surface:2 check "#terms"
cmux browser surface:2 uncheck "#newsletter"

# Scrolling
cmux browser surface:2 scroll-into-view "#pricing"
cmux browser surface:2 scroll --dy 800 --snapshot-after
cmux browser surface:2 scroll --selector "#log-view" --dx 0 --dy 400

# Text input
cmux browser surface:2 type "#search" "cmux"           # types character by character
cmux browser surface:2 fill "#email" --text "a@b.com"   # sets value directly
cmux browser surface:2 fill "#email" --text ""           # clear field
cmux browser surface:2 press Enter
cmux browser surface:2 keydown Shift
cmux browser surface:2 keyup Shift
cmux browser surface:2 select "#region" "us-east"
```

## Inspection

```bash
# Snapshots (accessibility tree — best for understanding page structure)
cmux browser surface:2 snapshot --interactive --compact
cmux browser surface:2 snapshot --selector "main" --max-depth 5

# Screenshots
cmux browser surface:2 screenshot --out /tmp/page.png

# Getters
cmux browser surface:2 get title
cmux browser surface:2 get url
cmux browser surface:2 get text "h1"
cmux browser surface:2 get html "main"
cmux browser surface:2 get value "#email"
cmux browser surface:2 get attr "a.primary" --attr href
cmux browser surface:2 get count ".row"
cmux browser surface:2 get box "#checkout"
cmux browser surface:2 get styles "#total" --property color

# Boolean checks
cmux browser surface:2 is visible "#checkout"
cmux browser surface:2 is enabled "button[type='submit']"
cmux browser surface:2 is checked "#terms"

# Find elements
cmux browser surface:2 find role button --name "Continue"
cmux browser surface:2 find text "Order confirmed"
cmux browser surface:2 find label "Email"
cmux browser surface:2 find placeholder "Search"
cmux browser surface:2 find testid "save-btn"
cmux browser surface:2 find first ".row"
cmux browser surface:2 find last ".row"
cmux browser surface:2 find nth 2 ".row"

# Highlight (visual debug)
cmux browser surface:2 highlight "#checkout"
```

## JavaScript

```bash
cmux browser surface:2 eval "document.title"
cmux browser surface:2 eval --script "window.location.href"
cmux browser surface:2 addinitscript "window.__cmuxReady = true;"
cmux browser surface:2 addscript "document.querySelector('#name')?.focus()"
cmux browser surface:2 addstyle "#debug-banner { display: none !important; }"
```

## Session Data

```bash
# Cookies
cmux browser surface:2 cookies get
cmux browser surface:2 cookies get --name session_id
cmux browser surface:2 cookies set session_id abc123 --domain example.com --path /
cmux browser surface:2 cookies clear --name session_id
cmux browser surface:2 cookies clear --all

# Storage
cmux browser surface:2 storage local set theme dark
cmux browser surface:2 storage local get theme
cmux browser surface:2 storage local clear
cmux browser surface:2 storage session set flow onboarding
cmux browser surface:2 storage session get flow

# Full state save/restore
cmux browser surface:2 state save /tmp/session.json
cmux browser surface:2 state load /tmp/session.json
```

## Tabs

```bash
cmux browser surface:2 tab list
cmux browser surface:2 tab new https://example.com/pricing
cmux browser surface:2 tab switch 1
cmux browser surface:2 tab close
```

## Console & Errors

```bash
cmux browser surface:2 console list
cmux browser surface:2 console clear
cmux browser surface:2 errors list
cmux browser surface:2 errors clear
```

## Dialogs & Frames

```bash
cmux browser surface:2 dialog accept
cmux browser surface:2 dialog dismiss
cmux browser surface:2 frame "iframe[name='checkout']"    # enter iframe
cmux browser surface:2 frame main                          # return to top
```

## Downloads

```bash
cmux browser surface:2 click "a#download-report"
cmux browser surface:2 download --path /tmp/report.csv --timeout-ms 30000
```

## Common Patterns

### Open dev server preview while coding

```bash
cmux browser open-split http://localhost:3000
SURFACE=$(cmux browser identify --json | jq -r '.surface_id')
cmux browser $SURFACE wait --load-state complete --timeout-ms 10000
cmux browser $SURFACE snapshot --interactive --compact
```

### Fill a form and verify

```bash
cmux browser $SURFACE fill "#email" --text "user@example.com"
cmux browser $SURFACE fill "#password" --text "$PASSWORD"
cmux browser $SURFACE click "button[type='submit']" --snapshot-after
cmux browser $SURFACE wait --text "Welcome"
```

### Debug on failure

```bash
cmux browser $SURFACE console list
cmux browser $SURFACE errors list
cmux browser $SURFACE screenshot --out /tmp/failure.png
```
