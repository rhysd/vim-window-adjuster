" utility {{{
function! s:parse_options(args)
    let ret = {}
    for arg in filter(copy(a:args), "v:val =~# '^--\\k\\+=.\\+$'")
        let [name, value] = matchlist(arg, '^--\(\k\+\)=\(.\+\)$')[1:2]
        let ret[name] = value =~# '^\d\+$' ? str2nr(value) : value
    endfor
    return ret
endfunction

function! s:pop(str)
    return [matchstr(a:str, '^.'), matchstr(a:str, '^.\zs.*$')]
endfunction

function! s:is_multibyte_char(c)
    return len(a:c) > 1
endfunction

function! s:strdisplaywidth(s)
    if exists('*strdisplaywidth')
        return strdisplaywidth(a:s)
    else
        if strchars(s) == strlen(s)
            return strlen(s)
        endif
        let str = a:s
        let len = 0
        while str != ''
            let [h, str] = s:pop(str)
            let len += s:is_multibyte_char(h) ? 2 : 1
        endwhile
        return len
    endif
endfunction
" }}}

" adjust width of window {{{
function! s:width_of_line_number_region()
    if ! &number
        return 0
    endif

    let line = line('$')
    return line < 1000 ? 4 : (float2nr(log(line) / log(10)) + 1) + 1
endfunction

function! s:width_of_signs_region()
    " XXX
    " Assumed that signs are characters (in terminal)
    " Is there a way to width of sign which is image?
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

function! s:max_col_of_current_window(line1, line2)
    let max_col = 0
    for lnum in range(a:line1, a:line2)
        let len = s:strdisplaywidth(getline(lnum))
        if max_col < len
            let max_col = len
        endif
    endfor
    return max_col
endfunction

function! s:adjust_current_window_width(line1, line2, right_margin)
    let width = s:max_col_of_current_window(a:line1, a:line2) + a:right_margin
    let width += s:width_of_line_number_region()
    let width += s:width_of_signs_region()
    let width += s:width_of_eol_chars()

    if width < winwidth(0)
        execute 'vertical resize' width
        if winwidth(0) == width
            echo 'width: '.width
        else
            echoerr 'can not change window width'
        endif
    endif
endfunction

function! s:adjust_window_width(line1, line2, opts)
    let opts_len = len(a:opts)
    if opts_len >= 2 | execute a:opts[1].'wincmd w' | endif
    call s:adjust_current_window_width(a:line1, a:line2, opts_len >= 1 ? a:opts[0] : 0)
    if opts_len >= 2 | wincmd p | endif
endfunction

" args: margin, winnr
function! window_adjuster#adjust_window_width(...)
    call s:adjust_window_width(1, line('$'), a:000)
endfunction

" args: margin, winnr
function! window_adjuster#adjust_screen_width(...)
    call s:adjust_window_width(line('w0'), line('w$'), a:000)
endfunction

function! window_adjuster#_cli_adjust_width(type, ...)
    let opts = s:parse_options(a:000)
    let args = []
    call add(args, get(opts, 'margin', 0))
    if has_key(opts, 'winnr')
        call add(args, opts.winnr)
    endif
    call call('window_adjuster#adjust_'.a:type.'_width', args)
endfunction
" }}}

" adjust height of window {{{
function! s:adjust_window_height(height, opts)
    if len(a:opts) == 1 | execute a:opts[0].'wincmd w' | endif
    if winheight(0) > a:height
        execute 'resize' a:height
        if winheight(0) == a:height
            echo 'height: '.a:height
        else
            echoerr 'can not change window height'
        endif
    endif
    if len(a:opts) == 1 | wincmd p | endif
endfunction

function! window_adjuster#adjust_window_height(...)
    call s:adjust_window_height(line('$'), a:000)
endfunction

function! window_adjuster#adjust_screen_height(...)
    call s:adjust_window_height(line('w$') - line('w0') + 1, a:000)
endfunction

function! window_adjuster#_cli_adjust_height(type, ...)
    let opts = s:parse_options(a:000)
    call call('window_adjuster#adjust_'.a:type.'_height', has_key(opts, 'winnr') ? [opts.winnr] : [])
endfunction
" }}}

" adjust width and height {{{
" XXX experimental
function! window_adjuster#adjust_window_both(...)
    silent! call call('window_adjuster#adjust_window_width', a:000)
    silent! call call('window_adjuster#adjust_window_height', a:000[1:])
endfunction

function! window_adjuster#adjust_screen_both(...)
    silent! call call('window_adjuster#adjust_screen_width', a:000)
    silent! call call('window_adjuster#adjust_screen_height', a:000)
endfunction
" }}}
