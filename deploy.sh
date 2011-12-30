#!/bin/bash
VIM_RUNTIME=~/.vim_runtime
rm -rf $VIM_RUNTIME/plugin/fdlint
cp -a plugin $VIM_RUNTIME
