alias ll="ls -alG"

command -v exa &>/dev/null
if [[ $? -eq 0 ]]; then
  alias ls=exa
fi

alias g="gcloud"

alias gg="git_effect"