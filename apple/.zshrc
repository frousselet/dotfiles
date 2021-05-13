ZSH_DISABLE_COMPFIX=true

setopt PROMPT_SUBST

export PAGER="most"

docker_version() {
	if [ -f "Dockerfile" ]
	then
		echo " [docker:$(docker --version 2> /dev/null | cut -d ',' -f 1 | sed 's/Docker version //g')]"
	fi
}

node_version() {
	if [ -f "package.json" ]
	then
		echo " [node:$(node -v | sed 's/v//g')]"
	fi
}

python_version() {
	py_file_count="$(find . -type f -name '*.py' -maxdepth 1)"
	if [ $py_file_count ]
	then
		echo " [python:$(python --version | sed 's/Python //g')]"
	fi
}

terraform_version() {
	tf_file_count="$(find . -type f -name '*.tf' -maxdepth 1)"
	if [ $tf_file_count ]
	then
		echo " [terraform:$(tfenv version-name 2> /dev/null)]"
	fi
}

git_branch() {
	gb="$(git branch 2> /dev/null | grep '*' | sed 's/* //')"
	if [ $gb ]
	then
		gs_M="$(git status --short 2> /dev/null | grep "^ M" | wc -l | sed 's/ //g' | sed 's/\n//g' | sed 's/0//g')"
		gs_D="$(git status --short 2> /dev/null | grep "^ D" | wc -l | sed 's/ //g' | sed 's/\n//g' | sed 's/0//g')"
		gs_U="$(git status --short 2> /dev/null | grep "^??" | wc -l | sed 's/ //g' | sed 's/\n//g' | sed 's/0//g')"
		gs_A="$(git status --short 2> /dev/null | grep "^[A|M]" | wc -l | sed 's/ //g' | sed 's/\n//g' | sed 's/0//g')"
		gs_P="$(git log origin/$gb..$gb 2> /dev/null | wc -l | sed 's/ //g' | sed 's/\n//g' | sed 's/0//g')"
		if [ $gs_U ]
		then
			gb="$gb/+"
		fi
		if [ $gs_M ]
                then
                        gb="$gb/~"
                fi
		if [ $gs_D ]
                then
                        gb="$gb/-"
                fi
		if [ $gs_A ]
                then
                        gb="$gb/‥"
                fi
		if [ $gs_P ]
                then
                        gb="$gb/↑"
                fi
		echo " [git:$gb]"
	fi
}

aws_profile() {
	if [ $AWS_PROFILE ]
	then
		echo " [aws:$AWS_PROFILE]"
	fi
}

gcp_profile() {
	gcp=$(gcloud config get-value core/project)
	if [ $gcp ]
	then
		echo " [gcp:$gcp]"
	fi
}

export ZSH="/Users/francois/.oh-my-zsh"

PS1=$'\n%{$reset_color%}%{$fg[black]%}%(!.%{$bg[red]%}.%{$bg[cyan]%})%n%{$reset_color%} %(2~|%{$fg[cyan]%}⋯%{$reset_color%}/%1~|%~)%{$fg_bold[cyan]%}$(git_branch)$(docker_version)$(terraform_version)$(aws_profile)$(python_version)$(node_version)%{$reset_color%}\n%(?.%{$fg_bold[cyan]%}.%{$fg_bold[red]%})>%{$reset_color%} '

plugins=(git pyenv aws docker osx ansible terraform node man brew genpass zsh-autosuggestions zsh-syntax-highlighting)

SHOW_AWS_PROMPT=false

source $ZSH/oh-my-zsh.sh

export PATH="/usr/local/opt/ruby/bin:$PATH"

eval "$(pyenv init -)"
