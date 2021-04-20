# Go path
export GOPATH="${HOME}/go"

# Check for personal bin
export PATH="${HOME}/.bin:${PATH}"
if [[ -d "${HOME}/bin" ]]; then
  export PATH="${HOME}/bin:$PATH"
fi
