#!/bin/bash
# DSL for colors
color() {
  echo -e "\033[0m"
  case $1 in
    purple)      color_fg="38;5;135";;
    pink)        color_fg="38;5;198";;
    lightblue)   color_fg="38;5;45";;
    blue)        color_fg="38;5;32";;
    red)         color_fg="38;5;196";;
    darkred)     color_fg="38;5;160";;
    lightgreen)  color_fg="38;5;156";;
    green)       color_fg="38;5;154";;
    orange)      color_fg="38;5;208";;
    lightorange) color_fg="38;5;214";;
    grey)        color_fg="38;5;242";;
    darkgrey)    color_fg="38;5;239";;
    lightgrey)   color_fg="38;5;249";;
    *)           color_fg="0";;
  esac

  echo -e "\033[${color_fg}m"
  return
}

_color()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $( compgen -W "purple pink lightblue blue red darkred lightgreen green orange lightorange grey darkgrey lightgrey" -- "$cur" ) )
    return 0
}
complete -F _color color


# Loop through colors
showcolors() {
  for i in {0..255}; do
    echo -n $(tput setaf $i)
    echo "This is color $i"
    echo -n $(tput setaf $(($i - 10)))
    echo -n $(tput setab $i)
    echo "This is color $i still"
    echo -e $SPLG_CLEAR

  done
}

# Legacy support
export SPLG_PURPLE="\033[38;5;135m"
export PURPLE=$SPLG_PURPLE
export SPLG_PINK="\033[38;5;198m"
export PINK=$SPLG_PURPLE
export SPLG_LBLUE="\033[38;5;45m"
export LIGHT_BLUE=$SPLG_PURPLE
export SPLG_DBLUE="\033[38;5;32m"
export DARK_BLUE=$SPLG_PURPLE
export SPLG_RED="\033[38;5;196m"
export RED=$SPLG_PURPLE
export SPLG_DRED="\033[38;5;160m"
export DARK_RED=$SPLG_PURPLE
export SPLG_GREEN="\033[38;5;156m"
export GREEN=$SPLG_PURPLE
export SPLG_BGREEN="\033[38;5;154m"
export BRIGHT_GREEN=$SPLG_PURPLE
export SPLG_ORANGE="\033[38;5;208m"
export ORANGE=$SPLG_PURPLE
export SPLG_LORANGE="\033[38;5;214m"
export LIGHT_ORANGE=$SPLG_PURPLE
export SPLG_GREY="\033[38;5;242m"
export GREY=$SPLG_PURPLE
export SPLG_DGREY="\033[38;5;239m"
export DARK_GREY=$SPLG_PURPLE
export SPLG_LGREY="\033[38;5;249m"
export LIGHT_GREY=$SPLG_PURPLE
export SPLG_CLEAR="\033[0m" #$(tput sgr0)
export CLEAR=$SPLG_CLEAR

# Dunkin Donuts
export DD_ORANGE="\033[38;5;202m"
export DD_PINK="\033[38;5;205m"
export DD_LPINK="\033[38;5;207m"

# color(1) completion
