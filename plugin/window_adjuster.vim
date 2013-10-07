if exists('g:loaded_window_adjuster')
    finish
endif

command! -nargs=* AdjustWindowWidth call window_adjuster#_cli_adjust_width('window', <f-args>)
command! -nargs=* AdjustScreenWidth call window_adjuster#_cli_adjust_width('screen', <f-args>)
command! -nargs=? AdjustWindowHeight call window_adjuster#_cli_adjust_height('window', <f-args>)
command! -nargs=? AdjustScreenHeight call window_adjuster#_cli_adjust_height('screen', <f-args>)

let g:loaded_window_adjuster = 1
