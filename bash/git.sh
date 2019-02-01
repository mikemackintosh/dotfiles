#!/bin/bash

function git_branch {
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    if [ -e $branch ]; then
        return
    else
        if [ $branch == 'master' ]; then
            COLOR="${SPLG_GREEN}"
        elif [ $branch == 'HEAD' ]; then
            COLOR="${SPLG_ORANGE}"
        else
            COLOR="${SPLG_PINK}"
        fi
        echo -e "${SPLG_LGREY}\302\261${COLOR} ${branch}"
    fi
}

# Rewrites the author in the history
function git_rewrite_author {
  export OLD_GIT_EMAIL=$1
  export CORRECT_EMAIL=$2
  git filter-branch -f --env-filter '
if [ "$GIT_COMMITTER_EMAIL" == "$OLD_GIT_EMAIL" ]
then
    #export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" == "$OLD_GIT_EMAIL" ]
then
    #export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
}

function branch {
    git symbolic-ref --short HEAD
}

# Git
alias pp='git pull --rebase && git push'
alias gc='git clone'
alias gs='git status'
alias gl='git lg'
alias commit='git commit -m'
alias add='git add'

function c {
  MESSAGE=$@
  git commit -m "$MESSAGE"
}

function git-cleanup {
  git reflog expire --all --expire=now
  git gc --prune=now --aggressive
}
