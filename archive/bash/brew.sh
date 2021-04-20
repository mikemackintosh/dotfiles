if [[ $(uname) == "Darwin" ]]; then
  function update() {
    brew doctor
    brew update
    brew upgrade
  }
fi
