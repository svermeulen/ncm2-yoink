
if get(s:, 'loaded', 0)
    finish
endif
let s:loaded = 1

call ncm2_yoink#init()

