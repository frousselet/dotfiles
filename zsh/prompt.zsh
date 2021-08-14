docker_version() {
	if command -v docker > /dev/null; then
		if [ -f "Dockerfile" ]
		then
			echo " [docker:$(docker --version 2> /dev/null | cut -d ',' -f 1 | sed 's/Docker version //g')]"
		fi
	fi
}

node_version() {
	if command -v node > /dev/null; then
		if [ -f "package.json" ]
		then
			echo " [node:$(node -v | sed 's/v//g')] [$(jq -r '.name' < package.json):$(jq -r '.version' < package.json)]"
		fi
	fi
}

python_version() {
	if command -v python > /dev/null; then
		py_file_count="$(find . -maxdepth 1 -type f -name '*.py')"
		if [ $py_file_count ]
		then
			echo " [python:$(python --version | sed 's/Python //g')]"
		fi
	fi
}

terraform_version() {
	if command -v terraform > /dev/null; then
		tf_file_count="$(find .  -maxdepth 1 -type f -name '*.tf')"
		if [ $tf_file_count ]
		then
			echo " [terraform:$(tfenv version-name 2> /dev/null)/$(terraform workspace show 2> /dev/null)]"
		fi
	fi
}

vagrant_version() {
	if command -v vagrant > /dev/null; then
		if [ -f "Vagrantfile" ]
		then
			echo " [vagrant:$(vagrant --version 2> /dev/null | cut -d ' ' -f 2)]"
		fi
	fi
}

git_branch() {
	if command -v git > /dev/null; then
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
				gb="$gb/⋯"
			fi
			if [ $gs_P ]
			then
				gb="$gb/↑"
			fi
			echo " [git:$gb]"
		fi
	fi
}

aws_profile() {
	if command -v aws > /dev/null; then
		if [ $AWS_PROFILE ]
		then
			echo " [aws:$AWS_PROFILE]"
		fi
	fi
}

gcp_profile() {
	if command -v gcloud > /dev/null; then
		gcp=$(gcloud config get-value core/project)
		if [ $gcp ]
		then
			echo " [gcp:$gcp]"
		fi
	fi
}

preexec() {
	printf "\n"
}

PS1=$'\n\n%{$reset_color%}%(!.%{$fg[red]%}.%{$reset_color%})%n%{$reset_color%} : %(2~|%(!.%{$fg[red]%}.%{$fg[cyan]%})⋯%{$reset_color%}/%1~|%~)%(!.%{$fg[red]%}.%{$fg[cyan]%})$(git_branch)$(aws_profile)%{$reset_color%}\n%(?.%{$reset_color%}.%{$fg[red]%})->%{$reset_color%} '
