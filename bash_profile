#!/bin/bash

# Turn off clobber, use >| instead. This prevents accidental overwrites.
set -o noclobber
set -o ignoreeof

# Set default editor
export EDITOR=vim

# Set some wonderful path stuff
unset PATH
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="/usr/local/sbin:/usr/local/bin:$PATH"
export PATH="/usr/local/google-cloud-sdk/bin:$PATH"

# Go path
export GOPATH="${HOME}/go"

# Set history to avoid duplicates
export HISTCONTROL=ignoredups:ignorespace:erasedups
export HISTFILESIZE=1000000
export HISTTIMEFORMAT="%d/%m/%y %T | "
export HISTIGNORE="ls:exit:history:[bf]g:jobs"
# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

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

# Look for other included files
for f in $HOME/.include.sh/*.sh; do
  if [[ -f $f ]]; then
    source $f;
  fi
done

# If iTerm2 Shell Integrations exists, load it
if [[ -e ${HOME}/.iterm2_shell_integration.bash ]]; then
  source ${HOME}/.iterm2_shell_integration.bash
fi

# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
