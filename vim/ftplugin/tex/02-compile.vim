"=============================================================================
" 	     File: compile.vim
"      Author: Yangqin Fang
"       Email: fangyq09@gmail.com
"     Created: 06/06/2013
"     Revised: 11/04/2025
" 	  Version: 3.0 
" 
"  Description: A compile plugin for LaTeX
"  In normal mode:
"  1. Press <F2> to run pdflatex or xelatex (auto detect TeX engine); 
"  2. Press <S-F2> to run pdflatex; 
"  3. Press <F6> to run xelatex;
"  4. Press <F8> to compile bibtex or biblatex;
"  5. Prees <F3> to compile current paragraph (auto detect TeX engine).
"  In case you split your project into many separated tex files, for example 
"  chapter1.tex, chapter2.tex, ..., in any chapter, the shortcuts are all feasible.
"=============================================================================
if exists('b:loaded_vimtextric_compile')
	finish
endif
let b:loaded_vimtextric_compile = 1

if has("win32") || has("win64")
	set shellslash
endif 

let &l:efm = '%-P**%f,%-P**"%f",%E! LaTeX %trror: %m,%E%f:%l: %m,'
			\ . '%E! %m,%Z<argument> %m,%Cl.%l %m,%-G%.%#'

function! s:Find_Main_TeX_File() "{{{
	if exists('b:doc_class_line')  && (b:doc_class_line > 0)
		let main_tex_file = expand('%:p')
		let main_tex_dir = expand('%:p:h')
		let main_tex = [main_tex_file,main_tex_dir]
	else
		let main_tex = tex#outils#GetMainTeXFile()
	endif
	return main_tex
endfunction
"}}}

"ViewPDF{{{
function! s:SumatraSynctexForward(file)
	"exec 'lcd ' . expand(%:p:h)
	"silent execute "!start SumatraPDF -reuse-instance ".a:file." -forward-search \"".expand("%:p")."\" ".line(".")
	silent execute '!start SumatraPDF -reuse-instance '.a:file.' -forward-search "'.b:tmp_source.'" '.b:tmp_cursor[0]
endfunction

function! s:ZathuraSynctexForward(file)
	let input = shellescape(b:tmp_cursor[0].":".b:tmp_cursor[1].":".b:tmp_source)
	if has("nvim")
		"let execstr_simple = 'zathura -x "nvim --server ' . v:servername
		"			\ . ' --remote-expr ''v:lua.jump_to_line(\"%{input}\", %{line})''" '
		"      \ . '--synctex-forward=' . input . ' ' . a:file . ' &'
		let base_cmd =
					\ 'if [ -S ' . v:servername . ' ]; then ' .
					\ 'nvim --server ' . v:servername .
					\ ' --remote-expr "v:lua.jump_to_line(\"%{input}\", %{line})"; ' .
					\ 'else setsid neovide "%{input}" -- ' .
					\ '--listen ' . v:servername .
					\ ' +"lua open_tex_and_jump(\"%{input}\", %{line})" >/dev/null 2>&1 & fi'
		let cmd = 'sh -c ' . shellescape(base_cmd)
		let execstr = 'zathura -x ' . shellescape(cmd) . ' ' .
					\ '--synctex-forward=' . input . ' ' . a:file . ' &'
	else
		let execstr = 'zathura -x "gvim --servername '.v:servername
					\ .' --remote-silent +\%{line} \%{input}" --synctex-forward='
					\ .input.' '.a:file.' &'
	endif
  silent call system(execstr)
endfunction

function! s:TeXViewPDF(pdf_file)
	if has("unix")
		call <SID>ZathuraSynctexForward(a:pdf_file)
	elseif has('win32') || has ('win64')
		call <SID>SumatraSynctexForward(a:pdf_file)
	endif
endfunction
"}}}

function! s:TeXCompileCloseHandler(viewpdf,file,...) "{{{CloseHandler
	let l:qflist = getqflist()
	if empty(l:qflist)
		cclose
		echom "successfully compiled"
		if a:viewpdf 
			let pdf_file = fnamemodify(a:file,':p:r').'.pdf'
			silent! call <SID>TeXViewPDF(fnameescape(pdf_file))
		endif
	else 
		copen 5      " open quickfix window
		wincmd p    " jump back to previous window
		echohl WarningMsg
		echomsg "compile failed with errors"
		echohl None
	endif
endfunction
"}}}

function! s:TeXCompileOutHandler(job_id, msg,...) "{{{OutHandler
	if has("nvim")
		call setqflist([], 'a', {'lines': a:msg, 'efm': &l:efm })
	else
		call setqflist([], 'a', {'lines': [a:msg], 'efm': &l:efm})
	endif
endfunction
"}}}

function! s:TeXCancelJob() "{{{
	if !exists('b:run_tex_job')
		return ''
	endif
	if has("nvim")
		if b:run_tex_job > 0
			call jobstop(b:run_tex_job)
		endif
	else
		let status = job_status(b:run_tex_job)
		if status == 'run'
			call job_stop(b:run_tex_job)
		endif
	endif
	return ''
endfunction
"}}}

"{{{ RunLaTeX_job(file,dir,engine,view) 
"let b:tex_proj_dir = expand('%:p:h')
let b:tex_engine_options = '-synctex=1 -file-line-error -interaction=nonstopmode'
function! RunLaTeX_job(file,dir,engine,view)
	let proj_dir = fnameescape(a:dir)
	let tex_file = fnameescape(a:file)
	if has('unix')
		let tex_cmd = 'cd ' . proj_dir . ' && ' . a:engine . ' '
					\ . b:tex_engine_options. ' ' . tex_file
		let cmd = ['/bin/sh', '-c', tex_cmd]
	elseif has('win32') || has('win64')
		let tex_cmd = 'cd /d ' . proj_dir . ' && ' . a:engine . ' '
					\ . b:tex_engine_options. ' ' . tex_file
		let cmd = &shell . ' /c ' . tex_cmd
	endif
	call setqflist([])
	if has("nvim")
		let b:run_tex_job = jobstart(cmd, {
					"\ 'on_stderr': function('s:TeXCompileOutHandler'),
					\ 'on_stdout': function('s:TeXCompileOutHandler'),
					\ 'on_exit': function('s:TeXCompileCloseHandler', [a:view, a:file]),
					\ })
	else
		let job_options = {
					\ 'out_io': 'pipe',
					\ 'out_cb': function('s:TeXCompileOutHandler'),
					\ 'close_cb': function('s:TeXCompileCloseHandler',[a:view,a:file]),
					\ }
		let b:run_tex_job = job_start(cmd, job_options)
	endif
endfunction
"}}}

""{{{ RunLaTeX(file,dir,engine,view)
function! RunLaTeX(file,dir,engine,view)
	let dir_old = getcwd()
	let proj_dir = fnameescape(a:dir)
	exec 'lcd ' . proj_dir
	let pdf_file = fnamemodify(a:file,':p:r').'.pdf'
	silent setlocal shellpipe=>
	call setqflist([]) " clear quickfix
	let makeprg_old = &makeprg
	let &makeprg = a:engine.' '.b:tex_engine_options.' '.fnameescape(a:file)
	silent make!  
	let &makeprg = makeprg_old
	exec 'lcd ' . dir_old
	if v:shell_error
		let l:entries = getqflist()
		if len(l:entries) > 0 
			copen 5      " open quickfix window
			wincmd p    " jump back to previous window
			"call cursor(l:entries[0]['lnum'], 0) " go to error line
		else
			echohl WarningMsg
			echo "compile failed with errors"
			echohl None
		endif
	else
		cclose
		echon "successfully compiled"
		if a:view
			silent! call <SID>TeXViewPDF(fnameescape(pdf_file))
		endif
	endif
endfunction
"}}}

"{{{ Find TeX engine
function! s:Find_TeX_engine() 
	" Get the TeX engine from the line % !TeX engine/grogram = pdflatex/xelatex
	"let com_str = '^\c\s*%\+.\{-}\(!\)*\s*\(TeX\)*\s*\(engine\|program\)*\s*\(=\|:\)*\s*\(pdf\|xe\|lau\)*latex.*'
	let l:current_file = expand('%:p')
	let com_str = '^\c\s*%.\{-}\(pdf\|xe\|lua\)latex\(\s.*\)*$' 
	let save_cursor = getpos(".")
	if b:tex_main_file_name ==# l:current_file
		call cursor(1, 1)
		if !exists('b:doc_class_line')
			let b:doc_class_line = search('^\s*\\documentclass','cw')
		endif
		if !exists('b:doc_begin_doc')
			let b:doc_begin_doc = search('^\s*\\begin\s*{\s*document\s*}','cnw')
		endif
		let tex_engine_com_line = search(com_str,'c',b:doc_class_line)
		let xelatex_marker = search('^\s*\\\(setmainfont\|setCJKmainfont\)','c',b:doc_begin_doc)
		if tex_engine_com_line
			let line_text = getline(tex_engine_com_line)
		endif
	else
		let main_tex_file_text = readfile(b:tex_main_file_name)
		let line_num = 0
		let tex_engine_com_line = 0
		let xelatex_marker = 0
		for item in main_tex_file_text
			let line_num = line_num + 1 
			if item =~ com_str
				let line_text = item 
				let tex_engine_com_line = line_num
				break
			endif
			if item =~ '^\s*\\\(setmianfont\|setCJKmainfont\)'
				let xelatex_marker = line_num
				break
			endif
		endfor
	endif
	if (tex_engine_com_line == 0)&&(xelatex_marker == 0)
		let tex_engine = 'pdflatex'
	elseif tex_engine_com_line > 0
		let tex_engine_pre = matchstr(line_text, '\(pdf\|xe\|lua\)latex')
		let tex_engine = tolower(tex_engine_pre)
	else
		let tex_engine = 'xelatex'
	endif
	call setpos('.', save_cursor)
	return tex_engine
endfunction
"}}}

"{{{ call RunLaTeX with proper TeX engine
function! s:Compile_LaTeX_Run(engine,view) 
	silent write
	if &ft != 'tex'
		echomsg "calling RunLaTeX from a non-tex file"
		return ''
	endif
	if !exists('b:tex_main_file_name')  || !exists('b:tex_proj_dir') || (b:tex_main_file_name == '')
		let [b:tex_main_file_name,b:tex_proj_dir] = s:Find_Main_TeX_File()
	endif
	if b:tex_main_file_name == ''
		echohl WarningMsg
		echomsg "No main tex file be found! Please assign the main tex file to b:tex_main_file_name and try again"
		echohl None
		return ''
	endif
	let save_cursor= [bufnr("%"),line("."),col("."),0]
	let b:tmp_cursor = save_cursor[1:2]
	let b:tmp_source = expand("%:p")

	" choose proper TeX engine
	if a:engine == 'auto'
		if !exists('b:tex_engine')
			let b:tex_engine = s:Find_TeX_engine()
		endif
	else 
		let b:tex_engine = a:engine
	endif

	let pdf_file = fnamemodify(b:tex_main_file_name,':p:r').'.pdf'
	if has('unix')
		let pdf_check = 'pgrep -a zathura | grep ' . pdf_file
		if empty(system(pdf_check)) && a:view
			let viewpdf = 1
		else
			let viewpdf = 0
		endif	
	else
		let viewpdf = a:view
	endif


	""compile latex 
	echomsg "compiling with ".b:tex_engine."..."
	if has("nvim")
		silent! call RunLaTeX_job(
					\ b:tex_main_file_name,
					\ b:tex_proj_dir,
					\ b:tex_engine,
					\ viewpdf
					\ )
	else
		if v:version >= 801
			silent! call RunLaTeX_job(
						\ b:tex_main_file_name,
						\ b:tex_proj_dir,
						\ b:tex_engine,
						\ viewpdf
						\ )
		else
			silent! call RunLaTeX(
						\ b:tex_main_file_name,
						\ b:tex_proj_dir,
						\ b:tex_engine,
						\ viewpdf
						\ )
		endif
	endif
	call setpos('.', save_cursor)
endfunction
"}}}

"View Dvi, and Dvi to PDF{{{
""这种方法生成的PDF文件质量好也可以避免中文书签乱码
function! s:DviToPDF(file)
	exec "silent !xdvipdfmx ".a:file
endfunction
function! s:VDwY()
	exe "silent !start YAP.exe -1 -s " . line(".") . "\"%<.TEX\" \"%<.DVI\""  
endfunction
""}}}

"Compile BibTeX{{{1
function! s:CompileBibTeX()
	if !exists('b:tex_main_file_name')  || !exists('b:tex_proj_dir')|| (b:tex_main_file_name == '')
		let [b:tex_main_file_name,b:tex_proj_dir] = s:Find_Main_TeX_File()
	endif
	exec 'lcd ' . fnameescape(b:tex_proj_dir)
	let l:tex_mfn = fnamemodify(b:tex_main_file_name,":p:t")
	if !exists('b:tex_bib_engine')  || (b:tex_bib_engine == '')
		if search('\\addbibresource\s*{.\+}','cnw')
			let b:tex_bib_engine = 'biber'
		else
			let b:tex_bib_engine = 'bibtex'
		endif
	endif
	if l:tex_mfn != ''
		let l:tex_mfwoe = substitute(l:tex_mfn,"\.tex$","","")
	else
		echomsg "no main file be found"
		return
	endif
	echo 'Compile bibtex ...'
	silent! exec '!'.b:tex_bib_engine. ' '.fnameescape(l:tex_mfwoe)
endfunction
"}}}1
"
"Compile asy {{{
function! s:CompileAsy()
	if !exists('b:tex_main_file_name')  || !exists('b:tex_proj_dir')|| (b:tex_main_file_name == '')
		let [b:tex_main_file_name,b:tex_proj_dir] = s:Find_Main_TeX_File()
	endif
	exec 'lcd ' . fnameescape(b:tex_proj_dir)
	let l:tex_mfn = b:tex_main_file_name
	if l:tex_mfn != ''
		let l:tex_mf_asy = substitute(l:tex_mfn,"\.tex$","-*.asy","")
	else
		echomsg "no main file be found"
		return
	endif
	silent! exec '!asy '.fnameescape(l:tex_mf_asy)
endfunction
"}}}

function! s:TeX_Compile_Paragraph(engine) "{{{
	silent write
	let cur_cursor= [line("."),col(".")]
	let curdir = expand("%:p:h")
	if getftype('tmp') != 'dir'
		call mkdir('tmp')
	endif
	"find the preamble
	if exists('b:doc_begin_doc') && (b:doc_begin_doc > 0)
		let preamble = getline(1,b:doc_begin_doc)
		let curtexfname = expand("%:t:r")
	else
		let [b:tex_main_file_name,b:tex_proj_dir] = s:Find_Main_TeX_File()
		if b:tex_main_file_name == ''
			echomsg "no main tex file be found!" 
			return ''
		else
			let curtexfname = fnamemodify(b:tex_main_file_name,':p:t:r')
			let mainfile_content = readfile(b:tex_main_file_name) 
			let preamble = []
			for item in mainfile_content
				call add(preamble,item)
				if item =~ '^\s*\\begin\s*{\s*document\s*}'
					break
				endif
			endfor
		endif
	endif

	" choose proper TeX engine
	if a:engine == 'auto'
		if !exists('b:tex_engine')
			let b:tex_engine = s:Find_TeX_engine()
		endif
	else 
		let b:tex_engine = a:engine
	endif

	"find the current paragraph
	let start_pos = search('^\s*\\\(chapter\|\(sub\)*section\|appendix\|begin\s*{\s*document\s*}\)','bcnW')
	let end_pos = search('^\s*\\\(chapter\|\(sub\)*section\|appendix\|end\s*{\s*document\s*}\)','nW')
	if start_pos == 0
		let start_pos = 1
	elseif getline(start_pos) =~ '^\s*\\begin\s*{\s*document\s*}'
		let start_pos = start_pos + 1
	endif
	if end_pos == 0
		let end_pos = line('$')
	else
		let end_pos = end_pos - 1
	endif
	"compile the paragraph 
	if start_pos >= end_pos
		return '' 
	else
		let content = getline(start_pos,end_pos)
		let compile_part = extend(copy(preamble), content)
		call add(compile_part,'\end{document}')
		let tmp_file =  curdir.'/tmp/'.curtexfname.'_tmp.tex'
		let tmp_dir = curdir . '/tmp'
		call writefile(compile_part,tmp_file)
		let b:tmp_cursor = [len(preamble) + cur_cursor[0] - start_pos + 1,cur_cursor[1]]
		let b:tmp_source = tmp_file
		echomsg "compiling the current paragraph with ".b:tex_engine."..."
		if has("nvim")
			silent call RunLaTeX_job(tmp_file,tmp_dir,b:tex_engine,1)
		else
			if v:version >= 801
				silent call RunLaTeX_job(tmp_file,tmp_dir,b:tex_engine,1)
			else
				silent call RunLaTeX(tmp_file,tmp_dir,b:tex_engine,1)
			endif
		endif
	endif
endfunction
"}}}

nnoremap <silent> <buffer><F2>  :call <SID>Compile_LaTeX_Run('auto',1)<CR>
nnoremap <silent> <buffer><S-F2>  :call <SID>Compile_LaTeX_Run('pdflatex',1)<CR>
nnoremap <silent> <buffer><F6>  :call <SID>Compile_LaTeX_Run("xelatex",1)<CR> 
nnoremap <silent> <buffer><F8> :call <SID>CompileBibTeX()<CR>
nnoremap <silent> <buffer><C-c> : call <SID>TeXCancelJob()<CR>
"nnoremap <silent> <buffer><F3> : call <SID>TeX_Compile_Paragraph('auto')<CR>
"{{{ menu
menu 8000.60.040 &LaTeX.&DVI\ To\ PDF<tab><C-F6>  
			\ :call <SID>DviToPDF(expand("%:r").".dvi")<CR>
menu 8000.60.050 &LaTeX.&XeLaTeX<tab><F6> 
			\ :call <SID>Compile_LaTeX_Run("xelatex",1)<CR>
menu 8000.60.060 &LaTeX.&pdfLaTeX<tab><S-F2> 
			\ :call <SID>Compile_LaTeX_Run("pdflatex",1)<CR>
menu 8000.60.070 &LaTeX.&Compile\ BibTeX<tab><F8>		
			\ :call <SID>CompileBibTeX()<CR>
menu 8000.60.080 &LaTeX.&Compile\ Asy<tab><C-F8>		
			\ :call <SID>CompileAsy()<CR>
menu 8000.60.090 &LaTeX.&Compile\ Paragraph<tab><F3>		
			\ :call <SID>TeX_Compile_Paragraph('auto')<CR>

"}}}
"
" vim:fdm=marker:noet:ff=unix
