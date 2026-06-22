ZSH_DISABLE_COMPFIX=true
setopt PROMPT_SUBST

export LC_ALL=en_US.UTF-8

# Set up Homebrew early so every "command -v" check below (plugins, ruby,
# pyenv, aliases…) can see brew-installed tools.
if [[ -d "/opt/homebrew" ]]
then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -d "/home/linuxbrew/.linuxbrew" ]]
then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
export HOMEBREW_NO_ENV_HINTS=true

if command -v most > /dev/null; then
    export PAGER="most"
fi
export ZSH="$HOME/.oh-my-zsh"
