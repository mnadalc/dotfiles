---
name: cmux
description: >
  Terminal multiplexer and workspace manager for AI coding agents (cmux by Manaflow).
  Use this skill whenever the user is running Claude Code inside cmux and wants to:
  split panes, open a browser alongside the terminal, send notifications,
  spawn parallel agents in separate panes, manage workspaces, or automate
  any terminal layout. Also use when tasks could benefit from being split
  into parallel panes (e.g. running a dev server in one pane and coding in another),
  or when the user needs to preview something in a browser pane.
  Trigger on mentions of "cmux", "split pane", "open browser pane",
  "notification", "workspace", or any request that implies multi-pane terminal work.
  When in doubt about whether cmux is available, check with: command -v cmux
---

# cmux — Terminal for AI Coding Agents

cmux is a native macOS terminal (Ghostty-based) with vertical tabs, split panes,
an embedded browser, notifications, and a full CLI/socket API.

## Detecting cmux

Before using cmux commands, verify availability:

```bash
# Check CLI exists
command -v cmux &>/dev/null && echo "cmux available"

# Check socket is live
SOCK="${CMUX_SOCKET_PATH:-/tmp/cmux.sock}"
[ -S "$SOCK" ] && echo "Socket available"

# Confirm we're inside a cmux surface
[ -n "${CMUX_WORKSPACE_ID:-}" ] && [ -n "${CMUX_SURFACE_ID:-}" ] && echo "Inside cmux"
```

If cmux is not available, fall back to standard terminal behavior and inform the user.

## Hierarchy

```
Window
└── Workspace (sidebar entry)
    └── Pane (split region)
        └── Surface (tab within pane)
            └── Panel (terminal or browser)
```

## Core CLI Commands

### Splits

```bash
cmux new-split right          # split pane to the right
cmux new-split down           # split pane downward
cmux new-split left           # split pane to the left
cmux new-split up             # split pane upward
```

### Send commands to surfaces

```bash
cmux list-surfaces --json                       # list all surfaces in workspace
cmux send "echo hello\n"                        # send text to focused surface
cmux send-surface --surface <id> "command\n"    # send text to specific surface
cmux send-key enter                             # send keypress to focused surface
cmux send-key-surface --surface <id> enter      # send keypress to specific surface
cmux focus-surface --surface <id>               # focus a specific surface
```

### Workspaces

```bash
cmux new-workspace                        # create new workspace
cmux list-workspaces --json               # list all workspaces
cmux select-workspace --workspace <id>    # switch to workspace
cmux current-workspace --json             # get current workspace info
cmux close-workspace --workspace <id>     # close workspace
```

### Browser

Open a browser pane and automate it:

```bash
cmux browser open-split https://localhost:3000    # open browser in new split
cmux browser open https://example.com             # open in current surface
cmux browser identify --json                      # get focused surface IDs
cmux browser surface:2 snapshot --interactive --compact   # inspect page structure
cmux browser surface:2 click "button.submit" --snapshot-after
cmux browser surface:2 wait --text "Success"
cmux browser surface:2 screenshot --out /tmp/page.png
cmux browser surface:2 eval "document.title"
```

**For full browser automation reference** (DOM interaction, form filling, JS eval,
cookies, storage, tabs, dialogs, downloads), read:
`references/browser-automation.md`

Use the browser when you need to:

- Preview a dev server alongside the terminal
- Inspect/debug a web page (snapshot the accessibility tree, read console errors)
- Fill forms, click buttons, verify UI state
- Take screenshots for the user
- Evaluate JavaScript on the page

### Notifications

```bash
cmux notify --title "Title" --body "Body"
cmux notify --title "T" --subtitle "S" --body "B"
cmux list-notifications --json
cmux clear-notifications
```

**For full notifications reference** (OSC escape sequences, Claude Code hooks setup,
custom notification commands, shell integration, tmux passthrough), read:
`references/notifications.md`

### Sidebar metadata

```bash
cmux set-status <key> "<value>" --icon <icon> --color "<hex>"
cmux clear-status <key>
cmux set-progress 0.5 --label "Building..."
cmux clear-progress
cmux log "Build started"
cmux log --level error --source build "Compilation failed"
cmux log --level success -- "All 42 tests passed"
cmux clear-log
cmux sidebar-state                        # dump all sidebar metadata
```

### Utility

```bash
cmux ping                    # check if cmux is running
cmux identify --json         # show current window/workspace/pane/surface context
cmux capabilities --json     # list available socket methods
```

## Common Patterns

### Spawn a parallel task in a new pane

```bash
cmux new-split right
# Get the new surface ID
SURFACES=$(cmux list-surfaces --json)
# Send a command to the new surface
cmux send "cd /path/to/project && npm run dev\n"
```

### Notify when a long task finishes

```bash
npm run build && cmux notify --title "✓ Build Success" --body "Ready to deploy" \
              || cmux notify --title "✗ Build Failed" --body "Check logs"
```

### Show progress in sidebar

```bash
cmux set-progress 0.0 --label "Starting..."
# ... during work ...
cmux set-progress 0.5 --label "Halfway..."
# ... done ...
cmux set-progress 1.0 --label "Done"
cmux clear-progress
```

## Tips

- Run `cmux --help` for the full list of subcommands and their flags.
- All CLI commands also have socket API equivalents via `/tmp/cmux.sock` (JSON-RPC over Unix socket).
