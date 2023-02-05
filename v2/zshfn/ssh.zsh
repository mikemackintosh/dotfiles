SSH_ENV="${HOME}/.ssh/environment"

_start_agent() {
  echo -n "Checking for SSH agent... "
    if [[ -f "${SSH_ENV}" ]]; then
       . ${SSH_ENV} > /dev/null
       #ps ${SSH_AGENT_PID} doesn't work under cywgin
       (ps -p ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null && check_agent_keys) || {
         new_ssh_agent
       }
       echo "connected!"
   else
      new_ssh_agent
   fi
}

check_agent_keys() {
   if [[ "The agent has no identities." == $(ssh-add -L) ]]; then
     find $HOME/.ssh -type f -exec grep -Hm1 'PRIVATE' {} \; | cut -d':' -f1 | xargs ssh-add
   fi
}

new_ssh_agent() {
  if [[ ! -e $(pgrep ssh-agent) ]]; then
    echo "Found SSH agent..."
    return
  fi
  echo -n "Starting new SSH agent... "
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' >! ${SSH_ENV}
  echo succeeded
  chmod 600 ${SSH_ENV}
  . ${SSH_ENV} > /dev/null
  # Find and add private keys
  check_agent_keys
}

_start_agent
