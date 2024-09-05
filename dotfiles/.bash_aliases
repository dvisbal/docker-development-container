alias ls='ls -a --color'
alias gh='history -a && history -n && history|grep'
alias lt='ls --human-readable --size -1 -S --classify'
alias count='find . -type f | wc -l'
alias diskspace='du -Sh | sort -n -r |more'
alias pip='pip3'
alias python='python3'
alias dc='docker compose'
alias folders="find . -maxdepth 1 -type d -print | xargs du -sk | sort -rn"
alias gitls='git ls-tree --name-only HEAD foldername/ | while read filename; do echo "$(git log -1 --format="%ci " -- $filename) $filename"; done | sort -r'w
alias chrome='google-chrome --disable-gpu --disable-setuid-sandbox --no-sandbox'
export DOCKER_GID=$(getent group docker | cut -d: -f3)

## The various escape codes that we can use to color our prompt.
        RED="\[\033[0;31m\]"
     YELLOW="\[\033[1;33m\]"
      GREEN="\[\033[0;32m\]"
       BLUE="\[\033[1;34m\]"
  LIGHT_RED="\[\033[1;31m\]"
LIGHT_YELLOW="\[\033[0;33m\]"
LIGHT_GREEN="\[\033[1;32m\]"
      WHITE="\[\033[1;37m\]"
 LIGHT_GRAY="\[\033[0;37m\]"
 COLOR_NONE="\[\e[0m\]"

## Detect whether the current directory is a git repository.
function is_git_repository {
  git branch > /dev/null 2>&1
}

## Determine the branch/state information for this git repository.
function set_git_branch {
  ## Capture the output of the "git status" command.
  git_status="$(git status 2> /dev/null)"

  ## Set color based on clean/staged/dirty.
  if [[ ${git_status} =~ "working directory clean" ]]; then
    state="${GREEN}"
  elif [[ ${git_status} =~ "Changes to be committed" ]]; then
    state="${YELLOW}"
  else
    state="${LIGHT_RED}"
  fi

  ## Set arrow icon based on status against remote.
  remote_pattern="Your branch is (.*) of"
  if [[ ${git_status} =~ ${remote_pattern} ]]; then
    if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
      remote="↑"
    else
      remote="↓"
    fi
  else
    remote=""
  fi
  diverge_pattern="Your branch and (.*) have diverged"
  if [[ ${git_status} =~ ${diverge_pattern} ]]; then
    remote="↕"
  fi

  ## Get the name of the branch.
  branch_pattern="^On branch ([^${IFS}]*)"
  if [[ ${git_status} =~ ${branch_pattern} ]]; then
    branch=${BASH_REMATCH[1]}
  fi

  ## Set the final branch string.
  BRANCH="${state}(${branch})${remote}${COLOR_NONE} "
}

## Determine active Python virtualenv details.
function set_virtualenv () {
  if test -z "$VIRTUAL_ENV" ; then
      PYTHON_VIRTUALENV=""
  else
      DIR=$(dirname "${VIRTUAL_ENV}")

      PYTHON_VIRTUALENV="${BLUE}[V:$(basename \""$DIR"\")]${COLOR_NONE} "
  fi
}

# Function to determine active Docker machine details.
function set_docker_machine () {
  if test -z "$DOCKER_MACHINE_NAME" ; then
      DOCKER_MACHINE=""
  else
      DOCKER_MACHINE="${LIGHT_GRAY}[D:${DOCKER_MACHINE_NAME}]${COLOR_NONE} "
  fi
}

## Show that we are in a screen
function set_screen_session () {
  if test -z "$STY" ; then
      SCREEN_SESSION=""
  else
      SCREEN_SESSION="${LIGHT_GRAY}${STY}${COLOR_NONE} "
  fi
}

## Determine active Python conda details.
function set_conda () {
  if test -z "$CONDA_PROMPT_MODIFIER" ; then
      PYTHON_CONDA=""
  else
    CONDA_BASE_TEST="(base) "

    ## We don't want to show anything if it is base
    if [ "${CONDA_PROMPT_MODIFIER}" != "${CONDA_BASE_TEST}" ] ; then
      ## Remove the brackets and the space at the end
      CONDA_PROMPT_SIMPLE=$(echo -n "$CONDA_PROMPT_MODIFIER" | sed -e 's/(//; s/)//; s/ $//')
      PYTHON_CONDA="${BLUE}[C:$CONDA_PROMPT_SIMPLE]${COLOR_NONE} "
    else
      PYTHON_CONDA=""
    fi
  fi
}

# ${debian_chroot:+($debian_chroot)}
#if [ "$color_prompt" = yes ]; then
#    PS1="${LIGHT_YELLOW}\u@\h\[\033[00m\] \A ${BLUE}\w${COLOR_NONE} ${RED}${BRANCH}
#${COLOR_NONE}\$ "
#else
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#fi

function set_bash_prompt () {
  ## Set the PROMPT_SYMBOL variable. We do this first so we don't lose the return value of the last command.
  #set_prompt_symbol $?
  set_virtualenv
  set_docker_machine
  set_conda
  set_screen_session
  if is_git_repository ; then
    set_git_branch
  else
    BRANCH=''
  fi

  ## Set the bash prompt variable.
    PS1="
${LIGHT_YELLOW}\u@\h\[\033[00m\] \A ${BLUE}\w${COLOR_NONE} ${RED}${BRANCH}
${LIGHT_GREEN}\$ ${YELLOW}"

  # Set output text to something normal
  PS0="\e[0m"
}

PROMPT_COMMAND=set_bash_prompt

# List docker containers and images
alias dl='docker container ls; echo ""; docker image ls'
alias pp="cd ~/Documents/Projects"
alias ds="cd ~/Documents/Projects/dev/basic-dev-shell-dvisbal-external"

export PATH=~/.local/bin:$PATH
