##############################################################################
# Dynamic prompt segments
#
# git/aws/terraform info is computed in a background worker and injected into
# the prompt asynchronously, so a slow "git status" (large repo) never blocks
# the prompt. The worker writes to a pipe watched by "zle -F"; when it's done
# we store the result and redraw with "zle reset-prompt".
##############################################################################

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

# ── Async machinery ─────────────────────────────────────────────────────────

# Rendered segments, filled in asynchronously and referenced from PS1.
typeset -g _PROMPT_INFO=""
typeset -g _prompt_async_fd=

# Runs in a forked subshell: inherits the current directory and all shell
# variables (incl. non-exported $AWS_PROFILE), and prints the segments once.
_prompt_async_worker() {
	print -r -- "$(git_branch)$(aws_profile)$(terraform_version)"
}

# Called by zle when the worker's output is ready.
_prompt_async_callback() {
	local fd=$1 data
	IFS= read -r -u $fd data
	zle -F $fd            # unregister the handler
	exec {fd}<&-          # close the pipe
	_prompt_async_fd=
	_PROMPT_INFO=$data
	zle reset-prompt      # redraw the prompt with the fresh info
}

# Kick off (or restart) the background computation.
_prompt_async_start() {
	# Cancel any computation still in flight (closing the fd makes a still-busy
	# worker exit via SIGPIPE on its next write).
	if [[ -n $_prompt_async_fd ]]; then
		zle -F $_prompt_async_fd 2> /dev/null
		exec {_prompt_async_fd}<&- 2> /dev/null
		_prompt_async_fd=
	fi
	exec {_prompt_async_fd}< <(_prompt_async_worker)
	zle -F $_prompt_async_fd _prompt_async_callback
}

# Clear stale info when changing directory so we never briefly show the
# previous repo's git status while the new one is being computed.
_prompt_chpwd() { _PROMPT_INFO="" }

# Print a blank line before each command's output.
_blank_line_preexec() { printf "\n" }

autoload -U add-zsh-hook
add-zsh-hook precmd  _prompt_async_start
add-zsh-hook chpwd   _prompt_chpwd
add-zsh-hook preexec _blank_line_preexec

PS1=$'\n\n%B%F{240}---%f%b\n%B%m%b : %(2~|⋯/%1~|%~)%(!.%F{240}.%f)%B${_PROMPT_INFO}%b%f%(?. %F{240}%B↪ %?. %F{red}%B↪ %?%b)\n%(?.%f%b.%F{red})%(!.%F{red}%B%n%f%b .%f)%B->%b%f '
