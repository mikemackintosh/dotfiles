#!/bin/bash

git clone https://github.com/qmk/qmk_firmware $HOME/qmk
ln -s $HOME/.dotfiles/qmk/duppster $HOME/qmk/keyboards/massdrop/alt/keymaps/duppster
