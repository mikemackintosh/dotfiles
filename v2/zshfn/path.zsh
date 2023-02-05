# Go path
export GOPATH="${HOME}/go"

# Check for personal bin
if [[ -d "${HOME}/.bin" ]]; then
  export PATH="${HOME}/.bin:$PATH"
fi
