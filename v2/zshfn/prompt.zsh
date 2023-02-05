# Set the theme, default to zepnik.
setopt promptsubst

# Load the theme
. ${HOME}/.dotfiles/zshfn/themes/${THEME:-"zepnik"}.zsh

theme() {
  unset PROMPT
  unset RPROMPT
  if [[ -f ${HOME}/.dotfiles/zshfn/themes/${1}.zsh ]]; then
    export THEME=$1
    reload
    return 0
  fi

  echo "Theme does not exist."
  return 1
}
