let s:source = {
\   'name': 'screen',
\ }

function! s:source.gather_candidates(args, context)
    if s:is_screen_running()
        let windows = s:get_screen_window_list()
        let fmt = 'execute "silent !screen -X select %d" | qa!'
    elseif s:is_tmux_running()
        let windows = s:get_tmux_window_list()
        let fmt = 'execute "silent !tmux select-window -t %d" | qa!'
    else
        throw "error: screen nor tmux is running."
    endif

    return map(windows, '{
    \   "word": v:val.nr . v:val.active ." ". v:val.name,
    \   "kind": "command",
    \   "action__command": printf(fmt, v:val.nr),
    \ }')
endfunction

function! s:is_screen_running()
    return $WINDOW != ''
endfunction

function! s:is_tmux_running()
    return $TMUX != ''
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
        if m[2] !=# '*' || $OPT_ALL ==# 'true'
            call add(windows, {
            \   'nr': m[1],
            \   'active': m[2],
            \   'name': m[3]
            \})
        endif
    endwhile

    return windows
endfunction

function! s:get_tmux_window_list()
    " Parse tmux output.

    let re = '\(\d\+\): \(.\{-1,}\)\([* -]\)'
    let windows = []
    for l in split(system('tmux list-windows'), '\n')
        let m = matchlist(l, re)
        if !empty(m) && (m[3] !=# '*' || $OPT_ALL ==# 'true')
            call add(windows, {
            \   'nr': m[1],
            \   'active': m[3],
            \   'name': m[2]
            \})
        endif
    endfor

    return windows
endfunction

function! unite#sources#screen#define()
    return s:source
endfunction
