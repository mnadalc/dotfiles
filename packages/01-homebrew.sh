#!/usr/bin/env bash

xcode-select --install && \
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
  echo '# Configure shell for Homebrew' >> ~/.zprofile && \
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile && \
  eval "$(/opt/homebrew/bin/brew shellenv)" && \
  brew doctor && \
  brew tap homebrew/bundle && \
  brew bundle --file ../Brewfile