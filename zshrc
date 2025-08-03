DOT_ZSH_PLUGIN_DIR="${HOME}/.dotfiles/zsh"

# Set brew env
if [[ -d /opt/homebrew/bin ]]; then
  eval $(/opt/homebrew/bin/brew shellenv)
fi

# Set default lang
export LANGUAGE="en_US.UTF-8"
export LC_ALL=en_US.UTF-8

# Set the editor, default to VIM
# Upgrade to VS Code if it's installed
export EDITOR=vim
command -v code &>/dev/null
if [[ $? -eq 0 ]]; then
  export EDITOR=code
fi

#
# Setopts
#
# General options
setopt globdots
setopt mark_dirs
setopt list_packed
setopt extended_glob
setopt nullglob
setopt SH_WORD_SPLIT

# Changing directories
# setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus
setopt auto_param_keys
setopt auto_param_slash

# Completion
setopt auto_list
setopt auto_menu
setopt always_to_end
setopt complete_in_word
setopt flow_control
setopt menu_complete

# History
export HISTSIZE=50000
export SAVEHIST=10000
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt inc_append_history
setopt share_history

# Auto-load completion and tab menu
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select

# Move cursor to bottom of screen
printf '\n%.0s' {1..$LINES}
# Set cursor to I-beam
printf '\033[5 q\r'

alias clear="clear && printf '\n%.0s' {1..$LINES} && printf '\033[5 q\r'"

#
# source ~/.zshrc
reload() {
    clear
    source ~/.zshrc
    echo -e "\033[38;5;208mReloaded!\033[0m"
}

# Syntax highlighting
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

STD_PATH=$PATH
extra_sources=(
    $HOME/bin
    "${GOPATH}/bin"
    /opt/homebrew/bin/
)
export PATH="${(j.:.)extra_sources}:$STD_PATH"

export GOPATH=$HOME/go

dot_plugins=(
    "add_secret"
    "alias"
    "git"
    "go"
    "grep"
    "keybind"
    "private"
    "ssh"

    "omp"
)

for f in $dot_plugins; do
    # echo "Loading: $i"
    source ${DOT_ZSH_PLUGIN_DIR}/${f}.zsh
done

eval "$(/opt/homebrew/bin/oh-my-posh init zsh --config ${HOME}/.dotfiles/omp/themes/dcs.omp.json)"
