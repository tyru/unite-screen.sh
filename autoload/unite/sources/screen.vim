let s:source = {
\   'name': 'screen',
\ }

function! s:source.gather_candidates(args, context)
    return map(s:get_window_list(), '{
    \   "word": v:val[0].v:val[1]." ".v:val[2],
    \   "kind": "command",
    \   "action__command": "execute \"silent !screen -X select ".v:val[0]."\" | qa!",
    \ }')
endfunction

function! s:get_window_list()
    if $WINDOW != ''    " screen is running
        return s:get_screen_window_list()
    elseif $TMUX != ''    " tmux is running
        " TODO
        " return s:get_tmux_window_list()
        return []
    else
        throw "error: screen nor tmux is running."
    endif
endfunction

function! s:get_screen_window_list()
    " Parse screen output.

    " NOTE: ./unite-screen called 'screen -X windows' before.
    let out = system('screen -Q "@lastmsg"')
    let windows = []
    let re = '\(\d\+\)\([*-]\?\) \(.\{-1,}\)\%(  \|$\)'
    while out != ''
        let m = matchlist(out, re)
        if empty(m)
            throw 'error: parse screen output failed.'
        endif
        let out = out[matchend(out, re) :]
        " [number, current, name]
        if m[2] !=# '*' || $OPT_ALL ==# 'true'
            call add(windows, [m[1], m[2], m[3]])
        endif
    endwhile

    return windows
endfunction

function! unite#sources#screen#define()
    return s:source
endfunction
