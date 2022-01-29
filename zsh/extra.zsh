# Things for the end...
source $ZSH/oh-my-zsh.sh
export GPG_TTY=$(tty)

if command -v cargo > /dev/null; then
  source $HOME/.cargo/env
fi