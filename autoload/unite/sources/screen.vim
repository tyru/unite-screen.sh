let s:source = {
\   'name': 'screen',
\ }

function! s:source.gather_candidates(args, context)
    " Parse screen output.
    let out = system('screen -Q windows')
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

    return map(windows, '{
    \   "word": v:val[0].v:val[1]." ".v:val[2],
    \   "kind": "command",
    \   "action__command": "execute \"silent !screen -X select ".v:val[0]."\" | qa!",
    \ }')
endfunction

function! unite#sources#screen#define()
    return s:source
endfunction
