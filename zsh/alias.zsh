# ls
command -v eza &>/dev/null
if [[ $? -eq 0 ]]; then
  alias ls=eza
fi

# Always pass the environment
alias sudo='sudo -E'

alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias gp='git pull'