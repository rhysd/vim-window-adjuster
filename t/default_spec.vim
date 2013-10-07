runtime autoload/window_adjuster.vim

describe 'default setting'
    it 'provides functions to adjust'
        Expect exists('*window_adjuster#adjust_window_width') to_be_true
        Expect exists('*window_adjuster#adjust_screen_width') to_be_true
        Expect exists('*window_adjuster#adjust_window_height') to_be_true
        Expect exists('*window_adjuster#adjust_screen_height') to_be_true
    end
end
