node_version() {
	if command -v node > /dev/null; then
		if [ -f "package.json" ]
		then
			echo " %B[node:$(node -v | sed 's/v//g')] [$(jq -r '.name' < package.json):$(jq -r '.version' < package.json)]%b"
		fi
	fi
}

go_version() {
	if command -v go > /dev/null; then
		go_file_count="$(find . -maxdepth 1 -type f -name '*.go')"
		if [ $go_file_count ]
		then
			echo " [go:$(go version | cut -d " " -f 3 | cut -c 3-)]"
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
  cmd_start=$(($(print -P %D{%s%6.}) / 1000))
}

function precmd() {
  if [ $cmd_start ]; then
    local now=$(($(print -P %D{%s%6.}) / 1000))
    local d_ms=$(($now - $cmd_start))
    local d_s=$((d_ms / 1000))
    local ms=$((d_ms % 1000))
    local s=$((d_s % 60))
    local m=$(((d_s / 60) % 60))
    local h=$((d_s / 3600))

    if   ((h > 0)); then cmd_time=${h}h${m}m
    elif ((m > 0)); then cmd_time=${m}m${s}s
    elif ((s > 9)); then cmd_time=${s}.$(printf %03d $ms | cut -c1-2)s
    elif ((s > 0)); then cmd_time=${s}.$(printf %03d $ms)s
    else cmd_time=${ms}ms
    fi

    unset cmd_start
  else
    unset cmd_time
  fi
}

PS1=$'\n%{$reset_color%}$(if [ $cmd_time ]; then echo "%{$fg[cyan]%}($cmd_time) %{$reset_color%}"; fi)%(?..%{$fg[red]%}%BRETURNED %?%b%{$reset_color%})%{$reset_color%}\n\n\n%m : %(2~|⋯%{$reset_color%}/%1~|%~)%(!.%{$fg[red]%}.%{$fg[cyan]%})$(git_branch)$(aws_profile)$(terraform_version)$(python_version)$(go_version)%{$reset_color%}\n%(?.%{$reset_color%}.%{$fg[red]%})%(!.%{$fg[red]%}%B%n%{$reset_color%} .%{$reset_color%})%B>%b%{$reset_color%} '
