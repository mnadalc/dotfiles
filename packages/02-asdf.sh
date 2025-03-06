#!/usr/bin/env bash

echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> $HOME/.zshrc && \
  asdf plugin add nodejs && \
  asdf install nodejs latest && \
  asdf global nodejs latest && \
  asdf plugin add ruby && \
  asdf install ruby latest && \
  asdf global ruby latest
