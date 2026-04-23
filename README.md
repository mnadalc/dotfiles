# dotfiles

## Setup

1. Install Apple's Command Line Tools (required for Git/Homebrew during install):

```bash
xcode-select --install
```

2. Download the dotfiles into `~/.dotfiles`.

If the machine is brand new (no Git / no browser needed), use the GitHub tarball:

```bash
mkdir -p ~/.dotfiles
curl -L https://github.com/mnadalc/dotfiles/archive/refs/heads/main.tar.gz \
  | tar -xz --strip-components=1 -C ~/.dotfiles
```

Or if Git is already available, clone as usual:

```
# Use SSH (if set up)
git clone git@github.com:mnadalc/dotfiles.git ~/.dotfiles

# Or use HTTPS
git clone https://github.com/mnadalc/dotfiles.git ~/.dotfiles
```

3. Execute install script

```bash
cd ~/.dotfiles && bash ./install.sh
```

4. Complete post-install logins and sync

Use the checklist in [`NEXT_STEPS.md`](NEXT_STEPS.md).

## AI Tooling

Shared Claude and Codex skills live in `.ai/skills`.

- `~/.claude/skills` and `~/.agents/skills` are created as symlinks to the shared skills folder during setup.
- `scripts/configure_ai_skills.sh` manages those shared skill symlinks.
- `scripts/config_claude.sh` manages Claude-specific files plus Claude MCP server registration.
- `scripts/config_codex.sh` manages Codex MCP registration.
- Project-specific templates live in `.ai/project-specific-skills` and are copied manually into a project's `.claude/skills` when needed.
- Context7 is configured as a user-scoped remote HTTP MCP server with OAuth. After setup, finish the one-time login in Claude Code with `/mcp`, select `context7`, then `Authenticate`.
- For Codex, `scripts/config_codex.sh` configures both `context7` and `openaiDeveloperDocs`. Finish the one-time OAuth flow for Context7 with `codex mcp login context7`.

### Vendored skills (external repos)

Third-party skill collections (currently [`mattpocock/skills`](https://github.com/mattpocock/skills)) are cloned into `.ai/vendor/` and exposed via symlinks under `.ai/skills/`. Your own real directories in `.ai/skills/` always win on name collision.

- `scripts/sync_vendor_skills.sh` clones (first run) or `git pull`s each vendor repo, then refreshes the symlinks. It also prunes symlinks whose upstream skill was removed.
- `.ai/vendor/` is gitignored — the vendored clones aren't tracked by this repo. Only the symlinks inside `.ai/skills/` are committed.
- **`git pull` on this repo does not update vendor skills** — it only updates the dotfiles and any committed symlinks. To refresh Matt's skills, run:

```bash
./scripts/sync_vendor_skills.sh
```

To add another upstream repo, append a `"local-name|git-url"` entry to `VENDOR_SKILL_REPOS` in that script.

See [`.ai/README.md`](.ai/README.md) for the rationale and layout details.

## cmux

cmux is installed from `Brewfile` via Homebrew and `install.sh` runs `scripts/configure_cmux.sh` to make the CLI available at `/usr/local/bin/cmux` using the upstream app-bundle binary.

## Individual scripts

You can run each script individually by executing them from the root directory.
Example:

```bash
cd .dotfiles && bash ./scripts/config_folder.sh
```

## Updating the root .config folder with only one folder

Run the following command at your root folder (`~`)

```bash
ln -s $(realpath ~/.dotfiles/.config/NEW_FOLDER_NAME) $HOME/.config/NEW_FOLDER_NAME
```
