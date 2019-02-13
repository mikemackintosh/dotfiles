#!/bin/bash

# Set the hide character
HIDE_CHARACTER="█"

# Repeat function
function repeat() {
  printf "${1}%.0s" $(seq 1 $2);
}

# mark allows you to set a visual line break
function mark() {
  message=""
  width=$(($(tput cols)-1))
  if [[ ! -z $@ ]]; then
    message=" MARKED: $@"
    width=$(($width-${#message}))
  fi

  echo -ne "\033[1;0;44m ${message}"
  repeat " " $width
  echo -ne "\033[0m"
}

# Short path sumarizes your $PWD in $PROMPT
function ellipses() {
  if [[ ! -z $PROMPT_ELIPSES ]]; then
    unset PROMPT_ELIPSES
    return
  fi
  COUNT=${1:-3}
  export PROMPT_ELIPSES=$COUNT
}

# Sets the prompt right
function prompt_right() {
  #echo -e "$SPLG_ORANGE[$SPLG_PINK\A$SPLG_ORANGE]"
  echo -e "\[$SPLG_GREEN\][\[$SPLG_PURPLE\]\#\[$SPLG_GREEN\]|\[$SPLG_PINK\]\A\[$SPLG_GREEN\]]"
}

# Sets the prompt left
function prompt_left() {
  PRIMARY_COLOR=${PRIMARY_COLOR-$SPLG_GREEN}
  #CPATH="$SPLG_DGREY$(dirname $PWD)/$SPLG_ORANGE$(basename $PWD)"
  #echo -e "$SPLG_LBLUE\u$SPLG_LGREY@$SPLG_DBLUE\h $SPLG_PINK[$CPATH$SPLG_PINK]"
  COLOR=$SPLG_LBLUE
  if [[ ! -z $SSH_CLIENT ]]; then
    PRIMARY_COLOR=${SPLG_LBLUE}
    COLOR=$SPLG_GREEN
  elif [[ $USER == 'root' ]]; then
    COLOR=$SPLG_PINK
  fi

  # CurrentDIR
  if [[ $SYSTEM == "Darwin" ]]; then
    CDIR="${PWD/#$HOME/~}"
  else
    CDIR="${PWD/#$HOME/\~}"
  fi

  if [ ! -z $HIDE_PATH ]; then
    CDIR=${CDIR//$HIDE_PATH/$(repeat $HIDE_CHARACTER ${#HIDE_PATH} )}
  elif [ ! -z $SHORTPATH ]; then
    # SHORT DIR
    CDIR=$(pwd | sed "s:${HOME}:~:" | sed "s:/\(.\)[^/]*:/\1:g" | sed "s:/[^/]*$:/$(basename $PWD):")
  elif [ ! -z $PROMPT_ELIPSES ]; then
    EDIR=$(pwd | awk -F\/ '{print $(NF-2),$(NF-1),$(NF)}'| sed 's/ /\//g')
    if [[ ${EDIR:0:1} != "/" ]]; then
      EDIR=".../${EDIR}"
    fi
    CDIR=$(echo ${EDIR}/)
  fi

  echo -e "\[$UPDATES\]\[$STATUS\]\[$COLOR\]\u\[$SPLG_LGREY\] \[$PRIMARY_COLOR\]$CDIR $(git_branch)"
}


# Sets the prompt left
function root_prompt_left() {
  #CPATH="$SPLG_DGREY$(dirname $PWD)/$SPLG_ORANGE$(basename $PWD)"
  #echo -e "$SPLG_LBLUE\u$SPLG_LGREY@$SPLG_DBLUE\h $SPLG_PINK[$CPATH$SPLG_PINK]"
  # CurrentDIR
  if [[ $SYSTEM == "Darwin" ]]; then
    CDIR="${PWD/#$HOME/~}"
  else
    CDIR="${PWD/#$HOME/\~}"
  fi

  if [ ! -z $HIDE_PATH ]; then
    CDIR=${CDIR//$HIDE_PATH/$(repeat $HIDE_CHARACTER ${#HIDE_PATH} )}
  elif [ ! -z $SHORTPATH ]; then
    # SHORT DIR
    CDIR=$(pwd | sed "s:${HOME}:~:" | sed "s:/\(.\)[^/]*:/\1:g" | sed "s:/[^/]*$:/$(basename $PWD):")
  elif [ ! -z $PROMPT_ELIPSES ]; then
    EDIR=$(pwd | awk -F\/ '{print $(NF-2),$(NF-1),$(NF)}'| sed 's/ /\//g')
    if [[ ${EDIR:0:1} != "/" ]]; then
      EDIR=".../${EDIR}"
    fi
    CDIR=$(echo ${EDIR}/)
  fi

  PRIMARY_COLOR=${PRIMARY_COLOR-$SPLG_LBLUE}

  echo -e "\[$UPDATES\]\[$STATUS\]\[$SPLG_PINK\]\u\[$SPLG_LGREY\] \[$PRIMARY_COLOR\]\w"
}

# Generate the prompt
function prompt() {
    local EXIT="$?"
    PROMPT_CHAR='$'

    if [[ ! -z $SCRIPT_UPDATES ]]; then
      UPDATES=$SCRIPT_UPDATES
    fi

    compensate=72
    STATUS="\[$SPLG_GREEN\]▸ \[$CLEAR\]"
    if [ $EXIT != 0 ]; then
      STATUS="\[$SPLG_PINK\]▸ \[$CLEAR\]"
    fi
    export PATH

    # E
    HOST=$(hostname)
    if [[ ! -z $SSH_CLIENT ]]; then
      HOST="${SPLG_PURPLE}${HOST}"
      PROMPT_CHAR="${SPLG_PINK}>"
    fi

    # Set the prompt Character
    if [ $USER == 'root' ]; then
      PROMPT_CHAR="${SPLG_PINK}#"
    fi

    # Export PS1 and prompts
    export PS1=$(printf "%*s\r%s\n\[$SPLG_GREY\]$HOST\[$CLEAR\] \[$SPLG_PURPLE\]$PROMPT_CHAR\[$CLEAR\] " "$(($(tput cols)+${compensate}))" "$(prompt_right)" "$(prompt_left)")
    export SUDO_PS1=$(printf "%*s\r%s\n\[$SPLG_DGREY\]$HOST\[$CLEAR\] \[$SPLG_PURPLE\]#\[$CLEAR\] " "$(($(tput cols)+${compensate}))" "$(prompt_right)" "$(root_prompt_left)")
}

SYSTEM=$(uname)

# Avoid duplicates
export HISTCONTROL=ignoredups:ignorespace:erasedups
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=$HISTSIZE               # big big history
export HISTTIMEFORMAT="%d/%m/%y %T | "
export HISTIGNORE="ls:exit:history:[bf]g:jobs"

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

export PROMPT_COMMAND="prompt; history -a;"

export -f prompt
export -f prompt_left
export -f prompt_right
export -f root_prompt_left
