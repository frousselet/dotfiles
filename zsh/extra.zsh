# Things for the end...
if [[ -f "$ZSH/oh-my-zsh.sh" ]]
then
  source "$ZSH/oh-my-zsh.sh"
fi

if command -v gpg > /dev/null; then
  export GPG_TTY=$(tty)
fi

if [[ -f "$HOME/.cargo/env" ]]
then
  source "$HOME/.cargo/env"
fi

# bashcompinit is only needed for the terraform "complete -C" below, so we
# load it (and the completion) only when terraform is actually installed —
# and we resolve its path instead of hardcoding the Homebrew location, so it
# works the same on macOS, Linuxbrew, etc.
if command -v terraform > /dev/null; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C "$(command -v terraform)" terraform
fi

if command -v thefuck > /dev/null; then
  eval "$(thefuck --alias)"
fi

if [[ -d "/Library/TeX/texbin" ]]
then
  export PATH=$PATH:/Library/TeX/texbin
fi
