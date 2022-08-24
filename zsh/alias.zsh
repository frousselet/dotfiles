##########
# PYTHON
####

if command -v python3 > /dev/null; then
  alias python='python3'
fi

##########
# TERRAFORM
####

if command -v terraform > /dev/null; then
  alias tf.u="tfenv install latest && tfenv use latest"
  alias tf.i="terraform init"
  alias tf.p="terraform plan"
  alias tf.a="terraform apply"
  alias tf.c="rm -rf .terraform*"
fi

##########
# BREW
####

if command -v brew > /dev/null; then
  alias br.u="brew update && brew upgrade && brew autoremove"
  alias br.i="brew install"
fi

##########
# GIT
####

alias git.t="git log --graph --all --decorate --oneline --date=short"

##########
# LOCALSTACK AWS CLI
####

if command -v aws > /dev/null; then
  alias awsl="aws --endpoint-url=http://localhost:4566"
fi

##########
# MISC
####

batchrename() {
  bash /Users/${USER}/.dotfiles/scripts/batch-rename.sh "$@"
}

wol() {
  wakeonlan "$@"
}

update_dotfiles() {
  cd ${DOTCONFPATH}/..
  git pull
  printf "Moved back to directory "
  cd -
}
