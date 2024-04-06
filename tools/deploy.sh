#!/bin/bash

#Run this in the repo root after compiling
#First arg is path to where you want to deploy
#creates a work tree free of everything except what's necessary to run the game

#second arg is working directory if necessary
if [[ $# -eq 2 ]] ; then
  cd $2
fi

mkdir -p \
    $1/config \
    $1/data \
    $1/maps \
    $1/icons \
    $1/sound \
    $1/tgui/public \
    $1/tgui/packages/tgfont/static \
    $1/nano/images

if [ -d ".git" ]; then
  mkdir -p $1/.git/logs
  cp -r .git/logs/* $1/.git/logs/
fi

cp baystation12.dmb baystation12.rsc $1/
cp -r config/* $1/config/
cp -r config/example/* $1/config/
cp -r maps/* $1/maps/
cp -r icons/* $1/icons/
cp -r tgui/public/* $1/tgui/public/
cp -r tgui/packages/tgfont/static/* $1/tgui/packages/tgfont/static/
cp -r nano/images/* $1/nano/images

#remove .dm files from _maps

#this regrettably doesn't work with windows find
#find $1/_maps -name "*.dm" -type f -delete

#dlls on windows
if [ "$(uname -o)" = "Msys" ]; then
	cp ./*.dll $1/
fi
