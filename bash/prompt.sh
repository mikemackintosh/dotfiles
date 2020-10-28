#!/bin/bash

# Set the hide character
HIDE_CHARACTER="█"

PRIMARY_COLOR=${PRIMARY_COLOR-$SPLG_LBLUE}
SECONDARY_COLOR=${SECONDARY_COLOR-$SPLG_DGREY}

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
  # echo -e "$SPLG_ORANGE[$SPLG_PINK\A$SPLG_ORANGE]"
  # echo -e "\[$SPLG_GREEN\][\[$SPLG_PURPLE\]\#\[$SPLG_GREEN\]|\[$SPLG_PINK\]\A\[$SPLG_GREEN\]]"
  # echo -e "\[$PRIMARY_COLOR\]#\#\[$SPLG_PINK\]@\[$SPLG_ORANGE\]\A"
  echo -e " "
}

# Sets the prompt left
function prompt_left() {
  #CPATH="$SPLG_DGREY$(dirname $PWD)/$SPLG_ORANGE$(basename $PWD)"
  #echo -e "$SPLG_LBLUE\u$SPLG_LGREY@$SPLG_DBLUE\h $SPLG_PINK[$CPATH$SPLG_PINK]"
  COLOR=$SECONDARY_COLOR
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

  echo -e "\[$UPDATES\]\[$STATUS\]\[$COLOR\]${USERNAME:-\u}\[$SPLG_LGREY\] \[$PRIMARY_COLOR\]$CDIR$(git_branch_prompt)"
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
    STATUS="\[$SPLG_GREEN\]→ \[$CLEAR\]"
    if [ $EXIT != 0 ]; then
      STATUS="\[$SPLG_PINK\]➲ \[$CLEAR\]"
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
    # export PS1=$(printf "%*s\r%s\n\[$SPLG_GREY\]$HOST\[$CLEAR\] \[$SPLG_PURPLE\]$PROMPT_CHAR\[$CLEAR\] " "$(($(tput cols)+${compensate}))" "$(prompt_right)" "$(prompt_left)")
    export PS1=$(printf "\n%s\n%s \[$SPLG_LBLUE\]$HOST\[$CLEAR\] \[$SPLG_PURPLE\]$PROMPT_CHAR\[$CLEAR\] " "$(prompt_left)" "$(prompt_right)")
    export SUDO_PS1=$(printf "%*s\r%s\n\[$SPLG_DGREY\]$HOST\[$CLEAR\] \[$SPLG_PURPLE\]#\[$CLEAR\] " "$(($(tput cols)+${compensate}))" "$(prompt_right)" "$(root_prompt_left)")
}

function gradient() {
  START=$1
  END=$2
  TEXT=$3

  color_count=$(expr $END - $START + 1)
  length=${#TEXT}

  if [[ $length -lt $color_count ]]; then
    loops=$(expr $color_count / $length)
  else
    loops=$(expr $(expr $length + 1) / $color_count)
  fi

  color_inc=$(expr $( expr $color_count + 1) / $loops)
  if [[ $color_inc -le 0 ]]; then
    color_inc=1
  fi

  last=0
  block=0
  color=$START
  while true; do
    page=$(expr $block + 1)
    offset=$(expr $block \* $loops)
    echo -en "$(tput setaf $color)"
    echo -en "${TEXT:$last:$offset}"
    last=$(expr $last + $offset)
    color=$(expr $color + $color_inc)
    if [[ $last -ge $length ]]; then
      echo -e "$(tput setaf 0)"
      break
    fi
  done
}

SYSTEM=$(uname)

export PROMPT_COMMAND="prompt; history -a;"

export -f prompt
export -f prompt_left
export -f prompt_right
export -f root_prompt_left
