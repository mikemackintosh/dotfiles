# LL aliases
alias ll="ls -lapG"
alias ls="ls -pG"

# Highlight
alias show="highlight -O ansi"

# Lock screen
alias lockscreen='/System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend'

# Encrypted Zip
function ze {
  zip -er protected.zip $2
}

# Archie a directory by prefixing it with zzarchive
function ar {
  mv {,zzarchive-}$1
}


# Convert a png to a jpg
function p2j() {
 FILENAME=$1
 OUTFILE=$(echo $1|cut -d'.' -f 1)
 sips -s format jpeg $FILENAME --out $OUTFILE.jpg
}

# Generates A Random string, works with OS X
function randomstring() {
  cat /dev/urandom | LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w ${1:-10} | head -n 1
}

# Replace <1> with <2> in the directory
function replace() {
  find_this="$1"
  replace_with="$2"
  ag -l --nocolor "$find_this" $* | xargs sed -i '' "s/$find_this/$replace_with/g"
}

# Pacman love..
function pacman() {
  echo "Wakka, Wakka, Wakka..."
  echo -e "\n\033[1;33mᗧ\033[0m • • • \033[1;31mᗣ\033[0m  • •\n"
}
alias fstat="stat -x"
