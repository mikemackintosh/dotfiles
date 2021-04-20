#!/usr/bin/env bash

# Helper function for outputting information

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
