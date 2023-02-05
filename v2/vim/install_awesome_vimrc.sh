#!/bin/sh
set -e

cd ~/.dotfiles/vim

echo 'set runtimepath+=~/.dotfiles/vim

source ~/.dotfiles/vim/vimrcs/basic.vim
source ~/.dotfiles/vim/vimrcs/filetypes.vim
source ~/.dotfiles/vim/vimrcs/plugins_config.vim
source ~/.dotfiles/vim/vimrcs/extended.vim

try
source ~/.dotfiles/vim/my_configs.vim
catch
endtry' > ~/.vimrc

echo "Installed the Ultimate Vim configuration successfully! Enjoy :-)"
