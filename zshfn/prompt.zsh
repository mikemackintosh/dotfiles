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

# putting it all together
function precmd {
  export PROMPT="$(return_status) $(username) $(directory) %b%F{154}%(!.#.$) %f"
  if [[ -n $(git_current_branch) ]]; then
    GIT="%B%F{078}$(git_current_branch)%f%b |$(git_prompt_status)"
  else
    unset GIT
  fi
  export RPROMPT="${GIT} %f$(current_time)"
}

setopt promptsubst
