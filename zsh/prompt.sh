# Set the theme, default to zepnik.
. ${HOME}/.dotfiles/zsh/themes/${THEME:-"zepnik"}/${THEME:-"zepnik"}.zsh

theme() {
  if [[ ${1} == "list" ]]; then
    echo "Available themes:"
    for i in $(ls -1 ${HOME}/.dotfiles/zsh/themes/); do
      echo -e "\t- $i"
    done
    return 0
  fi

  if [[ -d ${HOME}/.dotfiles/zsh/themes/${1} ]]; then
    unset PROMPT
    unset RPROMPT
    export THEME=$1
    reload
    return 0
  fi

  echo "Theme does not exist."
  return 1
}
