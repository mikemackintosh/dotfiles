#!/bin/bash

# Turn off clobber, use >| instead
set -o noclobber
# set -o hashall
set -o ignoreeof
# set -o allexport

# Set default editor
export EDITOR=vim

# Set some wonderful path stuff
unset PATH
export GOPATH="${HOME}/go"
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="/usr/local/sbin:/usr/local/bin:$PATH"
export PATH="/usr/local/google-cloud-sdk/bin:$PATH"

# Check for personal bin
if [[ -d "$HOME/bin" ]]; then
  export PATH="$HOME/bin:$PATH"
fi

# Load bash and private
for f in $HOME/.dotfiles/bash/*.sh; do
  source $f;
done

# Load all the source files
for f in $HOME/.private/*.sh; do
  if [[ -f $f ]]; then
    source $f;
  fi
done

# If iTerm2 Shell Integrations exists, load it
if [[ -e ${HOME}/.iterm2_shell_integration.bash ]]; then
  source ${HOME}/.iterm2_shell_integration.bash
fi

