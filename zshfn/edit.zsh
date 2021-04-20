# Edit helpers and functions
reload() {
  source $HOME/.zshrc;
  clear;
}

# Update the SSHConfig
sshconfig() {
  $EDITOR $HOME/.ssh/config
}

# Update bash profile
profile() {
  $EDITOR ~/.zshrc
}

# Update dotfiles
dotfiles() {
  $EDITOR $HOME/.dotfiles
}

# Update private configuration
private() {
  $EDITOR $HOME/.private
}
