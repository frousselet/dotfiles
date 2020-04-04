export PAGER="most"

export ZSH="$HOME/.oh-my-zsh"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

ZSH_DISABLE_COMPFIX=true

autoload -U colors && colors

PS1=$'%{$fg_bold[grey]%}%M::: %2~%{$reset_color%} %(!.%{$fg_bold[red]%}.%{$fg_bold[white]%})%n%{$reset_color%} %{$fg[cyan]%}=>%{$reset_color%} '

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
