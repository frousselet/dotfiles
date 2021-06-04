#!/bin/bash

# Clone dotfiles
if command -v git > /dev/null; then
    rm -rf $HOME/.dotfiles
    git clone https://github.com/frousselet/dotfiles.git $HOME/.dotfiles
else
    printf "Git not installed!"
    exit 1
fi

# Install Oh-My-ZSH
if command -v curl > /dev/null; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
fi

# Enable ZSH configuration
ln -sf "$HOME/.dotfiles/zsh/.zshrc" "$HOME/.zshrc"

. $HOME/.zshrc
