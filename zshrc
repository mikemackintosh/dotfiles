ZNAP_PLUGIN_DIR=$HOME/.zsh-plugins
DOT_ZSH_PLUGIN_DIR=$HOME/.dotfiles/zsh
GOPATH=$HOME/go

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

# Gray color for autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=239'


#
# Deps and Environment
#
# Check for personal bin
if [[ -d "${HOME}/.bin" ]]; then
  export PATH="${HOME}/.bin:$PATH"
fi

if [[ $STD_PATH == "" ]]; then
    export STD_PATH="$PATH"
fi

# Autoload plugins
# autoload -Uz compinit && compinit
autoload -Uz colors && colors
autoload -Uz promptinit && promptinit
autoload -Uz bashcompinit && bashcompinit
autoload -Uz compinit && compinit

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

#
# Zstyle
#
# Configurations for completions and more!
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format "$fg[yellow]%B--- %d%b"
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format "$fg[red]No matches for:$reset_color %d"
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

extra_sources=(
    $HOME/bin
    $HOME/.local/bin
    "${HOME}/.bin/google-cloud-sdk/bin"
    "${GOPATH}/bin"
    /opt/homebrew/bin/
)
export PATH="${(j.:.)extra_sources}:$STD_PATH"

dot_plugins=(
    "keybind"
    "sudo"
    "ssh"
    "colors"
    "git"
    "alias"
    "terraform"
    "private"
    "grep"
    "go"
    "add_secret"
    "autocomplete"
    "prompt"
)

for i in $dot_plugins; do
    # echo "Loading: $i"
    source $DOT_ZSH_PLUGIN_DIR/${i}.*sh
done

#
# Setup
#
# Download Znap, if it's not there yet.
[[ -f $ZNAP_PLUGIN_DIR/zsh-snap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git $ZNAP_PLUGIN_DIR/zsh-snap
source $ZNAP_PLUGIN_DIR/zsh-snap/znap.zsh  # Start Znap

#
# Plugins
#
# The following plugins will be downloaded/enabled
# znap source marlonrichert/zsh-autocomplete
znap source zsh-users/zsh-syntax-highlighting
znap source marlonrichert/zsh-hist
# znap source zsh-users/zsh-autosuggestions

#
#
# Commands
#
# source ~/.zshrc
reload() {
    clear 
    source ~/.zshrc
    echo -e "\033[38;5;208mReloaded!\033[0m"
}