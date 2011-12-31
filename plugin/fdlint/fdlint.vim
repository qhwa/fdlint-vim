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
    autocmd BufRead,BufWritePost *.css,*.js,*.html,*.htm :call g:fdlint()
    autocmd CursorMoved *.css,*.js,*.html,*.htm :ruby VIM_FDLint::show_err_msg
augroup END


" add the new menu item via NERD_Tree's API
if exists("*NERDTreeAddMenuItem")
  call NERDTreeAddMenuItem({
      \ 'text': 'check with (F)dlint',
      \ 'shortcut': 'f',
      \ 'callback': 'NERDFDlint' })
endif

function NERDFDlint()
    let cd = g:NERDTreeFileNode.GetSelected().path.str()
    call g:fdlint( cd )
endfunction

function g:fdlint(...)
    if a:0
        call setqflist([])
        exec 'ruby VIM_FDLint::check_file("'. a:1 . '")'
        cwindow
    else
        ruby VIM_FDLint::check
    end
endfunction

command -nargs=? FDLint call g:fdlint(<f-args>)

exe ":rubyf " . expand('<sfile>:p:h') . '/fdlint.rb'
