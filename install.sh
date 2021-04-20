#!/bin/zsh

# Inlcude the helper script - Helper function for outputting information
# A log will offset the start to match success and errors
function log() {
  echo -e "${@}"
}

# A generic log message
function info() {
  echo -e "\033[0m -> ${@}"
}

# A success will provide a green indicator at the beggining of the output
function success() {
  echo -e "\033[38;5;2m -> \033[0m${@}"
}

# Error will retun a red indication at the beggining of the output
function error() {
  echo -e "\033[38;5;1m -> \033[0m${@}"
}

# Used to backup files
function bkp() {
  info "Backing up ${1}"
  mv ${1} ${1}.bak
}

# Place will backup existing files and link new ones
function place() {
  filename=$(basename ${1})
  source_file=$HOME/.dotfiles/$1
  log "Installing ${filename}"

  # If we passed a destination file, use it
  # this will by the link target
  destination=$HOME/.${1}
  if [[ ! -z $2 ]]; then
    destination=$HOME/.${2}
  fi

  # log a message
  success "Copying '${source_file}' to '${destination}'"

  # Check for an existing file and backup if it exists
  if [[ -e ${destination} ]]; then
    bkp ${destination}
  fi

  # link the file correctly
  ln -s $source_file $destination
  if [[ $? -eq 0 ]]; then
    success "Placed ${filename}"
  else
    fail "Error placing ${filename}"
  fi

  echo ""
}

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
readlink $HOME/.zshrc | grep .dotfiles/zshrc > /dev/null
ZSH=$?

# Install if the links are not in place already
if [[ $ZSH -eq 1 ]]; then

  # Create private dir
  if [ ! -d "${HOME}/.private/" ]; then
    mkdir $HOME/.private
    touch $HOME/.private/nil
  fi

  # Place bin
  place bin

  # Place zsh
  place zshrc

  # Place curlrc
  place curlrc

  # Place git
  place git/gitconfig gitconfig
  place git/gitconfig-osx gitconfig-osx
  place git/gitignore gitignore

  # Place tmux.conf
  place tmux.conf
  place hushlogin

else
  log "Already installed. Skipping."
fi

# Source the bash_profile we just installed
source ~/.zshrc
#OS=`uname`
#if [[ $OS == 'Darwin' ]]; then
#  install_osx
# fi
