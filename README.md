# dotfiles

## Setup

1. Install Apple's Command Line Tools, which are prerequisites for Git and Homebrew.
   This is not needed if you already have the repo downloaded, since it's part of the installation process.

```bash
xcode-select --install
```

2. Clone repo into new hidden directory

```
# Use SSH (if set up)
git clone git@github.com:mnadalc/dotfiles.git .dotfiles

# Or use HTTPS
git clone https://github.com/mnadalc/dotfiles.git .dotfiles
```

3. Execute install script

```bash
cd .dotfiles && bash ./install.sh
```
