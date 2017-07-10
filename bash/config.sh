# Reload
function reload {
#    source $HOME/.zshrc
    source $HOME/.bash_profile
}

# Update the SSHConfig
function sshconfig {
  atom ~/.ssh/config
}

# Update bash profile
function profile {
  atom ~/.bash_profile
}

# Update dotfiles
function dotfiles {
  (cd ~/.dotfiles && atom .)
}

# Update private configuration
function private {
  (cd ~/.private && atom .)
}

# Update update-dotfiles
function update-dotfiles {
  (cd ${HOME}/.dotfiles && git stash && git pull && reload)
}
