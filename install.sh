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
success() {
  echo -e "\033[38;5;2m -> \033[0m${@}"
}

# Error will retun a red indication at the beggining of the output
error() {
  echo -e "\033[38;5;1m -> \033[0m${@}"
}

# Used to backup files
bkp() {
  info "Backing up ${1}"
  mv ${1} ${1}.bak
}

# Place will backup existing files and link new ones
place() {
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
  place zsh
  place zsh-plugins

  # Place curlrc
  place curlrc

  # Place git
  place git/gitconfig gitconfig
  place git/gitconfig-osx gitconfig-osx
  place git/gitignore gitignore

  # Place tmux.conf
  place tmux.conf
  place hushlogin
  place vimrc

else
  log "Already installed. Skipping."
fi

if [[ $OSTYPE == darwin* ]]; then

  # Install homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  #apm install atom-ide-ui
  #apm install city-lights-icons
  #apm install go-debug
  #apm install go-plus
  #apm install go-signature-statusbar
  #apm install hclfmt
  #apm install hey-pane
  #apm install ide-go
  #apm install language-docker
  #apm install language-hcl
  #apm install suburb-lights-syntax

  brew install zplug
  source ~/.zsh/zplug/init.zsh
  brew install git-delta
  brew install the_silver_searcher
  brew install jq
  brew install go
  brew install exa
fi

go install github.com/mikemackintosh/chrono@latest

# Source the bash_profile we just installed
source ~/.zshrc
