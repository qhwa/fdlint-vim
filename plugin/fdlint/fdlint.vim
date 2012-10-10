" The vim plugin of FDLint
" @author qhwa
" @see TODO:manual

if exists("g:disable_fdlint") || exists("g:did_fdlint_plugin")
    finish
endif

let g:did_fdlint_plugin=1

if !exists("g:FDLintHighlightErrorLine")
  let g:FDLintHighlightErrorLine = 1
endif
let s:install_dir = expand('<sfile>:p:h')
let s:fdlint_bin_path = s:install_dir . "/core/bin/fdlint"
let s:cmd = 'ruby ' . s:fdlint_bin_path . ' --format=vim'

augroup checkpoint
    "clear triggers first
    autocmd!
    autocmd BufEnter,BufRead,BufWritePost,InsertLeave *.css,*.html,*.htm :call g:fdlint()
    autocmd CursorMoved *.css,*.html,*.htm :call g:show_fdlint_hint()
    autocmd BufLeave *.css,*.html,*.htm :call s:FDLintClear()
augroup END

if !exists("*s:FDLintUpdate")
  function s:FDLintUpdate()
    silent call g:fdlint()
    call g:show_fdlint_hint()
  endfunction
endif

if !exists(":FDLintUpdate")
  command FDLintUpdate :call s:FDLintUpdate()
endif

if !exists(":FDLintToggle")
  command FDLintToggle :let b:fdlint_disabled = exists('b:fdlint_disabled') ? b:fdlint_disabled ? 0 : 1 : 1
endif

function! g:fdlint(...)

    if exists("b:jslint_disabled") && b:jslint_disabled == 1
        return
    endif

    highlight link FDLintError SpellBad

    if exists("b:cleared")
        if b:cleared == 0
            call s:FDLintClear()
        endif
    endif

    let b:matched = []
    let b:matchedlines = {}

    " Detect range
    if a:firstline == a:lastline
        " Skip a possible shebang line, e.g. for node.js script.
        if getline(1)[0:1] == "#!"
            let b:firstline = 2
        else
            let b:firstline = 1
        endif
        let b:lastline = '$'
    else
        let b:firstline = a:firstline
        let b:lastline = a:lastline
    endif

    let b:qf_list = []
    let b:qf_window_count = -1

    let lines = join(getline(b:firstline, b:lastline), "\n")

    if len(lines) == 0
        return
    endif

    let b:fdlint_output = system(s:cmd, lines . "\n")

    if v:shell_error
        echoerr b:fdlint_output
        echoerr 'could not invoke FDLint!'
        let b:fdlint_disabled = 1
    end

    call s:show_fdlint_results()
    let b:cleared = 0

endfunction

function! s:FDLintClear()
  " Delete previous matches
  let s:matches = getmatches()
  for s:matchId in s:matches
    if s:matchId['group'] == 'FDLintError'
      call matchdelete(s:matchId['id'])
    endif
  endfor
  let b:matched = []
  let b:matchedlines = {}
  let b:cleared = 1
endfunction

function! s:show_fdlint_results()
    for error in split(b:fdlint_output, "\n")
        " Match
        " {file}:[{type}]:{row},{column}:{message}
        " -:[error]:0,0:必须存在文档类型声明
        let b:parts = matchlist(error, '\v([^:]+):\[(warn|error|fatal)\]:(\d+),(\d+):(.*)')
        if !empty(b:parts)
            let l:errorType = b:parts[2]
            let l:line = b:parts[3] + (b:firstline - 1) " Get line relative to selection
            let l:errorMessage = b:parts[5]

            " Store the error for an error under the cursor
            let s:matchDict = {}
            let s:matchDict['lineNum'] = l:line
            let s:matchDict['message'] = l:errorType . ':' . l:errorMessage
            let b:matchedlines[l:line] = s:matchDict

            if g:FDLintHighlightErrorLine == 1
                let s:mID = matchadd('FDLintError', '\v%' . l:line . 'l\S.*(\S|$)')
            endif

            " Add line to match list
            call add(b:matched, s:matchDict)

            " Store the error for the quickfix window
            let l:qf_item = {}
            let l:qf_item.bufnr = bufnr('%')
            let l:qf_item.filename = expand('%')
            let l:qf_item.lnum = l:line
            let l:qf_item.text = l:errorMessage
            let l:qf_item.type = l:errorType

            " Add line to quickfix list
            call add(b:qf_list, l:qf_item)
        endif
    endfor

    if exists("s:fdlint_qf")
        " if fdlint quickfix window is already created, reuse it
        call s:ActivateFDLintQuickFixWindow()
        call setqflist(b:qf_list, 'r')
    else
        " one fdlint quickfix window for all buffers
        call setqflist(b:qf_list, '')
        let s:fdlint_qf = s:GetQuickFixStackCount()
    endif

endfunction

function! g:show_fdlint_hint()
    let s:cursorPos = getpos(".")

    " Bail if RunFDLint hasn't been called yet
    if !exists('b:matchedlines')
        return
    endif

    if !exists('b:showing_message')
        let b:showing_message = 0
    end

    if has_key(b:matchedlines, s:cursorPos[1])
        let s:fdlintMatch = get(b:matchedlines, s:cursorPos[1])
        call s:WideMsg(s:fdlintMatch['message'])
        let b:showing_message = 1
        return
    endif

    if b:showing_message == 1
        echo
        let b:showing_message = 0
    endif
endfunction

" WideMsg() prints [long] message up to (&columns-1) length
" guaranteed without "Press Enter" prompt.
if !exists("*s:WideMsg")
  function s:WideMsg(msg)
    let x=&ruler | let y=&showcmd
    set noruler noshowcmd
    redraw
    echo a:msg
    let &ruler=x | let &showcmd=y
  endfun
endif

if !exists("*s:GetQuickFixStackCount")
    function s:GetQuickFixStackCount()
        let l:stack_count = 0
        try
            silent colder 9
        catch /E380:/
        endtry

        try
            for i in range(9)
                silent cnewer
                let l:stack_count = l:stack_count + 1
            endfor
        catch /E381:/
            return l:stack_count
        endtry
    endfunction
endif

if !exists("*s:ActivateFDLintQuickFixWindow")
    function s:ActivateFDLintQuickFixWindow()
        try
            silent colder 9 " go to the bottom of quickfix stack
        catch /E380:/
        endtry

        if s:fdlint_qf > 0
            try
                exe "silent cnewer " . s:fdlint_qf
            catch /E381:/
                echoerr "Could not activate FDLint Quickfix Window."
            endtry
        endif
    endfunction
endif

command! -nargs=? FDLint call g:fdlint(<f-args>)
nnoremap <silent> <leader>ft dd:FDLintToggle<CR>
nnoremap <silent> <leader>fd :FDLintUpdate<CR>

