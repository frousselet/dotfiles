#!/bin/bash

if ! command -v brew > /dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if command -v brew > /dev/null; then
  brew update
  brew install zsh git wget
  brew install --cask drawio rectangle tower netnewswire
  brew install --build-from-source terraform
fi

git config --global user.email "francois.rousselet@rslt.fr"
git config --global user.name "François Rousselet"

cd /home/$USER

# git clone https://github.com/frousselet/dotfiles.git .dotfiles
rm -rf .zshrc
ln -s .dotfiles/.zshrc .zshrc

ln -s /Users/$USER/Library/Mobile\ Documents/com\~apple\~CloudDocs/Projets Projets
