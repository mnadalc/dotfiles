# Claude Code Configuration

## Skills Organization

### `skills/` — Shared global skills

Claude reads shared global skills through this path, but the canonical source of truth now lives in `.ai/skills`.

Repo adapter path:

```sh
.claude/skills -> ../.ai/skills
```

Laptop bootstrap path:

```sh
~/.claude/skills -> ~/.dotfiles/.ai/skills
```

This keeps shared skills portable between Claude and Codex while preserving Claude-specific config in `.claude/`.

Claude-specific files, the `statusline.sh` executable bit, and Claude MCP server registration are handled by `scripts/config_claude.sh`.
Context7 is registered through the remote OAuth endpoint. After setup, open Claude Code and complete the one-time auth flow with `/mcp`, select `context7`, then `Authenticate`.

### `.ai/project-specific-skills/` — Per-project skill templates

These are not symlinked globally. Copy them manually into a project's `.claude/skills/` when needed:

```sh
cp -r ~/.dotfiles/.ai/project-specific-skills/tanstack-query <project>/.claude/skills/
```

| Skill                      | When to include                                    |
| -------------------------- | -------------------------------------------------- |
| tanstack-query             | Projects using TanStack Query                      |
| react-best-practices       | Performance-focused work (58 Vercel rules — heavy) |
| setup-pre-commit           | New project setup (one-time)                       |
| git-guardrails-claude-code | New project setup (one-time)                       |

These stay separate because they're either tech-specific or one-time setup tools that add unnecessary context when loaded globally.
