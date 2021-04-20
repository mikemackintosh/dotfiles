# Set defaults
export EDITOR=atom
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
export CLICOLOR=1
alias ll="ls -alG"

# Set default lang
export LANGUAGE="en_US.UTF-8"
export LC_ALL=en_US.UTF-8

# Check for personal bin
if [[ -d "$HOME/bin" ]]; then
  export PATH="$HOME/bin:$PATH"
fi


# Load any darwin related code
sources=("$HOME/.dotfiles/zshfn/*")
if [[ $OSTYPE == darwin* ]]; then
    export CLICOLOR=1
    sources+=("$HOME/.dotfiles/zshfn/darwin/*")
# Load linux related configs
elif [[ $OSTYPE == linux* ]]; then
    alias ls='ls --color=auto'
    sources+=("$HOME/.dotfiles/zshfn/linux/*")
fi

# Source all the (readable) things (files)!
for file in "${sources[@]}"; do
  echo $file;
    [ -f "$file" ] && [ -r "$file" ] && source "$file";
done;
unset file;


# History
export HISTSIZE=50000
export SAVEHIST=10000
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt inc_append_history
setopt share_history

# General options
setopt globdots
setopt mark_dirs
setopt list_packed


# Changing directories
setopt auto_cd
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

# Completion
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*:default' list-colors ${LS_COLORS}
zstyle ':completion:*' list-suffixes 
zstyle ':completion:*' expand prefix suffix 
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path  ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
