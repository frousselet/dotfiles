export PAGER="most"
export ZSH="/home/frousselet/.oh-my-zsh"

# ZSH_THEME="evan"
ZSH_THEME="evan"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=black,bg=grey"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting node npm terraform vscode gitignore)

source $ZSH/oh-my-zsh.sh

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

alias ipinfo="curl -s ifconfig.co/json | jq"

export PATH="$HOME/.tfenv/bin:$PATH"

# eval $(thefuck --alias)

if [ -f '/tmp/google-cloud-sdk/path.zsh.inc' ]; then . '/tmp/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/tmp/google-cloud-sdk/completion.zsh.inc' ]; then . '/tmp/google-cloud-sdk/completion.zsh.inc'; fi

