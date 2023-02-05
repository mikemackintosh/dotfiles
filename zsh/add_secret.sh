# addsecret - Helps manage secrets stored in a users environment within
# $HOME/.private. This function takes two arguments, `service` and `secret`.
#
# To debug, run with DEBUG=true addsecret [options]
#
# Usage:
#    $ addsecret oauth_service f07s84d9a219acc8f69a8af9bd
#    To access secret, run: set_oauth_secret
#    -> creates $HOME/.private/oauth_service.sh
#    -> source's $HOME/.private/oauth_service.sh
#    -> secret added to environment by running
#    -> secret exported to OAUTH_SECRET_TOKEN
#    To access your secret via OAUTH_SECRET_TOKEN, run:
#
#        set_oauth_service_token
#
function addsecret  {
  if [[ -z $1 || -z $2 ]]; then
    echo "Usage: addsecret <service> <secret>"
    return 1
  fi

  # set local vars from args
  local name=$1
  local secret=$2

  # create the private dir if it doesnt exist
  if [[ ! -d "${HOME}/.private" ]]; then
    mkdir -p ${HOME}/.private || echo "[ERR] Couldn't create private directory"
  fi

  # set some variables such as the name uppercased
  # and the secret file to write
  lower_name=$(echo $name | tr [:upper:] [:lower:])
  func_name="set_${lower_name}_token"
  unset_func_name="unset_${lower_name}_token"
  secret_file=${HOME}/.private/${name}.sh
  upper_name=$(echo $name | tr [:lower:] [:upper:])
  token="${upper_name}_TOKEN"
  check="HAS_${upper_name}_TOKEN"
  [ ! -z $DEBUG ] && echo "-> setting ENV var access via ${token}"

  # Write to the secret file
  [ ! -z $DEBUG ] && echo "-> creating $secret_file"
  (cat >| $secret_file) <<EOF
#!/bin/bash
function ${func_name}() {
  [ ! -z $DEBUG ] && echo "Setting ${name} token in env as ${upper_name}_TOKEN..."
  export ${token}=${secret}
  export ${check}=1
}
function ${unset_func_name}() {
  [ ! -z $DEBUG ] && echo "Unetting ${name} token"
  unset ${token}
  unset ${check}
}
EOF

  # chmod the file
  chmod 0700 $secret_file

  # load the new file
  [ ! -z $DEBUG ] && echo "-> source'ing $secret_file"
  source $secret_file

  echo -e "To access your secret via ${token}, reload your bash profile and run:\n\n\t$func_name"

  # This will automatically source the changed files into your environment
  for f in $HOME/.private/*.sh; do
    source $f;
  done
  return 0
}