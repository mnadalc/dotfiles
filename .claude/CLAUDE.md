# cmux parallel agents

Always inside cmux. For parallel work, use cmux panes with Claude TUI (not Agent tool, not `-p`).

```
cmux new-split right/down
cmux send --surface <id> "claude --permission-mode auto 'prompt'\n"
cmux close-surface --surface <id>  # after done
```
