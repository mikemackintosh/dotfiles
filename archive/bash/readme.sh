#!/bin/bash

function readme() {
  local doc=$1

  # Check if we passed a doc
  if [[ -z "${doc}" ]]; then
    doc="README.md"
  fi

  # Check if the doc exists
  if [ ! -f "$doc" ]; then
    echo "No README.md"
    return 1
  fi

  # Creates a reusable
  bold=$(printf '\033[1m')
  italic=$(printf '\033[3m')
  underline=$(printf '\033[4m')
  codeblock=$(printf '\033[48;5;254m')
  blockquote=$(echo $italic)$(printf '\033[48;5;230m')
  clear=$(printf '\033[0;30;107m')

  # Set the background to white
  echo -e "$clear";
  echo ""

  # Create our initial readme
  README=$(cat README.md)

  # Start with a horizontal rule
  hr=$(printf "─%.0s" $(seq 1 $(($(tput cols)-4))))
  README=$(echo "$README" | sed -E "s/^([-]{3,}|[=]{3,}|[#]{3,}|[_]{3,})\$/${bold}${hr}${clear}/")

  # Update headings
  README=$(echo "$README" | sed -E "s/^###(.*)/${bold}\1${clear}/")
  README=$(echo "$README" | sed -E "s/^##(.*)/${bold}\1${clear}/")
  README=$(echo "$README" | sed -E "s/^#(.*)/${bold}\1${clear}/")

  # Update block quotes
  README=$(echo "$README" | sed -E "s/^\>(.*)/${blockquote} ║ \1 ${clear}/")

  # Update links
  README=$(echo "$README" | sed -E "s/[()]\((.*)\)/${underline} ║ \1 ${clear}/")

  # Update indent-derived code blocks
  README=$(echo "$README" | sed -E "s/^    (.*)/${codeblock}    \1${clear}/")

  # Sed will only do one match and is very greedy by default, so we need to loop to get them all
  for i in {0..8}; do
    README=$(echo "$README" | sed -E "s/\`([-_#+\\\/\(\)\.\*\!\@#\$%a-zA-Z0-9 ]+)\`/${codeblock} \1 ${clear}/");
  done

  # Adds a space to the beginning of  each line for a clear padding.
  README=$(echo "$README" | awk '{print "  " $0}')
  echo "$README"
  echo ""
  echo -e "\033[0m"
}
