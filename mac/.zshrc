sw_vers

printf ""

# ZSH CONFIG
export ZSH=/Users/frousselet/.oh-my-zsh
export TERM="xterm-256color"

# ANTIGEN
rm $HOME/.zcompdump*
source $HOME/antigen.zsh
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

# JAVA
export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"

# PYTHON
PATH="/usr/local/share/python/:/usr/local/bin/python3:$PATH"

# SCALA
SCALA_HOME="/Users/frousselet/.scala/"
PATH="$SCALA_HOME/bin:$PATH"

# ZSH SETTINGS
ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="true"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# ALIASES
alias ov1='ssh ov1.francoisrousselet.fr'
alias ov2='ssh ov2.francoisrousselet.fr'
alias mx1='ssh 192.168.1.154'
alias sy1='ssh sy1.francoisrousselet.fr'

# tmux source ~/.tmux.conf &
# source /usr/local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh
