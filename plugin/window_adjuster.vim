if exists('g:loaded_window_adjuster')
    finish
endif

command! -nargs=* AdjustWindowWidth call window_adjuster#_cli_adjust_width('window', <f-args>)
command! -nargs=* AdjustScreenWidth call window_adjuster#_cli_adjust_width('screen', <f-args>)


let g:loaded_window_adjuster = 1
