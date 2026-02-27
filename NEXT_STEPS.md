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

- Authenticate GitHub CLI (`gh` commands only):

```bash
gh auth login
```

- Confirm `gh` auth:

```bash
gh auth status
```

- Git identity is managed by dotfiles at
  `/Users/miguel.nadal/.dotfiles/.config/git/config`.
  Keep `user.name` and `user.email` (GitHub `noreply`) there as your source of truth.

- Configure Git push authentication (`git push`):
  - SSH (recommended):

```bash
ssh -T git@github.com
```

- If the SSH test fails, add an SSH key to GitHub and test again.
- Verify your remote uses SSH:

```bash
git -C ~/.dotfiles remote -v
```

- HTTPS option:
  - Keep remote as `https://...` and authenticate on first push using your credential manager/token.

- Verify commit identity before first push:

```bash
git config user.name
git config user.email
```

- If a push is rejected with `GH007` (private email protection), fix the latest commit and push again:

```bash
git commit --amend --reset-author --no-edit
git push origin master
```

## 3) Verify what was installed by this repo

- Core CLI tools expected:
  - `git`, `gh`, `mise`, `tmux`, `nvim`, `ripgrep`, `fd`, `fzf`, `zsh`.
- Core desktop apps expected:
  - `aerospace`, `alfred`, `cursor`, `codex`, `codex-app`, `meetily`,
    `ukelele`, `google-chrome`, `zen-browser`, `ghostty`, `obsidian`, `slack`,
    `spotify`, `telegram`, `whatsapp`, `hiddenbar`, `finicky`, `betterdisplay`.
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
  - Confirm your `settings.json` symlink is active (this repo links it automatically).
  - Use deterministic extension migration:
    - On your current machine (before moving), export and commit extension versions:

```bash
bash ~/.dotfiles/scripts/export_cursor_extensions.sh
cd ~/.dotfiles && git add apps/cursor/extensions.txt && git commit -m "chore(cursor): update extensions list" && git push
```

    - On the new machine (after pulling latest dotfiles), install extensions from that list:

```bash
# This is already executed by ~/.dotfiles/install.sh.
# You can rerun manually if needed.
bash ~/.dotfiles/scripts/install_cursor_extensions.sh
```

    - Verify installed extensions:

```bash
cursor --list-extensions --show-versions
```

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

## 10) BetterDisplay / 4K 120Hz tutorial

- Follow this setup tutorial:
  - https://forums.macrumors.com/threads/mac-mini-4k-120hz.2267035/page-31?post=31952813#post-31952813

## 11) Keyboard layout (GB + Spanish chars)

Karabiner should load automatically from the .config file

If not:

- Open Karaniber Settings --> Complex modifications.

Add the following:

```json
{
	"description": "Uppercase Spanish accents via dead keys",
	"manipulators": [
		{
			"from": {
				"key_code": "a",
				"modifiers": {
					"mandatory": ["left_option", "shift"],
					"optional": []
				}
			},
			"to": [
				{
					"key_code": "e",
					"modifiers": ["option"]
				},
				{
					"key_code": "a",
					"modifiers": ["shift"]
				}
			],
			"type": "basic"
		},
		{
			"from": {
				"key_code": "e",
				"modifiers": {
					"mandatory": ["left_option", "shift"],
					"optional": []
				}
			},
			"to": [
				{
					"key_code": "e",
					"modifiers": ["option"]
				},
				{
					"key_code": "e",
					"modifiers": ["shift"]
				}
			],
			"type": "basic"
		},
		{
			"from": {
				"key_code": "i",
				"modifiers": {
					"mandatory": ["left_option", "shift"],
					"optional": []
				}
			},
			"to": [
				{
					"key_code": "e",
					"modifiers": ["option"]
				},
				{
					"key_code": "i",
					"modifiers": ["shift"]
				}
			],
			"type": "basic"
		},
		{
			"from": {
				"key_code": "o",
				"modifiers": {
					"mandatory": ["left_option", "shift"],
					"optional": []
				}
			},
			"to": [
				{
					"key_code": "e",
					"modifiers": ["option"]
				},
				{
					"key_code": "o",
					"modifiers": ["shift"]
				}
			],
			"type": "basic"
		},
		{
			"from": {
				"key_code": "u",
				"modifiers": {
					"mandatory": ["left_option", "shift"],
					"optional": []
				}
			},
			"to": [
				{
					"key_code": "e",
					"modifiers": ["option"]
				},
				{
					"key_code": "u",
					"modifiers": ["shift"]
				}
			],
			"type": "basic"
		},
		{
			"from": {
				"key_code": "n",
				"modifiers": {
					"mandatory": ["left_option", "shift"],
					"optional": []
				}
			},
			"to": [
				{
					"key_code": "n",
					"modifiers": ["option"]
				},
				{
					"key_code": "n",
					"modifiers": ["shift"]
				}
			],
			"type": "basic"
		},
		{
			"from": {
				"key_code": "u",
				"modifiers": {
					"mandatory": ["right_option", "shift"],
					"optional": []
				}
			},
			"to": [
				{
					"key_code": "u",
					"modifiers": ["option"]
				},
				{
					"key_code": "u",
					"modifiers": ["shift"]
				}
			],
			"type": "basic"
		}
	]
}
```

```json
{
	"description": "Right option symbols and umlaut",
	"manipulators": [
		{
			"from": {
				"key_code": "u",
				"modifiers": {
					"mandatory": ["right_option"],
					"optional": []
				}
			},
			"to": [
				{
					"key_code": "u",
					"modifiers": ["option"]
				},
				{ "key_code": "u" }
			],
			"type": "basic"
		},
		{
			"from": {
				"key_code": "u",
				"modifiers": {
					"mandatory": ["right_option", "shift"],
					"optional": []
				}
			},
			"to": [
				{
					"key_code": "u",
					"modifiers": ["option"]
				},
				{
					"key_code": "u",
					"modifiers": ["shift"]
				}
			],
			"type": "basic"
		},
		{
			"from": {
				"key_code": "e",
				"modifiers": {
					"mandatory": ["right_option"],
					"optional": []
				}
			},
			"to": [
				{
					"key_code": "2",
					"modifiers": ["option", "shift"]
				}
			],
			"type": "basic"
		}
	]
}
```

```json
{
	"description": "Left option accents via dead keys",
	"manipulators": [
		{
			"from": {
				"key_code": "a",
				"modifiers": {
					"mandatory": ["left_option"],
					"optional": []
				}
			},
			"to": [
				{
					"key_code": "e",
					"modifiers": ["option"]
				},
				{ "key_code": "a" }
			],
			"type": "basic"
		},
		{
			"from": {
				"key_code": "e",
				"modifiers": {
					"mandatory": ["left_option"],
					"optional": []
				}
			},
			"to": [
				{
					"key_code": "e",
					"modifiers": ["option"]
				},
				{ "key_code": "e" }
			],
			"type": "basic"
		},
		{
			"from": {
				"key_code": "i",
				"modifiers": {
					"mandatory": ["left_option"],
					"optional": []
				}
			},
			"to": [
				{
					"key_code": "e",
					"modifiers": ["option"]
				},
				{ "key_code": "i" }
			],
			"type": "basic"
		},
		{
			"from": {
				"key_code": "o",
				"modifiers": {
					"mandatory": ["left_option"],
					"optional": []
				}
			},
			"to": [
				{
					"key_code": "e",
					"modifiers": ["option"]
				},
				{ "key_code": "o" }
			],
			"type": "basic"
		},
		{
			"from": {
				"key_code": "u",
				"modifiers": {
					"mandatory": ["left_option"],
					"optional": []
				}
			},
			"to": [
				{
					"key_code": "e",
					"modifiers": ["option"]
				},
				{ "key_code": "u" }
			],
			"type": "basic"
		},
		{
			"from": {
				"key_code": "n",
				"modifiers": {
					"mandatory": ["left_option"],
					"optional": []
				}
			},
			"to": [
				{
					"key_code": "n",
					"modifiers": ["option"]
				},
				{ "key_code": "n" }
			],
			"type": "basic"
		}
	]
}
```

## 12) Final checks

- Optional: run once more in case you updated `Brewfile`:

```bash
brew bundle --file ~/.dotfiles/Brewfile
```

- Restart once more after all app logins and permissions are granted.
