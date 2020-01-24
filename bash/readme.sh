#!/bin/bash

function readme() {
  local doc=$1
  if [[ -z "${doc}" ]]; then
    doc="README.md"
  fi

  if [ ! -f "$doc" ]; then
    echo "No README.md"
    return 1
  fi

  echo -e "\033[1;30;107m";
  echo ""
  cat README.md | awk '{print "  " $0}'
  echo ""
  echo -e "\033[0m"
}
