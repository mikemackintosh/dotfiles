NEWLINE=$'\n'
precmd_functions=()

# Set basic helper for resetting color
export rc="%f"

# purple username
username() {
   echo "%{%F{165}%}%n %fon %F{111}%B$HOST%b$rc"
}

# current directory, two levels deep
directory() {
  COUNT=$(($(tput cols) /5))
  echo "%F{51}%${COUNT}<..<%~$rc"
}

# current time with milliseconds
current_time() {
   echo "%*"
}

# returns 🖕 if there are errors, nothing otherwise
return_status() {
   echo "%(?..🖕)"
}

_git_branch_precmd() {
  export GIT_BRANCH="$(git_current_branch)"
}
precmd_functions+=(_git_branch_precmd)

_preexec_chrono() {
  export START_TIME=$(chrono -m)
}
preexec_functions+=(_preexec_chrono)

_precmd_chrono() {
  CHRONO_DURATION=$(chrono)
  unset START_TIME
}
precmd_functions+=(_precmd_chrono)

precmd() {
  RPROMPT="%B%F{215}${CHRONO_DURATION}%f%b"
  if [[ -n "${GIT_BRANCH/[ ]*\n/}" ]]; then
    RPROMPT="${RPROMPT} | %F{blue}${GIT_BRANCH}%f"
  fi

  if [[ -n $SHOW_TIME ]]; then 
    RPROMPT="${RPROMPT} - %F{13}$(current_time)"
  fi

  PROMPT="$PROMPT"
  
}
precmd_functions+=(precmd)

if [[ ! -z $SSH_CLIENT ]]; then
   export SSH_PROMPT="%B%F{48}%n%f%b %F{51}on%f %F{blue}${${(%):-%m}}%f${NEWLINE}%F{97}⮑%f  "
else 
  export SSH_PROMPT=""
fi

PROMPT="${SSH_PROMPT}%F{147}%2~%f %B%F{215}❯%f%b "