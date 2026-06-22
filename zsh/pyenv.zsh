if command -v pyenv > /dev/null; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    # "pyenv init -" already wires up the shims path on modern pyenv, so the
    # separate "pyenv init --path" eval is redundant.
    eval "$(pyenv init -)"
fi