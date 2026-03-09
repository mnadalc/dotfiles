# cmux Notifications Reference

cmux supports desktop notifications so AI agents and scripts can alert the user.

## Lifecycle

1. **Received** — appears in panel, desktop alert fires (unless suppressed)
2. **Unread** — badge on workspace tab
3. **Read** — cleared when user views that workspace
4. **Cleared** — removed from panel

Desktop alerts are suppressed when: cmux window is focused, the sending workspace
is active, or the notification panel is open.

Keyboard: `⌘⇧I` opens notification panel, `⌘⇧U` jumps to latest unread.

## Sending Notifications

### CLI (simplest)

```bash
cmux notify --title "Task Complete" --body "Your build finished"
cmux notify --title "Claude Code" --subtitle "Waiting" --body "Agent needs input"
cmux list-notifications --json
cmux clear-notifications
```

### OSC 777 (simple escape sequence)

```bash
printf '\e]777;notify;My Title;Message body here\a'
```

Shell helper:

```bash
notify_osc777() {
    local title="$1"
    local body="$2"
    printf '\e]777;notify;%s;%s\a' "$title" "$body"
}
notify_osc777 "Build Complete" "All tests passed"
```

### OSC 99 (rich — supports subtitles and IDs)

```bash
printf '\e]99;i=1;e=1;d=0;p=title:Build Complete\e\\'
printf '\e]99;i=1;e=1;d=0;p=subtitle:Project X\e\\'
printf '\e]99;i=1;e=1;d=1;p=body:All tests passed\e\\'
```

| Feature        | OSC 99 | OSC 777 |
|----------------|--------|---------|
| Title + body   | Yes    | Yes     |
| Subtitle       | Yes    | No      |
| Notification ID| Yes    | No      |

Use CLI for easiest integration, OSC 777 for simple, OSC 99 when you need subtitles/IDs.

## Custom Notification Command

Set in **Settings → App → Notification Command**. Runs via `/bin/sh -c` with env vars:

| Variable                      | Description          |
|-------------------------------|----------------------|
| `CMUX_NOTIFICATION_TITLE`     | Title                |
| `CMUX_NOTIFICATION_SUBTITLE`  | Subtitle             |
| `CMUX_NOTIFICATION_BODY`      | Body text            |

Examples:

```bash
say "$CMUX_NOTIFICATION_TITLE"                                           # text-to-speech
afplay /path/to/sound.aiff                                               # custom sound
echo "$CMUX_NOTIFICATION_TITLE: $CMUX_NOTIFICATION_BODY" >> ~/notif.log  # log to file
```

## Claude Code Hooks Integration

### 1. Create hook script

Save as `~/.claude/hooks/cmux-notify.sh`:

```bash
#!/bin/bash
[ -S /tmp/cmux.sock ] || exit 0

EVENT=$(cat)
EVENT_TYPE=$(echo "$EVENT" | jq -r '.event // "unknown"')
TOOL=$(echo "$EVENT" | jq -r '.tool_name // ""')

case "$EVENT_TYPE" in
    "Stop")
        cmux notify --title "Claude Code" --body "Session complete"
        ;;
    "PostToolUse")
        [ "$TOOL" = "Task" ] && cmux notify --title "Claude Code" --body "Agent finished"
        ;;
esac
```

```bash
chmod +x ~/.claude/hooks/cmux-notify.sh
```

### 2. Configure in settings.json

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": ["~/.claude/hooks/cmux-notify.sh"],
    "PostToolUse": [
      {
        "matcher": "Task",
        "hooks": ["~/.claude/hooks/cmux-notify.sh"]
      }
    ]
  }
}
```

Restart Claude Code to apply.

## Shell Integration

Add to `~/.zshrc`:

```bash
notify-after() {
  "$@"
  local exit_code=$?
  if [ $exit_code -eq 0 ]; then
    cmux notify --title "✓ Command Complete" --body "$1"
  else
    cmux notify --title "✗ Command Failed" --body "$1 (exit $exit_code)"
  fi
  return $exit_code
}
# Usage: notify-after npm run build
```

## tmux Passthrough

If running tmux inside cmux, enable passthrough in `.tmux.conf`:

```
set -g allow-passthrough on
```

Then:

```bash
printf '\ePtmux;\e\e]777;notify;Title;Body\a\e\\'
```
