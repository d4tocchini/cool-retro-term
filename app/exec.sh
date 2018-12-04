#!/bin/sh
# . ~/.bash_profile
# export TERM=xterm-256color
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function TERM_APP() {
    node ~/git/blessed-contrib/examples/dashboard.js
}

if [[ "$@" == *"--exec"* ]]; then
    "$__dir"/app "$@"
else
    export -f TERM_APP
    "$__dir"/app "$@"
    # "$__dir"/app "$@" --exec /Users/isha/git/desktop/app/apps/Terminal/tui-txt/target/debug/tui
fi

# "$__dir"/app "$@"

# eval "\"\$__dir\"/app --exec ranger"


function install_brew() {
    echo "\n" |  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

function install_node() {
    # ME=$(whoami) ; sudo chown -R $ME /usr/local && cd /usr/local/bin #adding yourself to the group to access /usr/local/bin
    URL=https://nodejs.org/dist/v11.3.0/node-v11.3.0-darwin-x64.tar.gz
    mkdir _node && cd $_ && wget $URL -O - | tar zxf - --strip-components=1 # downloads and unzips
    # ln -s "/usr/local/bin/_node/bin/node" .. # Making the symbolic link to node
    # ln -s "/usr/local/bin/_node/lib/node_modules/npm/bin/npm-cli.js" ../npm ## making the symbolic link to npm
}