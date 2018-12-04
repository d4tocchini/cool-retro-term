#!/usr/bin/env bash

function install () {
    brew install qt5
    git submodule init
    git submodule update
}

function build () {
    rm -rf cool-retro-term.app
    # rm -rf .qmake.stash
    # rm -rf Makefile

    # rm -rf qmltermwidget
    # git submodule init
    # git submodule update

    export CPPFLAGS="-I/usr/local/opt/qt5/include"
    export LDFLAGS="-L/usr/local/opt/qt5/lib"
    export PATH=/usr/local/opt/qt5/bin:$PATH
    # export PATH=/opt/Qt5.3.1/5.3/gcc_64/bin/:$PATH

    # cd qmltermwidget
    # qmake && make
    # cd ..
    qmake && make
    mkdir -p cool-retro-term.app/Contents/PlugIns
    cp -r qmltermwidget/QMLTermWidget cool-retro-term.app/Contents/PlugIns
    mv -f cool-retro-term.app/Contents/MacOS/cool-retro-term cool-retro-term.app/Contents/MacOS/app
    cp -f app/exec.sh cool-retro-term.app/Contents/MacOS/cool-retro-term
    chmod +x cool-retro-term.app/Contents/MacOS/cool-retro-term
    # open cool-retro-term.app
}

function open() {
    open cool-retro-term.app
}

# . .sh && commit -a "make & qmake for macos 10.14"
function commit () {
    cd ./qmltermwidget
    git commit "$@"
    cd ..
    git commit "$@"
}