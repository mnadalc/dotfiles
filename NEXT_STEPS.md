# Next Steps After Fresh Install

Use this checklist right after running:

```bash
cd ~/.dotfiles && bash ./install.sh
```

## 1) Terminal and shell

- Open a new terminal window (or restart the Mac) so shell changes are applied.
- Verify Homebrew is available:

```bash
brew --version
```

## 2) GitHub and Git (recommended first)

- Authenticate GitHub CLI:

```bash
gh auth login
```

- Confirm auth:

```bash
gh auth status
```

- Set Git identity (if not already set globally):

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

## 3) Verify what was installed by this repo

- Core CLI tools expected:
  - `git`, `gh`, `mise`, `tmux`, `nvim`, `ripgrep`, `fd`, `fzf`, `zsh`.
- Core desktop apps expected:
  - `aerospace`, `alfred`, `cursor`, `codex`, `codex-app`, `meetily`,
    `google-chrome`, `zen-browser`, `ghostty`, `obsidian`, `slack`,
    `spotify`, `telegram`, `whatsapp`, `hiddenbar`, `finicky`.
- Check Homebrew state:

```bash
brew bundle check --file ~/.dotfiles/Brewfile
```

- If anything is missing:

```bash
brew bundle --file ~/.dotfiles/Brewfile
```

## 4) Codex CLI

- Check installation:

```bash
codex --version
```

- Log in:

```bash
codex login
```

- Quick check:

```bash
codex
```

## 5) Claude CLI

- Check installation:

```bash
claude --version
```

- Log in:

```bash
claude login
```

Notes:
- Dotfiles already symlink `~/.claude` configuration.
- If `claude` is not installed yet, install it first, then run `claude login`.

## 6) Cursor / VS Code

- Cursor:
  - Open Cursor.
  - Sign in (account/provider).
  - Enable Settings Sync if you use it.
  - Confirm your `settings.json` symlink is active (this repo links it automatically).

- VS Code (if you use it):
  - Open VS Code.
  - Sign in and turn on Settings Sync.

## 7) Browsers

- Google Chrome:
  - Open Chrome and sign in to your Google account.
  - Turn on Chrome Sync (bookmarks, history, extensions, passwords as desired).

- Zen Browser:
  - Open Zen Browser.
  - Sign in to your Firefox account to sync tabs/bookmarks/passwords.
  - Verify Zen-specific add-ons/themes load as expected.

## 8) Meetily

- Confirm installation:

```bash
open -a Meetily
```

- Log in to Meetily in-app.
- Open Meetily settings and set:
  - Default model: `Local Whisper (high accuracy) Large`
  - Download transcription languages: `English (EN)`, `Spanish (ES)`,
    `French (FR)`, `German (DE)`

## 9) Wispr Flow (manual install, not in Homebrew)

- Install from the official site:
  - https://wisprflow.ai/
- Open Wispr Flow and log in.
- Grant macOS permissions when prompted (Microphone, Accessibility, etc.).

## 10) Final checks

- Optional: run once more in case you updated `Brewfile`:

```bash
brew bundle --file ~/.dotfiles/Brewfile
```

- Restart once more after all app logins and permissions are granted.
