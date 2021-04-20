# Check and alerts if the following URL is up or not
isup() {
  local ts=$(date +"%H:%M:%S")
	local uri=$1

  local status_code="200 OK"
  if [[ ! -z $2 ]]; then
    local status_code=$2
  fi

	if curl -s --head  --request GET "$uri" | grep "$status_code" > /dev/null ; then
    terminal-notifier -sound "default" -title "$uri is up" -subtitle "StartUp Monitor - $ts" -message "This URL is up." -open $uri
	else
    terminal-notifier -sound "Basso" -title "$uri is down" -subtitle "StartUp Monitor - $ts" -message "This URL is down." -open $uri
	fi
}

# https://github.com/julienXX/terminal-notifier
startup() {
  local status=true
  local uri=$1

  local status_code="200 OK"
  if [[ ! -z $2 ]]; then
    local status_code=$2
  fi

  while $status; do
    curl -s --head  --request GET "$uri" -m 1| grep "$status_code" > /dev/null;
    if [[ $? -eq 1 ]]; then
      ts=$(date +"%H:%M:%S")
      terminal-notifier -sound "Basso" -title "$uri is down" -subtitle "StartUp Monitor - $ts" -message "Your changes seem to have broken $uri" -open $uri
      echo -e "Testing \033[38;5;135m${uri}\033[0m at \033[38;5;135m${ts}\033[0m was \033[38;5;196munsuccessful\033[0m!"
      # status=false;
    else
      ts=$(date +"%H:%M:%S")
      echo -e "Testing \033[38;5;135m${uri}\033[0m at \033[38;5;135m${ts}\033[0m was \033[38;5;156msuccessful\033[0m."
      #  terminal-notifier -title "$uri is up" -subtitle "StartUp Monitor - $ts" -message "Changes are working as expected."
    fi
    sleep 1;
  done;
}

# d will return all the formatted results of dig
d() {
  dig +nocmd $1 any +multiline +noall +answer
}
