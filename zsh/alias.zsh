##########
# TERRAFORM
####

alias tf.u="tfenv install latest && tfenv use latest"
alias tf.i="terraform init"
alias tf.p="terraform plan"
alias tf.a="terraform apply"
alias tf.c="rm -rf .terraform*"

##########
# GIT
####

alias git.t="git log --graph --all --decorate --oneline --date=short"

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
