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
curl -L https://github.com/mnadalc/dotfiles/tarball/main \
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
