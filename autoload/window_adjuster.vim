function! window_adjuster#adjust_window_width()
    let max_col = 0
    for lnum in range(1, line('$'))
        let len = len(getline(lnum))
        if max_col < len
            let max_col = len
        endif
    endfor

    " add line number width
    if &number
        let digit = 1
        let l = line('$')
        while l > 10
            let digit += 1
            let l = l / 10
        endwhile
        let max_col += digit + 2
    endif

    " add sign width
    redir => this_buffer_sign
        silent execute 'sign place buffer='.bufnr('%')
    redir END
    if this_buffer_sign !~# '^\n--- Signs ---\n$'
        let max_col += 2
    endif

    if max_col < winwidth(0)
        execute 'vertical resize' max_col
        echo 'width: '.max_col
    endif
endfunction
