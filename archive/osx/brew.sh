#!/bin/bash

# Include helpers
source ~/.dotfiles/helpers.sh

# Check for and install brew
HAS_BREW=$(which brew)
if [ $? -eq 1 ]; then
  log "Downloading Brew"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Setup basic brew formula
log "Preparing to download packages"
ruby -e '%w{
ant
autoconf
awscli
bash-completion
coreutils
curl
docker
docker-compose
docker-machine
enchant
figlet
gnupg
go
highlight
jp2a
jpeg
jq
keybase
nikto
nmap
node
oniguruma
openssl
pass
pwgen
readline
reattach-to-user-namespace
socat
sqlite
sqlmap
ssh-copy-id
terminal-notifier
terraform
testssl
the_silver_searcher
tmate
tmux
tree
vim
wget
xz
}.each do |p|
  cmd = "/usr/local/bin/brew install #{p}"
  %x( #{cmd} )
end'
log "Package installation complete"

# Tap and install casks
log "Preparing to install casks"
ruby -e '%w{
atom
betterzipql
chefdk
firefox
flux
google-hangouts
java
qlcolorcode
qlmarkdown
qlprettypatch
qlstephen
quicklook-csv
quicklook-json
silverlight
sketch
spectacle
vagrant
virtualbox
}.each do |c|
  cmd = "brew cask install #{c}"
  %x( #{cmd} )
end'
