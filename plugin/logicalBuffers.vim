if !has_key(g:,"logical_buffer_use_default")
    let g:logical_buffer_use_default = 1
endif

" Get buff that isn't already displayed in a window and isn't unlisted
function! s:GetNextBuffer()
    let l:curbuf = bufnr("")
    let l:newbuf = 0
    let l:firstbuf = 0
    for buf in getbufinfo({'buflisted': 1})
        if !empty(buf.windows) || l:curbuf == buf.bufnr || buf.hidden
            continue
        endif

        if l:firstbuf == 0
            let l:firstbuf = buf.bufnr
        endif

        if l:curbuf > buf.bufnr
            let l:newbuf = buf.bufnr
            continue
        else
            exec "buffer". buf.bufnr
            return
        endif
    endfor
    if l:firstbuf != 0
        exec "buffer". firstbuf
    endif
endfunction

function! s:GetPrevBuffer()
    let l:curbuf = bufnr("")
    let l:newbuf = 0
    let l:firstbuf = 0
    for buf in reverse(getbufinfo({'buflisted': 1}))
        if !empty(buf.windows) || l:curbuf == buf.bufnr || buf.hidden
            continue
        endif

        if l:firstbuf == 0
            let l:firstbuf = buf.bufnr
        endif

        if l:curbuf < buf.bufnr
            let l:newbuf = buf.bufnr
            continue
        else
            exec "buffer". buf.bufnr
            return
        endif
    endfor
    if l:firstbuf != 0
        exec "buffer". firstbuf
    endif
endfunction

nnoremap <Plug>(Logic-Next) :call <SID>GetNextBuffer()<cr>
nnoremap <Plug>(Logic-Prev) :call <SID>GetPrevBuffer()<cr>

if g:logical_buffer_use_default
    nmap <silent><m-n> <Plug>(Logic-Next)
    nmap <silent><m-N> <Plug>(Logic-Prev)
endif

