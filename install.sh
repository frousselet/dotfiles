#!/bin/bash

GITHUB="https://github.com/frousselet/dotfiles.git"

if [[ ! command -v brew > /dev/null ]]
    printf "Installing Homebrew...\n"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Clone dotfiles
if [[ ! command -v git > /dev/null ]]
then
    printf "Installing Git...\n"
    if [[ "$OSTYPE" == "darwin"* ]]
    then
        brew install git
    elif [[ lsb_release -d | grep "ubuntu"]] || [[ lsb_release -d | grep "ubuntu" ]]
    then
        sudo apt-get -y install git
    fi
    exit 1
fi

rm -rf "$HOME/.dotfiles"
git clone "$GITHUB" "$HOME/.dotfiles"

# Install Oh-My-ZSH
if command -v curl > /dev/null; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
elif command -v wget > /dev/null; then
    sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
else
    printf "curl or wget not installed!\n"
    exit 1
fi

# Enable ZSH configuration
ln -sf "$HOME/.dotfiles/zsh/.zshrc" "$HOME/.zshrc"

. "$HOME/.zshrc"
