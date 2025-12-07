- In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

## PR Comments

- When tagging Claude in GitHub issues, use '@claude'

## Changesets

To add a changeset, write a new file to the `.changeset` directory.

The file should be named `0000-your-change.md`. Decide yourself whether to make it a patch, minor, or major change.

The format of the file should be:

```md
---
"project-name": patch
---

Description of the change.
```

The description of the change should be user-facing, describing which features were added or bugs were fixed.

## GitHub

- Your primary method for interacting with GitHub should be the GitHub CLI.
- If the project that you are working on is not part of ~/commercetools, `gh auth` should be `mnadalc`.
  If it's part of ~/commercetools, `gh auth` should be `nadalct`. If it's not matching, ask me to switch between `gh auth`.

## Git

- When creating branches, prefix them with mnadalc/ to indicate they came from me.

## Plans

- At the end of each plan, give me a list of unresolved questions to answer, if any. Make the questions extremely concise. Sacrifice grammar for the sake of concision.
