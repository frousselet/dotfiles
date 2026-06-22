terraform_version() {
	command -v terraform > /dev/null || return
	local tf=(*.tf(N))
	(( ${#tf} )) || return
	echo " [terraform:$(terraform --version | head -n 1 | cut -d " " -f 2 | cut -c 2-)]"
}

git_branch() {
	command -v git > /dev/null || return

	local branch
	branch="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"
	[ -n "$branch" ] || return

	# Single status call instead of one git invocation per category.
	local st flags=""
	st="$(git status --porcelain 2> /dev/null)"
	grep -q '^??'   <<< "$st" && flags+="/+"
	grep -q '^ M'   <<< "$st" && flags+="/~"
	grep -q '^ D'   <<< "$st" && flags+="/-"
	grep -q '^[AM]' <<< "$st" && flags+="/⋯"

	# Ahead/behind vs the configured upstream (any remote, not just origin).
	local counts
	counts="$(git rev-list --left-right --count '@{upstream}...HEAD' 2> /dev/null)"
	if [[ -n "$counts" ]]; then
		(( ${counts[(w)2]} )) && flags+="/↑"  # commits ahead of upstream
		(( ${counts[(w)1]} )) && flags+="/↓"  # commits behind upstream
	fi

	echo " [git:$branch$flags]"
}

aws_profile() {
	command -v aws > /dev/null || return
	[[ -n "$AWS_PROFILE" ]] || return
	echo " [aws:$AWS_PROFILE]"
}

# Print a blank line before each command's output. Registered as a hook (rather
# than a bare preexec function) so it composes with plugins that also use one.
autoload -U add-zsh-hook
_blank_line_preexec() { printf "\n" }
add-zsh-hook preexec _blank_line_preexec

PS1=$'\n\n%B%F{240}---%f%b\n%B%m%b : %(2~|⋯/%1~|%~)%(!.%F{240}.%f)%B$(git_branch)$(aws_profile)$(terraform_version)%b%f%(?. %F{240}%B↪ %?. %F{red}%B↪ %?%b)\n%(?.%f%b.%F{red})%(!.%F{red}%B%n%f%b .%f)%B->%b%f '
