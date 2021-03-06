let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir

function! s:line(str, line)
    if a:line == 0
        call setline(1, a:str)
    else
        call setline(a:line, a:str)
    endif
endfunction

command! -nargs=+ -count=0 Line call <SID>line(<args>, <count>)

describe 'window_adjuster#adjust_window_width()'
    before
        enew
        vsplit
        set number
    end

    after
        bdelete!
    end

    it 'adjusts current window'
        Line "hoge"
        call window_adjuster#adjust_window_width()
        Expect winwidth(0) == 9
        vertical resize 20
        call window_adjuster#adjust_window_width(3)
        Expect winwidth(0) == 12
        call window_adjuster#adjust_window_width(0, 'shrink', 2)
        Expect winwidth(2) == 5
    end

    it 'adjusts current window even if multibyte characters are included'
        Line "びむbeem"
        call window_adjuster#adjust_window_width()
        Expect winwidth(0) == 13
        call window_adjuster#adjust_window_width(0, 'expand-or-shrink', 2)
        Expect winwidth(2) == 13
        call window_adjuster#adjust_window_width(3)
        Expect winwidth(0) == 16
    end
end
