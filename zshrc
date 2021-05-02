# Set default lang
export LANGUAGE="en_US.UTF-8"
export LC_ALL=en_US.UTF-8

# Go path
export GOPATH="${HOME}/go"

# Gray color for autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

# Check for personal bin
if [[ -d "${HOME}/.bin" ]]; then
  export PATH="${HOME}/.bin:$PATH"
fi

# Autoload plugins
autoload -Uz compinit && compinit
autoload -Uz colors && colors
autoload -Uz promptinit && promptinit
autoload -Uz bashcompinit && bashcompinit

# Load zplug
export ZPLUG_HOME=$HOME/.zsh/zplug
source $ZPLUG_HOME/init.zsh

# Aliases
alias ls='ls -la'
alias grep='grep --color=auto '
alias egrep='egrep --color=auto '
export GREP_COLOR='34;1'

# Always pass the environment
alias sudo='sudo -E'
alias gs='git status'
alias gc='git clone'
# Setopts

# General options
setopt globdots
setopt mark_dirs
setopt list_packed
setopt extended_glob
setopt nullglob
setopt SH_WORD_SPLIT

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

# History
export HISTSIZE=50000
export SAVEHIST=10000
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt inc_append_history
setopt share_history

# SSH
zplug "hkupty/ssh-agent", from:github

# Load plugins
zplug "zsh-users/zsh-history-substring-search", from:github, defer:2
zplug "djui/alias-tips", from:github

zplug "woefe/wbase.zsh"
zplug "woefe/git-prompt.zsh", use:"{git-prompt.zsh,examples/wprompt.zsh}"
zplug "junegunn/fzf", use:"shell/*.zsh"
zplug "junegunn/fzf-bin", from:gh-r, as:command, rename-to:fzf, use:"*linux*amd64*"
zplug "sharkdp/fd", from:gh-r, as:command, rename-to:fd, use:"*x86_64-unknown-linux-gnu.tar.gz"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting", from:github, defer:2
zplug "zsh-users/zsh-history-substring-search", defer:3

zplug "b4b4r07/httpstat", as:command, use:'(*).sh', rename-to:'$1'

# Use the Emacs-like keybindings
bindkey -e
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey "^X\x7f" backward-kill-line
bindkey "^U" backward-kill-line
bindkey "^X^_" redo
bindkey "^F" forward-word
bindkey "^B" backward-word
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey '^ ' autosuggest-accept
bindkey '^f' autosuggest-accept

# Load any darwin related code
sources=("$HOME/.private/*.*sh")
if [[ $OSTYPE == darwin* ]]; then
    export CLICOLOR=1
    sources+=("${HOME}/.dotfiles/zshfn/darwin/*")
# Load linux related configs
elif [[ $OSTYPE == linux* ]]; then
    alias ls='ls --color=auto'
    sources+=("${HOME}/.dotfiles/zshfn/linux/*")
fi

# Source all the (readable) things (files)!
for dir in "${sources[@]}"; do
  while read -r file; do
      [ -f "$file" ] && source $file;
  done < <(compgen -G "$dir" || true)
  unset file;
done;
unset dir;

reload() {
  # Install plugins if there are plugins that have not been installed
  if ! zplug check --verbose; then
      printf "Install? [y/N]: "
      if read -q; then
          echo; zplug install
      fi
  fi

  clear
  source ~/.zshrc
}


# Update the SSHConfig
sshconfig() {
  $EDITOR $HOME/.ssh/config
}

# Update bash profile
profile() {
  $EDITOR ~/.zshrc
}

# Update dotfiles
dotfiles() {
  $EDITOR $HOME/.dotfiles
}

# Update private configuration
private() {
  $EDITOR $HOME/.private
}

# Add in GOBIN and PATH if it exists
if [[ -d "/usr/local/opt/go/libexec/bin" ]]; then
  export PATH="/usr/local/opt/go/libexec/bin:$PATH:${GOPATH}/bin"
fi

# MOST AWESOMEST THING EVER
goto() {
  echo -n "Switching to ${1}..."
  TARGETS=($(find $GOPATH/src -name $1 -type d -maxdepth 3))
  TARGET_COUNT=$((${#TARGETS[@]}))
  if [ $TARGET_COUNT -eq 0 ]; then
    echo " Sorry! No matching dirs"
    return
  elif [ $TARGET_COUNT -eq 1 ]; then
    cd "${TARGETS}"
  else
    echo -e "\nWe found more than one location matching you input.\n"
    for c in {1..$TARGET_COUNT}; do
      echo "  $c: ${TARGETS[$c]}";
    done
    echo -en "\nPlease choose a destination: "
    read idnum
    itemnum=$(($idnum))
    echo "Switching to ${TARGETS[$itemnum]}"
    cd "${TARGETS[$itemnum]}"
  fi
}

_goto()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $( compgen -W "$(find $GOPATH/src -type d -maxdepth 3 -exec basename {} \;)" -- "$cur" ) )
    return 0
}
complete -F _goto goto

# Go list deps that are not standard for the
golist(){
  PROJ=$1
  if [[ -z $1 ]]; then
    PROJ="./..."
  fi

  go list -f '{{.Deps}}' $PROJ | tr "[" " " | tr "]" " " | xargs go list -f '{{if not .Standard}}{{.ImportPath}}{{end}}'
}


# GoSkel creates a project skeleton for golang projects
function goskel(){
  PROJECT=$1
  if [[ -z $1 ]]; then
    echo "Please provide a project name and re-run."
    return
  fi

  # Create directories
  echo "Creating $PROJECT skeleton"
  echo " --> Adding bin, libs and testing directories"
  mkdir -p $PROJECT/{bin,cmd,libs,testing}
  touch $PROJECT/bin/.gitkeep

  # Add flatfiles
  echo " --> Adding license, todos and readme"
  touch $PROJECT/{TODOS,LICENSE,README.md}

  # Add a gitignore
  echo " --> Adding .gitignore"
  echo "bin/*" > $PROJECT/.gitignore

  # Adding a main.go
  echo " --> Adding main.go"
  echo -e "package main\n\nfunc main() {\n\n}\n" | tee $PROJECT/main.go $PROJECT/cmd/$PROJECT.go > /dev/null
  echo -e "package main\n\nimport (\n\t\"testing\"\n)\n\nfunc TestMain(t *testing.T) {\n\n}\n" | tee $PROJECT/main_test.go $PROJECT/cmd/${PROJECT}_test.go > /dev/null

  # Creating makefile
  echo " --> Adding Makefile"
  echo -e "all: test build\n\ntest:\n\nbuild:\n\tgo build -o bin/$PROJECT cmd/${PROJECT}.go" > $PROJECT/Makefile

  # Adding a README
  echo " --> Setting Readme"
  echo -e "# ${PROJECT}\n---\n\n<DESCRIPTION>\n\n## Usage\n\n## Installation\n\n" | tee $PROJECT/README.md > /dev/null

  # Adding Git Init
  echo " --> Creating Git Repo"
  (cd $PROJECT && git init)

  # Return status
  echo "Created project $PROJECT successfully."

}

goget(){
    if [[ -z $1 ]]; then
        echo "Please provide a repo"
        return
    fi

    # Make the git dir lowercase
    DIR=$(echo $1 | awk '{ print tolower($1) }')

    REPO=$GOPATH/src/`dirname $DIR`
    mkdir -p $REPO
    cd $REPO
    git clone $DIR
}

zplug load


[[ $OSTYPE == *darwin* ]] && alias brew="arch -arm64 brew"
