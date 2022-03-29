ZSH_DISABLE_COMPFIX=true
setopt PROMPT_SUBST

export LC_ALL=en_US.UTF-8

if command -v most > /dev/null; then
    export PAGER="most"
fi
export ZSH="$HOME/.oh-my-zsh"
