# Add in Android on OSX if it exists
if [[ -d "$HOME/Library/Android/sdk/platform-tools" ]]; then
  export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
fi
