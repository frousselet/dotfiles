##############################################################################
# Prompt
#
# Layout
#   left  : (venv) (ssh) host : path  [git:…] [k8s:…]  ✦jobs  ↪ exit
#   right : <duration> [aws:…] [terraform:…]  HH:MM:SS
#
# git/k8s/aws/terraform are computed in a background worker (see "Async"
# below) so a slow "git status" / "kubectl" never blocks the prompt.
#
# Icons: set PROMPT_ICONS=1 (e.g. in ~/.zsh_extra) on machines that have a
# Nerd Font installed. Default is plain ASCII labels, so the prompt stays
# readable everywhere.
##############################################################################

# ── Labels (icon vs ASCII) ──────────────────────────────────────────────────
_prompt_setup_labels() {
	if [[ ${PROMPT_ICONS:-0} == 1 ]]; then
		_L_GIT=$' '       #  branch
		_L_K8S=$'⎈ '       # ⎈
		_L_AWS=$' '       #  aws
		_L_TF=$' '        #  terraform
		_L_VENV_PRE=$' '  #  python
		_L_VENV_POST=''
		_L_SSH=$''        #  terminal
		_L_OK=$'✓'         # ✓
		_L_ERR=$'✗'        # ✗
		_L_JOBS=$'✦'       # ✦
		_L_DUR=$' '       #  clock
	else
		_L_GIT="git:"
		_L_K8S="k8s:"
		_L_AWS="aws:"
		_L_TF="terraform:"
		_L_VENV_PRE="("
		_L_VENV_POST=")"
		_L_SSH="(ssh)"
		_L_OK="↪"
		_L_ERR="↪"
		_L_JOBS="✦"
		_L_DUR=""
	fi
}
_prompt_setup_labels

# ── Dynamic segments ─────────────────────────────────────────────────────────

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

	# In-progress operation (rebase/merge/…) so we don't forget we're mid-flow.
	local gitdir state=""
	gitdir="$(git rev-parse --git-dir 2> /dev/null)"
	if [[ -d "$gitdir/rebase-merge" || -d "$gitdir/rebase-apply" ]]; then
		state="|REBASE"
	elif [[ -f "$gitdir/MERGE_HEAD" ]]; then
		state="|MERGE"
	elif [[ -f "$gitdir/CHERRY_PICK_HEAD" ]]; then
		state="|CHERRY-PICK"
	elif [[ -f "$gitdir/BISECT_LOG" ]]; then
		state="|BISECT"
	fi

	# Stash entries.
	local stash
	stash="$(git rev-list --walk-reflogs --count refs/stash 2> /dev/null)"
	[[ -n "$stash" && "$stash" != 0 ]] && flags+="/≡$stash"

	echo " [${_L_GIT}${branch}${state}${flags}]"
}

kube_context() {
	command -v kubectl > /dev/null || return
	# Don't spawn kubectl on machines without a kubeconfig.
	local cfg="${KUBECONFIG:-$HOME/.kube/config}"
	[[ -f "$cfg" ]] || return

	local ctx
	ctx="$(kubectl config current-context 2> /dev/null)" || return
	[[ -n "$ctx" ]] || return

	local ns
	ns="$(kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}' 2> /dev/null)"
	echo " [${_L_K8S}${ctx}${ns:+/$ns}]"
}

aws_profile() {
	command -v aws > /dev/null || return
	[[ -n "$AWS_PROFILE" ]] || return
	echo " [${_L_AWS}$AWS_PROFILE]"
}

terraform_version() {
	command -v terraform > /dev/null || return
	local tf=(*.tf(N))
	(( ${#tf} )) || return
	echo " [${_L_TF}$(terraform --version | head -n 1 | cut -d " " -f 2 | cut -c 2-)]"
}

# ── Async machinery ─────────────────────────────────────────────────────────
#
# A forked worker (inherits cwd + all shell vars) computes the left segments
# (git, k8s) and the right segments (aws, terraform) and prints them on two
# lines. Its output goes to a pipe watched by "zle -F"; when it's done we
# stash the result and redraw with "zle reset-prompt". The prompt itself is
# rendered immediately and never blocks.

typeset -g _PROMPT_LINFO=""    # git + k8s + aws + terraform (async)
typeset -g _PROMPT_DURATION="" # last cmd duration (sync)
typeset -g _PROMPT_VENV=""     # python venv (sync)
typeset -g _PROMPT_SSH=""      # ssh marker  (sync)
typeset -g _prompt_async_fd=

_prompt_async_worker() {
	print -r -- "$(git_branch)$(kube_context)$(aws_profile)$(terraform_version)"
}

_prompt_async_callback() {
	local fd=$1 data
	IFS= read -r -u $fd data
	zle -F $fd            # unregister the handler
	exec {fd}<&-          # close the pipe
	_prompt_async_fd=
	_PROMPT_LINFO=$data
	zle reset-prompt      # redraw with the fresh info
}

_prompt_async_start() {
	# Cancel any computation still in flight (closing the fd makes a busy
	# worker exit via SIGPIPE on its next write).
	if [[ -n $_prompt_async_fd ]]; then
		zle -F $_prompt_async_fd 2> /dev/null
		exec {_prompt_async_fd}<&- 2> /dev/null
		_prompt_async_fd=
	fi
	exec {_prompt_async_fd}< <(_prompt_async_worker)
	zle -F $_prompt_async_fd _prompt_async_callback
}

# ── Synchronous bits (cheap: env vars + a timer) ─────────────────────────────

_fmt_duration() {
	local s=$1 out=""
	(( s >= 86400 )) && out+="$(( s / 86400 ))d"
	(( s >= 3600 ))  && out+="$(( (s % 86400) / 3600 ))h"
	(( s >= 60 ))    && out+="$(( (s % 3600) / 60 ))m"
	out+="$(( s % 60 ))s"
	echo "$out"
}

_prompt_preexec() {
	_prompt_cmd_start=$SECONDS
	printf "\n"           # blank line before the command's output
}

_prompt_precmd() {
	# Duration of the last command, only shown past a threshold.
	if [[ -n "$_prompt_cmd_start" ]]; then
		local elapsed=$(( SECONDS - _prompt_cmd_start ))
		unset _prompt_cmd_start
		if (( elapsed >= ${PROMPT_CMD_MAX_DUR:-5} )); then
			_PROMPT_DURATION=" ${_L_DUR}$(_fmt_duration $elapsed)"
		else
			_PROMPT_DURATION=""
		fi
	else
		_PROMPT_DURATION=""
	fi

	# Python virtualenv.
	if [[ -n "$VIRTUAL_ENV" ]]; then
		_PROMPT_VENV="${_L_VENV_PRE}${VIRTUAL_ENV:t}${_L_VENV_POST} "
	else
		_PROMPT_VENV=""
	fi

	# SSH session marker.
	if [[ -n "$SSH_CONNECTION" ]]; then
		_PROMPT_SSH="$_L_SSH "
	else
		_PROMPT_SSH=""
	fi

	# Clear stale async info on directory change handled by _prompt_chpwd.
}

_prompt_chpwd() {
	_PROMPT_LINFO=""
}

autoload -U add-zsh-hook
add-zsh-hook preexec _prompt_preexec
add-zsh-hook precmd  _prompt_precmd
add-zsh-hook precmd  _prompt_async_start
add-zsh-hook chpwd   _prompt_chpwd

# ── Prompt strings ───────────────────────────────────────────────────────────
# Single-quoted parts keep ${_PROMPT_*} literal (expanded each render via
# PROMPT_SUBST); double-quoted parts bake the label/icon chosen at startup.

PS1=$'\n\n'"%B%F{240}---%f%b"$'\n'
PS1+='${_PROMPT_VENV}${_PROMPT_SSH}%B%m%b : %(2~|⋯/%1~|%~)%(!.%F{240}.%f)%B${_PROMPT_LINFO}%b%f'
PS1+="%(1j. %F{yellow}${_L_JOBS}%j%f.)"
PS1+="%(?. %F{240}%B${_L_OK} %?. %F{red}%B${_L_ERR} %?%b)"
PS1+='%F{240}${_PROMPT_DURATION}%f'
PS1+=$'\n'
PS1+='%(?.%f%b.%F{red})%(!.%F{red}%B%n%f%b .%f)%B->%b%f '

# No right prompt / clock.
RPROMPT=''
