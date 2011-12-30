" The vim plugin of FDLint (codename: xray)
" @author qhwa
" @see TODO:manual

if exists("g:disable_fdlint") || exists("g:did_fdlint_plugin")
    "finish
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
    autocmd BufRead,BufWritePost *.css,*.js,*.html,*.htm :ruby VIM_FDLint::check
    autocmd CursorMoved *.css,*.js,*.html,*.htm :ruby VIM_FDLint::show_err_msg
augroup END


let g:path_to_fdlint = "/home/qhwa/projects/fdev-xray/xray" . "\\ --format=vim"

" add the new menu item via NERD_Tree's API
call NERDTreeAddMenuItem({
    \ 'text': 'check with (F)dlint',
    \ 'shortcut': 'f',
    \ 'callback': 'NERDFDlint' })

function! NERDFDlint()
    " get the current dir from NERDTree
    let cd = g:NERDTreeDirNode.GetSelected().path.str()

    let grepprg_bak = &grepprg
    exec "set grepprg=" . g:path_to_fdlint
    exec 'silent! grep ' . cd

    let &grepprg=grepprg_bak
    exec "redraw!"

    let hits = len(getqflist())
    if hits == 0
        echo 'Check done, everything is OK'
    elseif hits > 1
        echo 'Found ' . hits . ' hits. Use the menu to navigate!'
        botright copen
    endif

endfunction


exe ":rubyf " . expand('<sfile>:p:h') . '/fdlint.rb'


