export DOTCONFPATH="$HOME/.dotfiles/zsh"

if [[ -d "$HOME/.zsh_extra/pre" ]]
then
    for file in $HOME/.zsh_extra/pre/*.zsh
    do
        if [[ -f "$file" ]]
        then
            source $file
        fi
    done
fi

source "$DOTCONFPATH/setup.zsh"
source "$DOTCONFPATH/prompt.zsh"
source "$DOTCONFPATH/ruby.zsh"
source "$DOTCONFPATH/pyenv.zsh"
source "$DOTCONFPATH/plugins.zsh"
source "$DOTCONFPATH/extra.zsh"

if [[ -d "$HOME/.zsh_extra/post" ]]
then
    for file in $HOME/.zsh_extra/post/*.zsh
    do
        if [[ -f "$file" ]]
        then
            source $file
        fi
    done
fi
