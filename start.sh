#!/usr/bin/zsh

if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
    source $HOME/.rvm/scripts/rvm
else
    echo "No RVM found."
    exit 1
fi

cd $HOME/Showbot

rvm 2.1.2 do bundle exec foreman start -f Procfile >> $1
