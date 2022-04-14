# Things for the end...
source $ZSH/oh-my-zsh.sh
export GPG_TTY=$(tty)

if command -v cargo > /dev/null; then
  source $HOME/.cargo/env
fi

autoload -U +X bashcompinit && bashcompinit

if [[ -f "/opt/homebrew/bin/terraform" ]]
then
  complete -o nospace -C /opt/homebrew/bin/terraform terraform
fi
