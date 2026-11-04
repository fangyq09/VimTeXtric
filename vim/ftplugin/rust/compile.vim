" Vim plugin: Rust run with F2
if exists('b:rust_misc')
	finish
endif
let b:rust_misc = 1

let b:cargo_prog = expand('~/.cargo/bin/cargo')
let s:rust_build_buf = -1
let s:rust_build_status = -1

" Find project root by searching upward for Cargo.toml
function! s:FindProjectRoot()
	let l:dir = expand('%:p:h')
	while l:dir !=# '/'
		if filereadable(l:dir . '/Cargo.toml')
			return l:dir
		endif
		let l:dir = fnamemodify(l:dir, ':h')
	endwhile
	return ''
endfunction

" Handler for stdout lines: append as quickfix items
let b:rust_efm = '%-G\s%#,%-G,' .
			\ '%-Gerror:\ aborting\ %.%#,' .
			\ '%-Gerror:\ Could\ not\ compile\ %.%#,' .
			\ '%-Gwarning:\ %m\ generated\ %*\d\ warning%#,' .
			\ '%Eerror:\ %m,' .
			\ '%Eerror[E%n]:\ %m,' .
			\ '%Wwarning:\ %m,' .
			\ '%Inote:\ %m,' .
			\ '%C\ %#-->\ %f:%l:%c,' .
			\ '%+C\ %#|%m,' .
			\ '%-G%.%#'
function! s:OnStdout(job_id, data, ...)
	if has("nvim")
		call setqflist([], 'a', {'lines': a:data,'efm': b:rust_efm})
	else
		call setqflist([], 'a', {'lines': [a:data],'efm': b:rust_efm})
	endif
endfunction

" On exit: if quickfix has items open it
function! s:OnExit(...)
	if !empty(getqflist())
		copen 3
	else
		cclose
		echo "cargo run finished (no errors)"
	endif
endfunction

function! s:RustRun(type)
	let l:root = s:FindProjectRoot()
	if empty(l:root)
		echohl ErrorMsg | echo "No Cargo.toml be found!" | echohl None
		return
	endif

	""必须切换目录，否则错误转跳不正确
	execute 'silent! lcd ' . fnameescape(l:root)

	" Clear quickfix before starting
	call setqflist([])

	let l:cmd = ['/bin/sh', '-c', b:cargo_prog . ' ' . a:type]

	echo "Running cargo " . a:type . " in " . l:root

	if has('nvim')
		let l:opts = {
					\ 'cwd': l:root,
					\ 'on_stdout': function('s:OnStdout'),
					\ 'on_stderr': function('s:OnStdout'),
					\ 'on_exit': function('s:OnExit'),
					\ }
		call jobstart(l:cmd, l:opts)
	else
		let l:opts = {
					\ 'cwd': l:root,
					\ 'out_io': 'pipe',
					\ 'err_io': 'out',
					\ 'out_cb': function('s:OnStdout'),
					\ 'close_cb': function('s:OnExit'),
					\ }
		call job_start(l:cmd, l:opts)
	endif
endfunction

function! s:RustBuildExit(copen, job, status, ...) abort
	let s:rust_build_status = a:status

	let l:buf = a:0 > 0 ? a:1 : s:rust_build_buf

	" Read terminal buffer content
	"if s:rust_build_buf > 0 && bufexists(s:rust_build_buf)
		"let l:lines = getbufline(s:rust_build_buf, 1, '$')
	if l:buf > 0 && bufexists(l:buf)
		let l:lines = getbufline(l:buf, 1, '$')

		" Clear and populate quickfix
		call setqflist([], 'r', {'lines': l:lines, 'efm': b:rust_efm})

		if a:copen &&!empty(getqflist()) 
			copen 3
		endif
	endif

	if a:status != 0
		echohl ErrorMsg
		echom 'Rust build failed! Press F6 to view output.'
		echohl None
	else
		cclose
		echom 'Rust build succeeded.'
	endif
endfunction

function! s:NvimRustBuildExit(copen, buf, job, status, event) abort
    call s:RustBuildExit(a:copen, a:job, a:status)
endfunction

function! s:RustBuild(type,copen) abort
	let l:root = s:FindProjectRoot()
	if empty(l:root)
		echohl ErrorMsg | echo "No Cargo.toml found!" | echohl None
		return
	endif

	""必须切换目录，否则错误转跳不正确
	execute 'silent! lcd ' . fnameescape(l:root)

	" Clear quickfix before starting
	call setqflist([])

	let l:cmd = ['/bin/sh', '-c', b:cargo_prog . ' ' . a:type]

	echo "Running cargo " . a:type . " in " . l:root


	if has('nvim')
		" Create a hidden scratch buffer
		let l:buf = nvim_create_buf(v:false, v:true)
		call nvim_buf_set_option(l:buf, 'bufhidden', 'hide')

		let s:rust_build_buf = l:buf

		let l:opts = {
					\ 'cwd': l:root,
					\ 'term': v:true,
					\ 'on_exit': function('s:NvimRustBuildExit', [a:copen, l:buf]),
					\ }

		" Start terminal in the context of the new buffer
		let l:job = nvim_buf_call(l:buf, {-> jobstart(l:cmd, l:opts)})

		if l:job <= 0
			echoerr 'Failed to start Rust build'
		endif
	else
		let l:opts = {
					\ 'hidden': 1,
					\ 'cwd': l:root,
					\ 'term_name': 'RustBuild',
					\ 'exit_cb': function('s:RustBuildExit', [a:copen]),
					\ }

		let s:rust_build_buf = term_start(l:cmd, l:opts)

		if s:rust_build_buf <= 0
			echoerr 'Failed to start Rust build'
		endif
	endif
endfunction

function! s:RustBuildOpen() abort
	if s:rust_build_buf > 0
		if bufexists(s:rust_build_buf)
			execute 'botright sbuffer ' . s:rust_build_buf
		else
			echoerr 'Build terminal buffer no longer exists'
		endif
	else
		echo 'No build output available'
	endif
endfunction

" Copy Rust build terminal output to clipboard
function! s:RustBuildCopy() abort
	if s:rust_build_buf <= 0 || !bufexists(s:rust_build_buf)
		echoerr 'No Rust build terminal available'
		return
	endif

	let l:lines = getbufline(s:rust_build_buf, 1, '$')

	" Remove trailing empty lines
	while !empty(l:lines) && empty(l:lines[-1])
		call remove(l:lines, -1)
	endwhile

	call setreg('+', join(l:lines, "\n") . "\n")
	echom 'Rust build output copied to clipboard'
endfunction

function! s:RustBuildClose() abort
    " Close quickfix window
    cclose

    " Close Rust build terminal window
    if s:rust_build_buf > 0 && bufexists(s:rust_build_buf)
        let l:winid = bufwinid(s:rust_build_buf)
        if l:winid != -1
            call win_execute(l:winid, 'close')
        endif
    endif
endfunction

nnoremap <silent> <F2> :call <SID>RustBuild('run',0)<CR>
nnoremap <silent> <F3> :call <SID>RustBuild('check',1)<CR>
nnoremap <silent> <F4> :call <SID>RustBuildClose()<CR>
nnoremap <silent> <F5> :call <SID>RustBuild('build --release',0)<CR>
nnoremap <silent> <F6> :call <SID>RustBuildOpen()<CR>
nnoremap <silent> <F8> :call <SID>RustRun('clean')<CR>
nnoremap <silent> <F12> :call <SID>RustBuildCopy()<CR>

