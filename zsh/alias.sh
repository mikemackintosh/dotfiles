alias ll="ls -alG"

command -v eza &>/dev/null
if [[ $? -eq 0 ]]; then
  alias ls=eza
fi

alias g="gcloud"

alias gg="git_effect"

alias tf="terraform"
