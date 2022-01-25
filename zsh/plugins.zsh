ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

plugins=()

if command -v git > /dev/null; then
    plugins+=git
fi

if command -v aws > /dev/null; then
    plugins+=aws
fi

if command -v pyenv > /dev/null; then
    plugins+=pyenv
fi

if command -v docker > /dev/null; then
    plugins+=docker
fi

if command -v ansible > /dev/null; then
    plugins+=ansible
fi

if command -v terraform > /dev/null; then
    plugins+=terraform
fi

if command -v node > /dev/null; then
    plugins+=node
fi

if command -v man > /dev/null; then
    plugins+=man
fi

if command -v brew > /dev/null; then
    plugins+=brew
fi

if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]
then
    plugins+=zsh-autosuggestions
fi

if [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]
then
    plugins+=zsh-syntax-highlighting
fi

if [[ -d "$ZSH_CUSTOM/plugins/lxd-completion-zsh" ]]
then
    plugins+=lxd-completion-zsh
fi

plugins+=genpass

SHOW_AWS_PROMPT=false
