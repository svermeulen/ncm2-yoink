if get(s:, 'loaded', 0)
    finish
endif
let s:loaded = 1

let s:listDirty = 1
let s:yankList = []

let g:ncm2_yoink_source = extend(get(g:, 'ncm2_yoink_source', {}), {
    \ 'name': 'yoink',
    \ 'ready': 0,
    \ 'priority': 5,
    \ 'mark': 'yoink',
    \ 'on_complete': 'ncm2_yoink#on_complete',
    \ }, 'keep')

func! s:onYoinkHistoryChanged()
    let s:listDirty = 1
endfunc

func! s:updateYankList()
    if len(s:yankList) > 0
        call remove(s:yankList, 0, -1)
    endif

    for entry in yoink#getYankHistory()
        let newLinePos = stridx(entry.text, "\n")

        if newLinePos == -1
            let firstLine = entry.text
        else
            let firstLine = strpart(entry.text, 0, newLinePos)
        endif

        " Trim whitespace
        let firstLine = substitute(firstLine, '^\s*\(.\{-}\)\s*$', '\1', '')

        call add(s:yankList, firstLine)
    endfor
endfunc

func! ncm2_yoink#on_complete(ctx)
    if s:listDirty
        let s:listDirty = 0
        call s:updateYankList()
    endif

    call ncm2#complete(a:ctx, a:ctx['startccol'], s:yankList, 0)
endfunc

func! ncm2_yoink#init()
    call ncm2#register_source(g:ncm2_yoink_source)
    call ncm2#set_ready(g:ncm2_yoink_source)
    call yoink#observeHistoryChangeEvent(function("s:onYoinkHistoryChanged"))
endfunc

