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
It will check your code everytime you open and save a css or html file.
for javascript files, you must manualy call :FDLint to check. This is for performance consider.
You may want to bind a hotkey to `:FDLint`. It is `<leader>+fd` by default.

## Thanks
This vim script is built base on the awesome **jslint.vim** vim plugin, which is available here:
https://github.com/hallettj/jslint.vim
