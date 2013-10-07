function! s:adjust_width(line1, line2, right_mergin)
    let max_col = 0
    for lnum in range(a:line1, a:line2)
        let len = len(getline(lnum))
        if max_col < len
            let max_col = len
        endif
    endfor

    " add line number width
    if &number
        let l = line('$')
        if l < 1000
            let max_col += 4
        else
            let digit = 1
            while l > 10
                let digit += 1
                let l = l / 10
            endwhile
            let max_col += digit + 1
        endif
    endif

    " add sign width
    redir => this_buffer_sign
        silent execute 'sign place buffer='.bufnr('%')
    redir END
    if this_buffer_sign !~# '^\n--- Signs ---\n$'
        let max_col += 2
    endif

    let max_col += a:right_mergin

    if max_col < winwidth(0)
        execute 'vertical resize' max_col
        if winwidth(0) == max_col
            echo 'width: '.max_col
        else
            echoerr 'can not change window width'
        endif
    endif
endfunction

function! s:adjust_width_in(line1, line2, ...)
    if a:0 >= 2 | execute a:2.'wincmd w' | endif
    call s:adjust_width(a:line1, a:line2, a:0 >= 1 ? a:1 : 0)
    if a:0 >= 2 | wincmd p | endif
endfunction

function! window_adjuster#adjust_window_width(...)
    call call('s:adjust_width_in', [1, line('$')] + a:000)
endfunction

function! window_adjuster#adjust_screen_width(...)
    call call('s:adjust_width_in', [line('w0'), line('w$')] + a:000)
endfunction
