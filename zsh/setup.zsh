ZSH_DISABLE_COMPFIX=true
setopt PROMPT_SUBST

if command -v most > /dev/null; then
    export PAGER="most"
fi
export ZSH="$HOME/.oh-my-zsh"
