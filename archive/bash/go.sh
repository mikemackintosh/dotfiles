# Add in GOBIN and PATH if it exists
if [[ -d "/usr/local/opt/go/libexec/bin" ]]; then
  export PATH="/usr/local/opt/go/libexec/bin:$PATH:${GOPATH}/bin"
fi

# MOST AWESOMEST THING EVER
function goto() {
  echo -n "Switching to ${1}..."
  TARGETS=($(find $GOPATH/src -name $1 -type d -maxdepth 3))
  TARGET_COUNT=${#TARGETS[@]}
  if [ $TARGET_COUNT -eq 0 ]; then
    echo " Sorry! No matching dirs"
    return
  elif [ $TARGET_COUNT -eq 1 ]; then
    cd "${TARGETS[0]}"
  else
    echo -e "\nWe found more than one location matching you input.\n"
    for i in "${!TARGETS[@]}"; do
      item=$(($i + 1))
      echo "  $item: ${TARGETS[$i]}";
    done

    echo -en "\nPlease choose a destination: "
    read idnum
    itemnum=$(($idnum - 1))
    echo "Switching to ${TARGETS[itemnum]}"
    cd "${TARGETS[itemnum]}"
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
function golist(){
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

function goget(){
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
