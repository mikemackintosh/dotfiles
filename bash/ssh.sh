SSH_ENV=$HOME/.ssh/environment

function start_agent {
    if [ -f "${SSH_ENV}" ]; then
       . ${SSH_ENV} > /dev/null
       #ps ${SSH_AGENT_PID} doesn't work under cywgin
       (ps -efp ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null && echo "Using existing ssh-agent") || {
         new_ssh_agent
       }
   else
      new_ssh_agent
   fi
}

function new_ssh_agent {
  echo "Initialising new SSH agent..."
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' >| ${SSH_ENV}
  echo succeeded
  chmod 600 ${SSH_ENV}
  . ${SSH_ENV} > /dev/null
  /usr/bin/ssh-add;
}

start_agent
