# FDLint as vim plugin

## install

    git clone git://github.com/qhwa/fdlint-vim.git
    cd fdlint-vim

    git submodule init
    git submodule update

    #copy plugin to your $VIM_RUNTIME/ (commonly '~/.vim')
    VIM_RUNTIME=~/.vim
    cp -a plugin/* $VIM_RUNTIME/plugin/


## usage
It will check your code everytime you open and save a js,css or html file.
