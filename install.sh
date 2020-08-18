#!/bin/bash

# Inlcude the helper script
source $HOME/.dotfiles/helpers.sh

# Install dotfiles
if [ ! -d $HOME/.dotfiles ]; then
  log "Downloading"
  git clone https://github.com/mikemackintosh/dotfiles $HOME/.dotfiles
else
  cd $HOME/.dotfiles
  git pull --rebase
fi

# If we pass a module, do the love for it
if [[ ! -z $1 ]]; then
  log "Selective-Install"
  place $1 $2
  exit
fi

# Get readlink
readlink $HOME/.bash_profile | grep .dotfiles/bash_profile > /dev/null
BASH=$?

# Install if the links are not in place already
if [[ $BASH -eq 1 ]]; then

  # Create private dir
  if [ ! -d "${HOME}/.private/" ]; then
    mkdir $HOME/.private
    touch $HOME/.private/nil
  fi

  # Create includes dir
  if [ ! -d "${HOME}/.include.sh/" ]; then
    mkdir $HOME/.include.sh
    touch $HOME/.include.sh/nil
  fi

  # Place bash_profile
  place bash_profile

  # Place curlrc
  place curlrc

  # Place vim
  place vim
  place vim/vimrc vimrc

  # Place git
  place git/gitconfig gitconfig
  place git/gitconfig-osx gitconfig-osx
  place git/gitignore gitignore

  # Place tmux.conf
  place tmux.conf

else
  log "Already installed. Skipping."
fi

# Source the bash_profile we just installed
source ~/.bash_profile

#OS=`uname`
#if [[ $OS == 'Darwin' ]]; then
#  install_osx
#fi
