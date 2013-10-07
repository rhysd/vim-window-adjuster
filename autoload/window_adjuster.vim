function! s:width_of_line_number_region()
    if ! &number
        return 0
    endif

    let l = line('$')
    if l < 1000
        return 4
    else
        let digit = 1
        while l > 10
            let digit += 1
            let l = l / 10
        endwhile
        return digit + 1
    endif
endfunction

function! s:width_of_signs_region()
    redir => this_buffer_sign
        silent execute 'sign place buffer='.bufnr('%')
    redir END
    return this_buffer_sign =~# '^\n--- Signs ---\n$' ? 0 : 2
endfunction

function! s:width_of_eol_chars()
    if &listchars !~# 'eol:'
        return 0
    endif

    let eol_chars = matchstr(split(&listchars, ','), '^eol:')

    " decrease the length for 'eol:'
    return len(eol_chars) - 4
endfunction

function! s:max_line_width(line1, line2)
    let max_col = 0
    for lnum in range(a:line1, a:line2)
        let len = len(getline(lnum))
        if max_col < len
            let max_col = len
        endif
    endfor

    let max_col += s:width_of_line_number_region()
    let max_col += s:width_of_signs_region()
    let max_col += s:width_of_eol_chars()

    return max_col
endfunction

function! s:adjust_width(line1, line2, right_mergin)

    let width = s:max_line_width(a:line1, a:line2) + a:right_mergin

    if width < winwidth(0)
        execute 'vertical resize' width
        if winwidth(0) == width
            echo 'width: '.width
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
