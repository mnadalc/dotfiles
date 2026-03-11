# AI Tooling Layout

This folder is the canonical home for shared AI agent content in this dotfiles repo.

## Why `.ai` exists

Claude and Codex both use skills, but neither tool-specific folder should own the shared source of truth. Keeping shared skills in `.ai` makes the layout easier to understand and avoids coupling your reusable skills to one vendor path.

## Folder structure

### `skills/`

Globally shared skills for both Claude and Codex.

Edit shared skills here. Do not edit them through `.claude/skills` or `.agents/skills`; those are symlink adapter paths.

### `project-specific-skills/`

Templates and technology-specific skills that you copy into individual projects when needed.

These are not symlinked into `$HOME` as part of dotfiles setup. They stay in this repo as a manual source library.

## Symlink model

The laptop setup script creates these symlinks:

- `~/.claude/skills` -> `~/.dotfiles/.ai/skills`
- `~/.agents/skills` -> `~/.dotfiles/.ai/skills`

Those shared skill symlinks are managed by `scripts/configure_ai_skills.sh`.

Within the repo, these adapter paths also point to the same shared skills directory:

- `.claude/skills` -> `../.ai/skills`
- `.agents/skills` -> `../.ai/skills`

## Maintenance rule

- Shared global skills live in `.ai/skills`.
- Project templates live in `.ai/project-specific-skills`.
- Tool-specific configuration stays in `.claude/` or `.agents/`.
