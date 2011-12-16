" The vim plugin of FDLint (codename: xray)
" @author qhwa
" @see TODO:manual

if exists("g:disable_fdlint") || exists("g:did_fdlint_plugin")
    finish
endif

" disabled for debugging
"let g:did_fdlint_plugin=1

if !has("ruby")
    echo "Please install ruby support for your vim"
    echo "...further helper goes here..."
    finish
endif

augroup checkpoint
    "clear triggers first
    autocmd!
    autocmd InsertLeave,BufRead,BufWritePost *.css,*.js,*.html,*.htm :ruby VIM_FDLint::check
    autocmd CursorMoved *.css,*.js,*.html,*.htm :ruby VIM_FDLint::show_err_msg
augroup END

exe ":rubyf " . expand('<sfile>:p:h') . '/fdlint.rb'
