#!/bin/bash

GITHUB="https://github.com/frousselet/dotfiles.git"


###########
# OSX: Check Homebrew installation
######
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ ! command -v brew > /dev/null ]]; then
        printf "Installing Homebrew...\n"
        if command -v curl > /dev/null; then
            bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        elif command -v wget > /dev/null; then
            bash -c "$(wget https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -O -)"
        else
            printf "curl or wget not installed!\n"
            exit 1
        fi
    fi
fi


###########
# ALL: Check Git installation
######
if [[ ! command -v git > /dev/null ]]; then
    printf "Installing Git...\n"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install git
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ lsb_release -d | grep "ubuntu"]] || [[ lsb_release -d | grep "debian" ]]; then
            sudo apt-get -y install git
        else
            printf "git not installed!\n"
            exit 1
        fi
    fi
fi


###########
# ALL: Clone dotfiles
######
rm -rf "$HOME/.dotfiles"
git clone "$GITHUB" "$HOME/.dotfiles"


###########
# ALL: Configure ZSH
######
printf "Configure ZSH? (Y/n) "
read CONFIGURE_ZSH

if [[ "$CONFIGURE_ZSH" == "y" || "$CONFIGURE_ZSH" == "yes" ]];then
    printf "Configuring ZSH...\n"
    if command -v curl > /dev/null; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    elif command -v wget > /dev/null; then
        sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
    else
        printf "curl or wget not installed!\n"
        exit 1
    fi
    ln -sf "$HOME/.dotfiles/zsh/.zshrc" "$HOME/.zshrc"
    . "$HOME/.zshrc"
else
    printf "ZSH configuration skipped.\n"
fi
