terraform_version() {
	if command -v terraform > /dev/null; then
		tf_file_count="$(find .  -maxdepth 1 -type f -name '*.tf')"
		if [ $tf_file_count ]
		then
			echo " [terraform:$(terraform --version | head -n 1 | cut -d " " -f 2 | cut -c 2-)]"
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

function preexec() {
	printf "\n"
}

PS1=$'\n%B%{$fg[grey]%}---%b%{$reset_color%}\n%B%m%b : %(2~|⋯%{$reset_color%}/%1~|%~)%(!.%{$fg[grey]%}.%{$fg[default]%})%B$(git_branch)$(aws_profile)$(terraform_version)%b%{$reset_color%}%(?. %{$fg[grey]%}%B↪ %?. %{$fg[red]%}%B↪ %?%b)\n%(?.%{$reset_color%}.%{$fg[red]%})%(!.%{$fg[red]%}%B%n%{$reset_color%} .%{$reset_color%})%B->%b%{$reset_color%} '
