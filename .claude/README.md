# Claude Code Configuration

## Skills Organization

### `skills/` — Global skills

Symlinked to `~/.claude/skills/`. Always available in every project.

Contains workflow tools (tdd, grill-me, PRD tools, etc.) and personal coding conventions (react-my-patterns, typescript, etc.) that apply universally.

### `project-skills/` — Per-project skill templates

**Not** symlinked globally. Copy into a project's `.claude/skills/` when needed:

```sh
cp -r ~/.dotfiles/.claude/project-skills/tanstack-query <project>/.claude/skills/
```

| Skill                      | When to include                                    |
| -------------------------- | -------------------------------------------------- |
| tanstack-query             | Projects using TanStack Query                      |
| react-best-practices       | Performance-focused work (58 Vercel rules — heavy) |
| setup-pre-commit           | New project setup (one-time)                       |
| git-guardrails-claude-code | New project setup (one-time)                       |

These are kept separate because they're either tech-specific or one-time setup tools that add unnecessary context when loaded globally.
