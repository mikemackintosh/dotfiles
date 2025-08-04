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

if [ ! -d $HOME/bin ]; then
  mkdir $HOME/bin
fi

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
  # place zsh
  # place zsh-plugins

  # Place curlrc
  # place curlrc
  place psqlrc

  # Place git
  place git/config gitconfig
  place git/gitignore gitignore
  # place git/gitconfig-osx gitconfig-osx

  # Place tmux.conf
  # place tmux.conf
  place hushlogin
  # place vimrc

else
  log "Already installed. Skipping."
fi

if [[ $OSTYPE == darwin* ]]; then

  # Install homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  brew install zsh
  brew install ruby
  brew install node
  brew install git-delta
  brew install the_silver_searcher
  brew install jq
  brew install go
  brew install eza
  brew install terraform
  brew install wget
  brew install gitleaks
  brew install zsh-syntax-highlighting

  brew install jandedobbeleer/oh-my-posh/oh-my-posh

  brew install --cask google-chrome
  brew install --cask visual-studio-code
  brew install --cask docker
  brew install --cask iterm2
  brew install --cask alfred

  brew install --cask  qlcolorcode
  brew install --cask  qlstephen
  brew install --cask  qlmarkdown
  brew install --cask  quicklook-json
  brew install --cask  qlprettypatch
  brew install --cask  quicklook-csv
  brew install --cask  betterzip
  brew install --cask  webpquicklook
  brew install --cask  suspicious-package

  # Fonts
  brew install --cask font-fira-mono-for-powerline
  brew install --cask font-fira-code-nerd-font
  brew install --cask font-menlo-for-powerline
  brew install --cask font-source-code-pro-for-powerline
  brew install --cask font-ubuntu-mono-derivative-powerline
  brew install --cask font-ubuntu-mono-nerd-font
  brew install --cask font-hack-nerd-font
  brew install --cask font-code-new-roman-nerd-font

  # wget https://github.com/mikemackintosh/chrono/releases/download/v1.0.6/chrono-darwin-amd64
  # chmod +x ./chrono-darwin-amd64
  # mv ./chrono-darwin-amd64 $HOME/bin/chrono

  # wget https://github.com/mikemackintosh/ninetails/releases/download/v1.0.4/ninetails-darwin-amd64
  # chmod +x ./ninetails-darwin-amd64
  # mv ./ninetails-darwin-arm64 $HOME/bin/ninetails
fi

# Source the bash_profile we just installed
source ~/.zshrc
