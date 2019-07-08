#!/bin/sh

# --------------------------------------------------
# Dotfiles
# --------------------------------------------------
if [ -e ~/dotfiles ]; then
    mv ~/dotfiles ~/.dotfiles
elif [ -e ~/.dotfiles ]; then
    cd ~/.dotfiles
    echo "Dotfiles Git Update..."
    git pull
    cd
else
    git clone git@github.com:te-koyama/dotfiles.git ~/.dotfiles
fi

# --------------------------------------------------
# Emacs
# --------------------------------------------------
if [ ! -e ~/.emacs.d ]; then
    ln -sf ~/.dotfiles/.emacs.d ~/.emacs.d
    echo "\n.emacs.d Symbolic Link Creation Completed!."
fi
