# The next line updates PATH for the Google Cloud SDK.
if [ -f '/usr/local/gcloud/path.bash.inc' ]; then source '/usr/local/gcloud/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/usr/local/gcloud/completion.bash.inc' ]; then source '/usr/local/gcloud/completion.bash.inc'; fi

# Add appengine alias
alias appengine="/usr/local/google-cloud-sdk/bin/dev_appserver.py"
