" Global {{{1
" Vars {{{2
if !has_key(g:,"logical_buffer_use_default")
    let g:logical_buffer_use_default = 1
endif

if !has_key(g:,"logical_buffer_ignore_hidden")
    let g:logical_buffer_ignore_hidden = 1
endif

if !has_key(g:,"logical_buffer_ignore_weird")
    let g:logical_buffer_ignore_weird = 1
endif

if !has_key(g:,"logical_buffer_ignore_windowed")
    let g:logical_buffer_ignore_windowed = 1
endif

if !has_key(g:,"logical_buffer_list_number")
    let g:logical_buffer_list_number = 1
endif

if !has_key(g:,"logical_buffer_wrap_around")
    let g:logical_buffer_wrap_around = 0
endif

" Highlight {{{2
if !hlexists( 'LogicalBuffer' )
    hi LogicalBuffer ctermfg=none ctermbg=none cterm=bold,inverse
endif

if !hlexists( 'logical0' )
    hi logical0 ctermfg=6 ctermbg=0 cterm=bold
endif

if !hlexists( 'logical1' )
    hi logical1 ctermfg=5 ctermbg=0 cterm=bold
endif

if !hlexists( 'logical2' )
    hi logical2 ctermfg=4 ctermbg=0 cterm=bold
endif

if !hlexists( 'logical3' )
    hi logical3 ctermfg=3 ctermbg=0 cterm=bold
endif

if !hlexists( 'logical4' )
    hi logical4 ctermfg=2 ctermbg=0 cterm=bold
endif

if !hlexists( 'logical5' )
    hi logical5 ctermfg=1 ctermbg=0 cterm=bold
endif

if !hlexists( 'logical6' )
    hi logical6 ctermfg=1 ctermbg=0 cterm=none
endif

if !hlexists( 'logical7' )
    hi logical7 ctermfg=2 ctermbg=0 cterm=none
endif

if !hlexists( 'logical8' )
    hi logical8 ctermfg=3 ctermbg=0 cterm=none
endif

if !hlexists( 'logical9' )
    hi logical9 ctermfg=4 ctermbg=0 cterm=none
endif

if !hlexists( 'logical10' )
    hi logical10 ctermfg=5 ctermbg=0 cterm=none
endif

if !hlexists( 'logical11' )
    hi logical11 ctermfg=6 ctermbg=0 cterm=none
endif

" Help me!! {{{1
function! s:keepGoing(buf)
    echom 
    return  (a:buf.hidden && g:logical_buffer_ignore_hidden) ||
          \ (getbufvar(a:buf.bufnr, "&buftype") != "" && g:logical_buffer_ignore_weird)
endfunc
" If we are cycling we don't want to pick something already in a window...
function! s:keepGoingMove(buf)
    return (!empty(a:buf.windows) && g:logical_buffer_ignore_windowed) ||
          \ bufnr('') == a:buf.bufnr ||
          \ s:keepGoing(a:buf)
endfunc

function! s:contains(string, char)
    return count(split(a:string), a:char)
endfunction

" Get buff that isn't already displayed in a window and isn't unlisted {{{1
function! s:GetNextBuffer() "{{{2
    let l:newbuf = 0
    let l:firstbuf = 0
    for buf in getbufinfo({'buflisted': 1})
        if s:keepGoingMove(buf)
            continue
        endif

        if l:firstbuf == 0
            let l:firstbuf = buf.bufnr
        endif

        if bufnr('') > buf.bufnr
            let l:newbuf = buf.bufnr
            continue
        else
            exec "buffer". buf.bufnr
            return
        endif
    endfor
    if g:logical_buffer_wrap_around && l:firstbuf != 0
        exec "buffer". firstbuf
    endif
endfunction

function! s:GetPrevBuffer() "{{{2
    let l:newbuf = 0
    let l:firstbuf = 0
    for buf in reverse(getbufinfo({'buflisted': 1}))
        if s:keepGoingMove(buf)
            continue
        endif

        if l:firstbuf == 0
            let l:firstbuf = buf.bufnr
        endif

        if bufnr('') < buf.bufnr
            let l:newbuf = buf.bufnr
            continue
        else
            exec "buffer". buf.bufnr
            return
        endif
    endfor
    if g:logical_buffer_wrap_around && l:firstbuf != 0
        exec "buffer". firstbuf
    endif
endfunction

function! s:getBuffers(param, bang) "{{{1
    " Vars {{{2
    let s:thebuffer = ''
    let curbufname = ''
    let s:leftbufferlist = []
    let s:rightbufferlist = []
    let goright = 0
    let s:biggest = len(string(bufnr('$')))

    " Get the list we care about {{{2
    for buf in getbufinfo()
        let bufname     = bufname(buf.bufnr)
        let amicur      = buf.bufnr == bufnr('')
        let s = ""
        let needspaces = 2

        let s .= (l:bufname != '' ? ''. fnamemodify(l:bufname, ':t') . '' : '[No Name] ')
        let bufname = l:s

        if l:amicur
            let needspaces = needspaces - 1
            let s = '%   ' . s
        endif

        if buf.hidden
            if !s:contains(a:param, 'h')
                continue
            endif
            let needspaces = needspaces - 1
            let s = 'h   ' . s
        else
            if s:contains(a:param, 'h')
                continue
            endif
        endif

        if buf.listed
            if s:contains(a:param, 'u')
                continue
            endif
        else
            if !s:contains(a:param, 'u') && !a:bang
                continue
            endif
            let needspaces = needspaces - 1
            let s = 'u   ' . s
        endif

        " If it's alternate lead with ^
        if bufnr('#') == buf.bufnr
            let s = '#   ' . s
            let needspaces = needspaces - 1
        elseif s:contains(a:param,'#')
            continue
        endif

        " If it has a window surround with |
        if !empty(buf.windows)
            let s = '|   ' . s
            let needspaces = needspaces - 1
        elseif s:contains(a:param,'a')
            continue
        endif

        if needspaces
            let s = repeat('    ', needspaces) . s
        endif

        let bigger = len(string(buf.bufnr))
        if s:biggest > bigger
            let s = repeat(' ',s:biggest - bigger) . s
        endif

        " add number at very beginning
        if g:logical_buffer_list_number
            let s = string(buf.bufnr) . ': ' . s
        endif

        " If it's modified but a green +
        if getbufvar(buf.bufnr, "&mod")
            let s .= '[+]'
        elseif s:contains(a:param,'+')
            continue
        endif

        " If it's read-only put a red RO
        if getbufvar(buf.bufnr, "&ro")
            let s .= '[RO]'
        elseif s:contains(a:param,'=')
            continue
        endif

        " If it's not modifiable put a red -
        if !getbufvar(buf.bufnr, "&ma")
            let s .= '[-]'
        elseif s:contains(a:param,'-')
            continue
        endif

        " Which list to put buffers in
        if l:amicur
            let goright=1
            let s:thebuffer = "" . l:s . repeat(" ", &columns - len(l:s) - 10)
            let l:curbufname = l:bufname
        elseif s:contains(a:param,'%')
            continue
        else
            if l:goright
                call add(s:rightbufferlist, l:s)
            else
                call add(s:leftbufferlist , l:s)
            endif
        endif
    endfor

    return ''
endfunc "}}}2
" Better LS {{{1
func! logicalBuffers#LS(param, bang)
    call s:echo(0, a:param, a:bang)
    echohl NONE
endfunc

func! logicalBuffers#Kill(param, bang)
    call s:echo(1, a:param, a:bang)
    echohl NONE
endfunc

func! s:echo(op, param, bang)
    call s:getBuffers(a:param, a:bang)
    echohl Title
    echom "Buffers"
    echom repeat("=", &columns - 10)
    echohl NONE
    echom ""
    let all = s:leftbufferlist
    let ind = len(l:all) - 1
    for x in l:all
        exec 'echohl Logical' . l:ind
        echom x
        echohl NONE
        echom ''
        let ind -= 1
    endfor

    echohl LogicalBuffer
    echom s:thebuffer
    echohl NONE

    let all = s:rightbufferlist
    let l:ind = 0
    for x in l:all
        exec 'echohl Logical' . l:ind
        echom x
        echohl NONE
        echom ''
        let ind += 1
    endfor
    echom ""
    echom ""
    echohl Question
    let answer = input(( a:op == 0 ? "Switch to" : "Kill" ) ."(# or name) >>> ", "", "buffer")
    echohl None

    try
        let space = ''
        if len(l:answer) > s:biggest
            let space = ' '
        endif
        if a:op == 0
            exec 'b'.l:space.l:answer
        else
            exec 'bw'.l:space.l:answer
        endif
    catch
        echom ''
        echom ''
        echohl ErrorMsg
        echom "You need it to be a buffer that exists!!"
        echohl NONE
    endtry
endfun

" The end (Mappings and shit) {{{1
nnoremap <Plug>(Logic-Next) :call <SID>GetNextBuffer()<cr>
nnoremap <Plug>(Logic-Prev) :call <SID>GetPrevBuffer()<cr>
command! -bang -nargs=* LS call logicalBuffers#LS('<args>' . '', '<bang>' == '!')
command! -bang -nargs=* KILL call logicalBuffers#KILL('<args>'. '', '<bang>' == '!')

if g:logical_buffer_use_default
    nmap <silent><m-n> <Plug>(Logic-Next)
    nmap <silent><m-N> <Plug>(Logic-Prev)
    nmap <silent><leader>b :LS<cr>
    nmap <silent><leader>k :KILL<cr>
endif
