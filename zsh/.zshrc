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
source "$DOTCONFPATH/1password.zsh"
source "$DOTCONFPATH/gcloud.zsh"
source "$DOTCONFPATH/plugins.zsh"
source "$DOTCONFPATH/alias.zsh"
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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
autoload -U compinit; compinit
