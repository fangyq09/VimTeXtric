if exists('b:tex_misc')
	finish
endif

let b:tex_misc = 1

set cc=79
set ambiwidth=double
"set timeout
"set timeoutlen=300
"set notimeout
set nottimeout
set noshowmatch
set wrap 
set textwidth=78
if has("win32") || has("win64")
	set shellslash
endif 
nnoremap ( <Nop>
nnoremap ) <Nop>
nnoremap { <Nop>
nnoremap } <Nop>
nnoremap [ <Nop>
nnoremap ] <Nop>
nnoremap [[ <Nop>
nnoremap ]] <Nop>
nnoremap [( <Nop>
nnoremap ]) <Nop>
nnoremap [] <Nop>
nnoremap ][ <Nop>
"
function! s:TeX_Jump(mode,bf,...)
	if a:mode == 'par'
		if a:bf == 'b'
			let searpos = search('^\s*$','bsW')
		elseif a:bf == 'f'
			let searpos = search('^\s*$','sW')
		endif
	elseif a:mode == 'env'
		if a:bf == 'b'
				let searpos = search('^\s*\\\(begin\|\[\)','bsW')
		elseif a:bf == 'f'
				let searpos = search('^\s*\\\(end\|\]\)','sW')
		endif
	endif
	return searpos
endfunction

function! s:TeX_Paragraph_Filter(mode)
	let save_pos = getpos(".")
	if a:mode == 'para'
		let next_space = search('^\s*\($\|\\chapter\|\\\(\sub\)*section\|\\bib\)','cnW')
		let pre_space = search('^\s*\($\|\\chapter\|\\\(\sub\)*section\|\\begin{document}\)','cbnW')
	elseif a:mode == 'env'
		let next_space = search('^\s*\($\|\\\(\[\|\]\|end\|begin\)\)','cnW')
		let pre_space = search('^\s*\($\|\\\(\[\|\]\|end\|begin\)\)','cbnW')
	endif
	let lnum = next_space - pre_space + 1
	exec "normal ".lnum."=="
	call setpos('.',save_pos)
endfunction

function! s:TeX_Syntax_Recover()
	let save_pos = getpos(".")
	let syn_start_pos = search('^\s*\($\|\\\(\[\|\]\|end\|begin\|chapter\|\(sub\)*section\)\)','bcnW')
	let Delta = save_pos[1] - syn_start_pos 
	exec 'syntax sync minlines='.Delta
	echo ':syntax sync minlines='.Delta
	return ''
endfunction


nnoremap <silent><buffer> {
			\ :call <SID>TeX_Jump('par','b')<cr>
nnoremap <silent><buffer> }
			\ :call <SID>TeX_Jump('par','f')<cr>
nnoremap <silent><buffer> [[
			\ :call <SID>TeX_Jump('env','b')<cr>
nnoremap <silent><buffer> ]]
			\ :call <SID>TeX_Jump('env','f')<cr>
nnoremap <silent><buffer> =p
			\ :call <SID>TeX_Paragraph_Filter('para')<cr>
nnoremap <silent><buffer> =e
			\ :call <SID>TeX_Paragraph_Filter('env')<cr>

"nnoremap <F12> <Esc>:syntax sync fromstart<CR>
nnoremap <silent><buffer><F12> <Esc>:call <SID>TeX_Syntax_Recover()<CR>
