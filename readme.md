# FDLint as vim plugin

This is the vim plugin for [fdlint](https://github.com/qhwa/fdlint) which helps web developers write better code by reading and reviewing codes.

## preview

![reviewing](http://q.pnq.cc/wp-content/uploads/2012/02/fdlint-vim-500x543.png)

## install

    git clone git://github.com/qhwa/fdlint-vim.git
    cd fdlint-vim

    git submodule init
    git submodule update

    #copy plugin to your $VIM_RUNTIME/ (commonly '~/.vim')
    VIM_RUNTIME=~/.vim
    cp -a plugin/* $VIM_RUNTIME/plugin/


## usage
It will check your code everytime you open and save a css or html file.

fdlint.vim will review your code when...
* every time you edit CSS/HTML file
* you open CSS/HTML file
* you called `:FDLint` command in a CSS/HTML/JS buffer

You may want to bind a hotkey to `:FDLint`. It is `<leader>+fd` by default.

## Thanks
This vim script is built base on the awesome **jslint.vim** vim plugin, which is available here:
https://github.com/hallettj/jslint.vim
