# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/home/chris/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/home/chris/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "/home/chris/anaconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/home/chris/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<

# source /opt/ros/iron/setup.bash
# source ~/race_common/install/setup.bash

# alias trt='if [ $# -eq 0 ]; then echo "Please provide an argument Container Name for Docker."; else docker exec -it $1 /bin/bash; fi'
# alias trt='if [ $# -eq 0 ]; then echo "Please provide an argument Container Name for Docker."; else ls $1; fi'

# Building a docker image with some SSH thing you want to add
build_dockerfile() {

    local IMG_NAME_W_TARGET # Format: <name>:<tag>

    # Start the SSH agent
    eval $(ssh-agent)
    ssh-add ~/.ssh/chris/id

    # Run the actual docker build
    DOCKER_BUILDKIT=1 docker build \
        --network=host \
        --ssh default=${SSH_AUTH_SOCK} \
        -t ${IMG_NAME_W_TARGET} .
}       

create_container_rocker() {
    local img_name="$1"
    local cont_name="$2"

    # Check if img_name is provided
    if [ -z "${img_name}" ]; then
        echo "Error: Image name (IMG_NAME) not provided."
        return 1  # Exit the function with an error status
    fi

    # Check if cont_name is provided
    if [ -z "${cont_name}" ]; then
        echo "Error: Container name (CONT_NAME) not provided."
        return 1  # Exit the function with an error status
    fi

    # If both arguments are provided, proceed with the main logic
    rocker --network host --nvidia runtime -e NVIDIA_DRIVER_CAPABILITIES=all --git --ssh --x11 --privileged --nocleanup --name "${cont_name}" --user --volume "$(pwd):$(pwd)" -- "${img_name}"
}

# Example calling o f the above alias:
# trtdocker "your_image_name_here" "your_container_name_here"
# create_container_rocker trt11-8 trt

joindocker() {
    if [ $# -eq 0 ]; then
        echo "Please provide an argument Container Name for Docker."
    else
        docker exec -it $1 /bin/bash
    fi
}

