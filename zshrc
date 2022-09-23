# Set default lang
export LANGUAGE="en_US.UTF-8"
export LC_ALL=en_US.UTF-8

# Go path
export GOPATH="${HOME}/go"


# Gray color for autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s`
  ssh-add
fi

# Check for personal bin
if [[ -d "${HOME}/.bin" ]]; then
  export PATH="${HOME}/.bin:$PATH"
fi
export PATH="${HOME}/.bin/google-cloud-sdk/bin:/opt/homebrew/bin:${PATH}:${GOPATH}/bin"


function __git_prompt_git() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

function git_prompt_status() {
  [[ "$(__git_prompt_git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]] && return

  # Maps a git status prefix to an internal constant
  # This cannot use the prompt constants, as they may be empty
  local -A prefix_constant_map
  prefix_constant_map=(
    '\?\? '     'UNTRACKED'
    'A  '       'ADDED'
    'M  '       'ADDED'
    'MM '       'MODIFIED'
    ' M '       'MODIFIED'
    'AM '       'MODIFIED'
    ' T '       'MODIFIED'
    'R  '       'RENAMED'
    ' D '       'DELETED'
    'D  '       'DELETED'
    'UU '       'UNMERGED'
    'ahead'     'AHEAD'
    'behind'    'BEHIND'
    'diverged'  'DIVERGED'
    'stashed'   'STASHED'
  )

  # Maps the internal constant to the prompt theme
  local -A constant_prompt_map
  constant_prompt_map=(
    'UNTRACKED' "$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    'ADDED'     "$ZSH_THEME_GIT_PROMPT_ADDED"
    'MODIFIED'  "$ZSH_THEME_GIT_PROMPT_MODIFIED"
    'RENAMED'   "$ZSH_THEME_GIT_PROMPT_RENAMED"
    'DELETED'   "$ZSH_THEME_GIT_PROMPT_DELETED"
    'UNMERGED'  "$ZSH_THEME_GIT_PROMPT_UNMERGED"
    'AHEAD'     "$ZSH_THEME_GIT_PROMPT_AHEAD"
    'BEHIND'    "$ZSH_THEME_GIT_PROMPT_BEHIND"
    'DIVERGED'  "$ZSH_THEME_GIT_PROMPT_DIVERGED"
    'STASHED'   "$ZSH_THEME_GIT_PROMPT_STASHED"
  )

  # The order that the prompt displays should be added to the prompt
  local status_constants
  status_constants=(
    UNTRACKED ADDED MODIFIED RENAMED DELETED
    STASHED UNMERGED AHEAD BEHIND DIVERGED
  )

  local status_text="$(__git_prompt_git status --porcelain -b 2> /dev/null)"

  # Don't continue on a catastrophic failure
  if [[ $? -eq 128 ]]; then
    return 1
  fi

  # A lookup table of each git status encountered
  local -A statuses_seen

  if __git_prompt_git rev-parse --verify refs/stash &>/dev/null; then
    statuses_seen[STASHED]=1
  fi

  local status_lines
  status_lines=("${(@f)${status_text}}")

  # If the tracking line exists, get and parse it
  if [[ "$status_lines[1]" =~ "^## [^ ]+ \[(.*)\]" ]]; then
    local branch_statuses
    branch_statuses=("${(@s/,/)match}")
    for branch_status in $branch_statuses; do
      if [[ ! $branch_status =~ "(behind|diverged|ahead) ([0-9]+)?" ]]; then
        continue
      fi
      local last_parsed_status=$prefix_constant_map[$match[1]]
      statuses_seen[$last_parsed_status]=$match[2]
    done
  fi

  # For each status prefix, do a regex comparison
  for status_prefix in ${(k)prefix_constant_map}; do
    local status_constant="${prefix_constant_map[$status_prefix]}"
    local status_regex=$'(^|\n)'"$status_prefix"

    if [[ "$status_text" =~ $status_regex ]]; then
      statuses_seen[$status_constant]=1
    fi
  done

  # Display the seen statuses in the order specified
  local status_prompt
  for status_constant in $status_constants; do
    if (( ${+statuses_seen[$status_constant]} )); then
      local next_display=$constant_prompt_map[$status_constant]
      status_prompt="$next_display$status_prompt"
    fi
  done

  echo $status_prompt
}

function git_current_branch() {
  local ref
  ref=$(__git_prompt_git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

typeset _agent_forwarding _ssh_env_cache

function _start_agent() {
	local lifetime
	zstyle -s :omz:plugins:ssh-agent lifetime lifetime

	# start ssh-agent and setup environment
	echo Starting ssh-agent...
	ssh-agent -s ${lifetime:+-t} ${lifetime} | sed 's/^echo/#echo/' >! $_ssh_env_cache
	chmod 600 $_ssh_env_cache
	. $_ssh_env_cache > /dev/null
}

function _add_identities() {
	local id line sig lines
	local -a identities loaded_sigs loaded_ids not_loaded
	zstyle -a :omz:plugins:ssh-agent identities identities

	# check for .ssh folder presence
	if [[ ! -d $HOME/.ssh ]]; then
		return
	fi

	# add default keys if no identities were set up via zstyle
	# this is to mimic the call to ssh-add with no identities
	if [[ ${#identities} -eq 0 ]]; then
		# key list found on `ssh-add` man page's DESCRIPTION section
		for id in id_rsa id_dsa id_ecdsa id_ed25519 identity; do
			# check if file exists
			[[ -f "$HOME/.ssh/$id" ]] && identities+=$id
		done
	fi

	# get list of loaded identities' signatures and filenames
	if lines=$(ssh-add -l); then
		for line in ${(f)lines}; do
			loaded_sigs+=${${(z)line}[2]}
			loaded_ids+=${${(z)line}[3]}
		done
	fi

	# add identities if not already loaded
	for id in $identities; do
		# check for filename match, otherwise try for signature match
		if [[ ${loaded_ids[(I)$HOME/.ssh/$id]} -le 0 ]]; then
			sig="$(ssh-keygen -lf "$HOME/.ssh/$id" | awk '{print $2}')"
			[[ ${loaded_sigs[(I)$sig]} -le 0 ]] && not_loaded+="$HOME/.ssh/$id"
		fi
	done

	local args
	zstyle -a :omz:plugins:ssh-agent ssh-add-args args
	[[ -n "$not_loaded" ]] && ssh-add "${args[@]}" ${^not_loaded}
}

# Get the filename to store/lookup the environment from
_ssh_env_cache="$HOME/.ssh/environment-$SHORT_HOST"

# test if agent-forwarding is enabled
zstyle -b :omz:plugins:ssh-agent agent-forwarding _agent_forwarding

if [[ $_agent_forwarding == "yes" && -n "$SSH_AUTH_SOCK" ]]; then
	# Add a nifty symlink for screen/tmux if agent forwarding
	[[ -L $SSH_AUTH_SOCK ]] || ln -sf "$SSH_AUTH_SOCK" /tmp/ssh-agent-$USERNAME-screen
elif [[ -f "$_ssh_env_cache" ]]; then
	# Source SSH settings, if applicable
	. $_ssh_env_cache > /dev/null
	if [[ $USERNAME == "root" ]]; then
		FILTER="ax"
	else
		FILTER="x"
	fi
	ps $FILTER | grep ssh-agent | grep -q $SSH_AGENT_PID || {
		_start_agent
	}
else
	_start_agent
fi

_add_identities


# Autoload plugins
# autoload -Uz compinit && compinit
autocomplete() {
  source $HOME/.dotfiles/zshfn/zsh-autocomplete/zsh-autocomplete.plugin.zsh
}

source $HOME/.dotfiles/zshfn/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

autoload -Uz colors && colors
autoload -Uz promptinit && promptinit
autoload -Uz bashcompinit && bashcompinit

zmodload zsh/langinfo

# Aliases
alias ll="ls -alG"
alias tf="terraform"
alias plan="terraform plan"
alias g="gcloud"
alias apply="terraform apply"

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

# SSH
#zplug "hkupty/ssh-agent", from:github

# Load plugins
#zplug "zsh-users/zsh-history-substring-search", from:github, defer:2
#zplug "djui/alias-tips", from:github

#zplug "woefe/wbase.zsh"
#zplug "woefe/git-prompt.zsh", use:"{git-prompt.zsh,examples/wprompt.zsh}"
#zplug "sharkdp/fd", from:gh-r, as:command, rename-to:fd, use:"*x86_64-unknown-linux-gnu.tar.gz"
zplug "zsh-users/zsh-completions"
#zplug "zsh-users/zsh-autosuggestions"
#zplug "zsh-users/zsh-syntax-highlighting", from:github, defer:2
#zplug "zsh-users/zsh-history-substring-search", defer:3

#zplug "b4b4r07/httpstat", as:command, use:'(*).sh', rename-to:'$1'
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Use the Emacs-like keybindings
bindkey -e
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey "^X\x7f" backward-kill-line
bindkey "^U" backward-kill-line
bindkey "\e[3~" delete-char
bindkey "^X^_" redo
bindkey "^F" forward-word
bindkey "^B" backward-word
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey '^ ' autosuggest-accept
bindkey '^f' autosuggest-accept
bindkey ' ' magic-space
bindkey -s '\el' 'ls\n'
bindkey '\ew' kill-region

# Load any darwin related code
sources=("$HOME/.dotfiles/zshfn/corpident/*.*sh")
sources+=("$HOME/.private/*.*sh")

_git_branch_precmd() {
  export GIT_BRANCH="$(git_current_branch)"
}
precmd_functions+=(_git_branch_precmd)

_preexec_chrono() {
  export START_TIME=$(chrono -m)
}
preexec_functions+=(_preexec_chrono)

_precmd_chrono() {
  CHRONO_DURATION=$(chrono)
  unset START_TIME
}
precmd_functions+=(_precmd_chrono)

precmd() {
  RPROMPT="%B%F{215}${CHRONO_DURATION}%f%b"
  if [[ -n "${GIT_BRANCH/[ ]*\n/}" ]]; then
    RPROMPT="${RPROMPT} | %F{blue}${GIT_BRANCH}%f"
  fi

  PROMPT="$PROMPT"
}
precmd_functions+=(precmd)

function cd () {
  local DOTENV="\033[1;38;5;220m[\033[0;38;5;214md\033[0;38;5;215mo\033[0;38;5;216mt\033[0;38;5;217me\033[0;38;5;218mn\033[0;38;5;219mv\033[1;38;5;220m]\033[0m"
  if [[ -f .env ]]; then
    echo "${DOTENV} Unscoping \033[38;5;243m.env\033[0m configuration"
    unset $(cat .env | cut -d'=' -f1)
  fi
  builtin cd "$@"
  if [[ -f .env ]]; then
    set -o allexport
    echo "${DOTENV} Sourcing environment from \033[38;5;243m.env\033[0m"
    source .env
    set +o allexport
  fi
}
function ".."() { cd .. }
function "../.."() { cd ../.. }
function "../../.."() { cd ../../.. }
function "../../../.."() { cd ../../../.. }

export CORPIDENT=$CORPIDENT_DOORDASH
PROMPT="${CORPIDENT}%F{blue}%1~%f %B%F{green}%#%f%b "

# Source all the (readable) things (files)!
for dir in "${sources[@]}"; do
  while read -r file; do
    [ -f "$file" ] && source $file;
  done < <(compgen -G "$dir" || true)
  unset file;
done;
unset dir;

reload() {
  clear
  #source ~/.zshrc
  exec zsh -l
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

# zplug load


if [[ $(uname -p) == *arm* ]]; then
  export ARCHFLAGS="-arch arm64"
  alias brew="arch -arm64 brew"
fi
