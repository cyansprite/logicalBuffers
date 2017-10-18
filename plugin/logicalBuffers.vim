" Global Vars {{{1
if !has_key(g:,"logical_buffer_use_default")
    let g:logical_buffer_use_default = 1
endif

if !has_key(g:,"logical_buffer_override_stupid_tabline")
    let g:logical_buffer_override_stupid_tabline = 1
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

if !has_key(g:,"logical_buffer_sep")
    let g:logical_buffer_sep = '|'
endif

if !has_key(g:,"logical_center_use_buffers")
    let g:logical_center_use_buffers = 1
endif

if !has_key(g:,"logical_center_use_args")
    let g:logical_center_use_args = 0
endif

if !hlexists( 'LogicalBuffer' )
    hi LogicalBuffer ctermfg=none ctermbg=none cterm=bold,inverse
endif

if !hlexists( 'logicalmodified' )
    hi logicalmodified ctermfg=2 ctermbg=none cterm=bold
endif

if !hlexists( 'logicalreadonly' )
    hi logicalreadonly ctermfg=1 ctermbg=none cterm=bold
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
    return  (a:buf.hidden && g:logical_buffer_ignore_hidden) ||
          \ (getbufvar(a:buf.bufnr, "&buftype" != "") && g:logical_buffer_ignore_weird)
endfunc
" If we are cycling we don't want to pick something already in a window...
function! s:keepGoingMove(buf)
    return (!empty(a:buf.windows) && g:logical_buffer_ignore_windowed) ||
          \ bufnr('') == a:buf.bufnr ||
          \ s:keepGoing(a:buf)
endfunc

" Get buff that isn't already displayed in a window and isn't unlisted {{{1
function! s:GetNextBuffer()
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
    if l:firstbuf != 0
        exec "buffer". firstbuf
    endif
endfunction

function! s:GetPrevBuffer()
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
    if l:firstbuf != 0
        exec "buffer". firstbuf
    endif
endfunction

" Tabline Fuck off {{{1
function! logicalBuffers#TablineOverride()
    " Vars {{{2
    let s:thebuffer = ''
    let curbufname = ''
    let leftbufferlist = []
    let rightbufferlist = []
    let leftfilebufferlist = []
    let rightfilebufferlist = []
    let goright = 0

    " Get the list we care about {{{2
    if g:logical_center_use_buffers
        for buf in getbufinfo({'buflisted': 1})
            if s:keepGoing(buf)
                continue
            endif

            let bufname     = bufname(buf.bufnr)
            let amicur      = buf.bufnr == bufnr('')
            let s = ""
            let bufexpander = ''
            let needspaces = 0

            if g:logical_buffer_list_number
                let s .= string(buf.bufnr) . ':'
                let bufexpander .= '  '
            endif

            let s .= (l:bufname != '' ? ''. fnamemodify(l:bufname, ':t') . '' : '[No Name] ')
            let bufname = l:s

            " If it has a window surround with |
            if !empty(buf.windows)
                let s = '|' . s . '|'
                let bufexpander .= ' '
            endif

            " If it's alternate surround with ^
            if bufnr('#') == buf.bufnr
                let s = '^' . s . '^'
                let bufexpander .= ' '
            endif
            let l:needspaces = 1

            " If it's current arg surround with []
            " if argv(argidx()) == bufname(buf.bufnr)
            "     let s = ' [' . s . '] '
            "     let bufexpander .= ' '
            " else
            "     let l:needspaces = 1
            " endif

            if l:needspaces
                let s = ' ' . s . ' '
                let bufexpander .= ' '
            endif

            " If it's modified but a green +
            if getbufvar(buf.bufnr, "&mod")
                let s .= '%#LogicalModified#[+]'
                let bufexpander .= '   '
            endif

            " If it's read-only but a red RO
            if getbufvar(buf.bufnr, "&ro")
                let s .= '%#LogicalReadOnly#[RO]'
                let bufexpander .= '    '
            endif

            " If it's not modifiable put a red -
            if !getbufvar(buf.bufnr, "&ma")
                let s .= '%#LogicalReadOnly#[-]'
                let bufexpander .= '   '
            endif
            let bufname .= bufexpander

            " Which list to put buffers in
            if l:amicur
                let goright=1
                let s:thebuffer = l:s
                let l:curbufname = l:bufname
            else
                if l:goright
                    call add(rightbufferlist, l:s)
                    call add(rightfilebufferlist, l:bufname)
                else
                    call add(leftbufferlist , l:s)
                    call add(leftfilebufferlist , l:bufname)
                endif
            endif
        endfor
    " Arg list
    elseif g:logical_center_use_args
        let l:rightidx   = argidx() + 1
        let l:leftidx    = argidx() - 1
        let s:thebuffer  = ' [ ' . argv(argidx()) . ' ] '
        let l:curbufname = s:thebuffer

        while l:rightidx < argc() || l:leftidx > 0
            if l:leftidx > 0
                call add(leftbufferlist, ' ' . argv(l:leftidx) . ' ')
                call add(leftfilebufferlist, ' ' . argv(l:leftidx) . ' ')
                let l:leftidx  -= 1
            endif

            if l:rightidx < argc()
                call add(rightbufferlist , ' ' . argv(l:rightidx) . ' ')
                call add(rightfilebufferlist , ' ' . argv(l:rightidx) . ' ')
                let l:rightidx += 1
            endif
        endwhile
    endif


    " Colorize and limit {{{2
    let consume = &columns
    let consume -= len(l:curbufname)

    let l:leftidx = len(leftbufferlist) - 1
    let l:rightidx = 0
    let l:leftfailed = 0
    let l:rightfailed = 0

    let s:Lfinal = []
    let s:Rfinal = []

    while 1
        if leftfailed && rightfailed
            break
        endif

        if !leftfailed
            if l:leftidx < 0
                let l:leftfailed = 1
            else
                let l = leftbufferlist[l:leftidx]
                let la = leftfilebufferlist[l:leftidx]
                let llen = len(l:la)
                if l:llen < l:consume
                    call insert(s:Lfinal,l:l)
                    let l:consume -= l:llen
                    let l:leftidx -= 1
                else
                    let l:leftfailed = 1
                endif
            endif
        endif

        if !rightfailed
            if l:rightidx >= len(rightbufferlist)
                let rightfailed = 1
            else
                let r = rightbufferlist[l:rightidx]
                let ra = rightfilebufferlist[l:rightidx]
                let rlen = len(l:ra)
                if l:rlen < l:consume
                    call add(s:Rfinal,l:r)
                    let l:consume -= l:rlen
                    let l:rightidx += 1
                else
                    let l:rightfailed = 1
                endif
            endif
        endif
    endwhile

    let s = ''

    " Putting finishing touches {{{2
    " Left of
    let tempidx = len(s:Lfinal) - 1
    for l in s:Lfinal
        let s  .= '%#Logical'. l:tempidx . '#' . l
        let tempidx -= 1
    endfor
    let s .= '%4*%='

    " The current
    let s .= '%#LogicalBuffer#'.s:thebuffer .'%4*%='

    " Right of
    let tempidx = 0
    for r in s:Rfinal
        let s  .= '%#Logical'. l:tempidx . '#' . r
        let tempidx += 1
    endfor

    return s
endfunc "}}}2
" Better LS
func! logicalBuffers#LS()
    call s:echo(0)
    echohl NONE
endfunc

func! logicalBuffers#Kill()
    call s:echo(1)
    echohl NONE
endfunc

func! s:echo(op)
    echohl Title
    echom "Buffers"
    echom repeat("=", winwidth(".") - 10)
    echohl NONE
    echom ""
    let all = s:Lfinal
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

    let all = s:Rfinal
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
    let answer = input("Buffer To Choose (ctrl-c cancels) >>> ")
    echohl None


    try
        if a:op == 0
            exec 'b'.l:answer
        else
            exec 'bw'.l:answer
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
nnoremap <Plug>(Logic-Next) :update \| call <SID>GetNextBuffer()<cr>
nnoremap <Plug>(Logic-Prev) :update \| call <SID>GetPrevBuffer()<cr>

if g:logical_buffer_use_default
    nmap <silent><m-n> <Plug>(Logic-Next)
    nmap <silent><m-N> <Plug>(Logic-Prev)
endif

if g:logical_buffer_override_stupid_tabline
    set stal=2
    set tabline=%!logicalBuffers#TablineOverride()
endif
