# Things for the end...
source $ZSH/oh-my-zsh.sh
export GPG_TTY=$(tty)

if [[ -f "$HOME/.cargo/env" ]]
then
  source $HOME/.cargo/env
fi

autoload -U +X bashcompinit && bashcompinit

if [[ -f "/opt/homebrew/bin/terraform" ]]
then
  complete -o nospace -C /opt/homebrew/bin/terraform terraform
fi

if command -v fuck > /dev/null; then
  eval $(thefuck --alias)
fi

if [[ -d "/Library/TeX/texbin" ]]
then
  export PATH=$PATH:/Library/TeX/texbin
fi

export PATH="/opt/homebrew/bin:$PATH"
eval $(/opt/homebrew/bin/brew shellenv)

export HOMEBREW_NO_ENV_HINTS=true
