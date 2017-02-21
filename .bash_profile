# Initialize
source ~/.bash-preexec.sh

# Aliases
alias ll='ls -al'
alias vi='vim'

# Get Git Status


#Retore default color
preexec() {
    printf "\e[0m\n";
}

# Get Git state

# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		printf "(${BRANCH})"
	else
		echo ""
	fi
}

# get current status of git repo
function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modifié:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Fichiers non suivis" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "nouveau fichier:" &> /dev/null; echo "$?"`
    val=`echo -n "${status}" 2> /dev/null | grep "Modifications qui seront validées :" &> /dev/null; echo "$?"`
    noval=`echo -n "${status}" 2> /dev/null | grep "Modifications qui ne seront pas validées :" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renommé:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "supprimé:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${untracked}" == "0" ] || [ "${noval}" == "0" ]; then
		bits="\e[31m"
    elif [ "${newfile}" == "0" ] || [ "${renamed}" == "0" ] || [ "${deleted}" == "0" ] || [ "${val}" == "0" ]; then
        bits="\e[101m"
    else
        bits="\e[32m"
    fi
	if [ ! "${bits}" == "" ]; then
		printf "${bits}"
	else
		echo ""
	fi
}

export PS1="\[\e[0m\]\n\n\u : \W \`parse_git_branch\`\[\e[m\]\n➜\[\e[1m\] "
