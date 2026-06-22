export NVM_DIR="$HOME/.nvm"

# Lazy-load nvm: the large nvm.sh script is only sourced the first time
# nvm/node/npm/npx is called, which keeps shell startup fast. The stub
# functions are defined here (before plugins.zsh) so the node plugin is still
# detected via "command -v node".
if [ -s "$NVM_DIR/nvm.sh" ]; then
    _load_nvm() {
        unset -f nvm node npm npx 2> /dev/null
        \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    }
    nvm()  { _load_nvm; nvm "$@"; }
    node() { _load_nvm; node "$@"; }
    npm()  { _load_nvm; npm "$@"; }
    npx()  { _load_nvm; npx "$@"; }
fi
