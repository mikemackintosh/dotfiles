#!/bin/bash
#
# ip.sh
# -> returns the IP of the specified interface
function mip() {

  if [[ $1 == 'p' ]]; then
    dig +short myip.opendns.com @resolver1.opendns.com
    #curl icanhazip.com
    return
  fi

  if [[ $1 == 't' ]]; then
    curl icanhaztraceroute.com
    return
  fi

  if [[ ! -z $1 ]]; then
    ipconfig getifaddr $1
    return
  fi

  IFACES=$(ifconfig -l)
  for i in $IFACES; do
    IP=$(ipconfig getifaddr $i)
    if [[ ! -z $IP ]]; then
      echo $(printf $SPLG_GREEN)$i$(printf $CLEAR): $IP
    fi
  done

}

# Spoof MAC address
function smack() {
  echo "Changing en0 MAC address to ${1}"
  sudo ifconfig en0 ether $1
}

function pub() {
  mip p
}

_mip()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $( compgen -W "$(ifconfig -l)" -- "$cur" ) )
    return 0
}
complete -F _mip mip
