export PAGER="most"
export ZSH="$HOME/.oh-my-zsh"

ZSH_DISABLE_COMPFIX=true

autoload -U colors && colors

PROMPT="$fg[grey]%B%M ::: %2~$reset_color %(!.$fg[red].)%n $fg[cyan]=>$reset_color%b "

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=black,bg=grey"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

alias ipinfo="curl -s ifconfig.co/json | jq"

export PATH="$HOME/.tfenv/bin:$PATH"

