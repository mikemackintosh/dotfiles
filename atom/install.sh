#!/bin/bash
source ../helpers.sh

log "Preparing to install Atom packages via apm"
ruby -e '%w{
city-lights-syntax
figletify
go-plus
language-chef
language-hcl
language-puppet
language-terraform
language-viml
linter
linter-foodcritic
linter-puppet
minimap
navigator-godef
pretty-json
}.each do |c|
  cmd = "apm install #{c}"
  %x( #{cmd} )
end'

# If the atom config exists already, back it up
if [[ -e ${HOME}/.atom/config.cson ]]; then
  log "Backing up Atom configuration"
  mv ${HOME}/.atom/config.{cson,cson.bak}
fi

# Link the local config into atom
log "Enabling custom Atom configuration"
ln -s ${HOME}/.dotfiles/atom/config.cson ${HOME}/.atom/config.cson
