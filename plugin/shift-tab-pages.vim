" Avoid installing twice or when in unsupported Vim version.
if exists('g:shift_tab_pages_loaded') || (v:version < 701)
	finish
endif
let g:shift_tab_pages_loaded = 1

function! s:shiftOneTab()
	let [ nr, pos ] = s:bufferList[s:bufferIndex]

	exec "buffer ".nr
	call setpos(".", pos) " XXX - this doesn't seem to restore the cursor's column

	let s:bufferIndex = (s:bufferIndex + 1) % len(s:bufferList)
endfunction

function! s:dumpBuffer()
	let pos = getpos('.')
	let current_buffer = bufnr("%")
	let s:bufferList = s:bufferList + [ [ current_buffer , pos ] ]

endfunction

function! s:dumpBuffers()
	" dump the buffers state in a temporary window to avoid having to
	" save / restore the current context, as bufdo seems to be destructive...
	wincmd v
	wincmd w

	let s:bufferList = [ ]
	silent hide bufdo call s:dumpBuffer()

	wincmd c
endfunction

function! s:shiftTabPages(dir, len)
	set lazyredraw

	call s:dumpBuffers()

	if a:dir != "<" && a:dir != ">"
		" warn
		set nolazyredraw
		return
	endif

	let current_tab_page = tabpagenr()

	" determine the buffer being edited in the first tab, it will be our
	" starting index
	tabrewind

	let current_buffer = bufnr('%')

	let s:bufferIndex = -1

	let i = 0
	while i < len(s:bufferList)
		let [nr, pos] = s:bufferList[i]
		if (nr == current_buffer)
			let s:bufferIndex = i
			break
		endif
		let i = i + 1
	endwhile

	if s:bufferIndex == -1
		echo "can not locate current tab"
		set nolazyredraw
		return
	endif

	if a:dir == ">"
		let s:bufferIndex = s:bufferIndex - 1
		if s:bufferIndex < 0
			let s:bufferIndex = len(s:bufferList) - 1
		endif
	else a:dir == "<"
		let s:bufferIndex = (s:bufferIndex + 1) % len(s:bufferList)
	endif

	silent hide tabdo call s:shiftOneTab()

	exec "tabn ".current_tab_page

	set nolazyredraw
endfunction

function! g:ShiftTabPages_Left()
	call s:shiftTabPages("<", 1)
endfunction

function! g:ShiftTabPages_Right()
	call s:shiftTabPages(">", 1)
endfunction
