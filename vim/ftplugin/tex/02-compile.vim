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

"let &l:efm = '%-P**%f,%-P**"%f",%E! LaTeX %trror: %m,%E%f:%l: %m,'
"			\ . '%E! %m,%Z<argument> %m,%Cl.%l %m,%-G%.%#'

let &l:efm = '%-P**%f,%E%f:%l: %m,%Z<argument> %m,%Cl.%l %m,%-G%.%#'

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
function! s:SumatraSynctexForward(pdf,source,line,col)
	"silent execute '!start SumatraPDF -reuse-instance '.fnameescape(a:pdf).' -forward-search "'.a:source.'" '.a:line
	if !exists('b:pdf_prog') || (b:pdf_prog == '')
		if !exists('g:pdf_prog')
			if executable('SumatraPDF')
				let b:pdf_prog = 'SumatraPDF'
			elseif executable($LOCALAPPDATA . '/SumatraPDF/SumatraPDF.exe')
				let b:pdf_prog = $LOCALAPPDATA . '/SumatraPDF/SumatraPDF.exe'
			elseif executable('C:/Program Files/SumatraPDF/SumatraPDF.exe')
				let b:pdf_prog = 'C:/Program Files/SumatraPDF/SumatraPDF.exe'
			else
				let b:pdf_prog = ''
				echom 'Can not find SumatraPDF!'
			endif
		else
			let b:pdf_prog = g:pdf_prog
		endif
	endif
	if b:pdf_prog != ''
		silent execute '!start '.fnameescape(b:pdf_prog).' -reuse-instance '
					\ .fnameescape(a:pdf).' -forward-search "'.a:source.'" '.a:line
	endif
endfunction

function! s:ZathuraSynctexForward_lua(pdf,source,line,col)
	let input = shellescape(a:line.":".a:col.":".a:source)
	if has("nvim")
		"let execstr_simple = 'zathura -x "nvim --server ' . v:servername
		"			\ . ' --remote-expr ''v:lua.jump_to_line(\"%{input}\", %{line})''" '
		"      \ . '--synctex-forward=' . input . ' ' . a:pdf . ' &'
		let base_cmd =
					\ 'if [ -S ' . v:servername . ' ]; then ' .
					\ 'nvim --server ' . v:servername .
					\ ' --remote-expr "v:lua.jump_to_line(\"%{input}\", %{line})"; ' .
					\ 'else setsid neovide "%{input}" -- ' .
					\ '--listen ' . v:servername .
					\ ' +"lua open_tex_and_jump(\"%{input}\", %{line})" >/dev/null 2>&1 & fi'
		
		let cmd = 'sh -c ' . shellescape(base_cmd)
		let execstr = 'zathura -x ' . shellescape(cmd) . ' ' .
					\ '--synctex-forward=' . input . ' ' . a:pdf . ' &'
	else
		let execstr = 'zathura -x "gvim --servername '.v:servername
					\ .' --remote-silent +\%{line} \%{input}" --synctex-forward='
					\ .input.' '.a:pdf.' &'
	endif
  silent call system(execstr)
endfunction
function! s:ZathuraSynctexForward(pdf,source,line,col)
	let input = shellescape(a:line . ":" . a:col . ":" . a:source)
	if has("nvim")
		let base_cmd =
					\ 'if [ -S ' . v:servername . ' ]; then ' .
					\ 'nvim --server ' . v:servername .
					\ ' --remote-expr "call(''tex#outils#JumpToLine'', [''%{input}'', %{line}])"; ' .
					\ 'else setsid neovide "%{input}" -- ' .
					\ '--listen ' . v:servername .
					\ ' +":call tex#outils#OpenTexAndJump(''%{input}'', %{line})" >/dev/null 2>&1 & fi'

		let cmd = 'sh -c ' . shellescape(base_cmd)
		let execstr = 'zathura -x ' . shellescape(cmd) . ' ' .
					\ '--synctex-forward=' . input . ' ' . fnameescape(a:pdf) . ' &'
	else
		let execstr = 'zathura -x "gvim --servername '.v:servername
					\ .' --remote-silent +\%{line} \%{input}" --synctex-forward='
					\ . input . ' ' . fnameescape(a:pdf) . ' &'
	endif
  silent call system(execstr)
endfunction

function! s:TeXViewPDF(pdf_file,source,line,col)
	if has("unix")
		call <SID>ZathuraSynctexForward(a:pdf_file,a:source,a:line,a:col)
	elseif has('win32') || has ('win64')
		call <SID>SumatraSynctexForward(a:pdf_file,a:source,a:line,a:col)
	endif
endfunction
"}}}

"{{{s:TeXCompileCloseHandler
function! s:TeXCompileCloseHandler(viewpdf,pdf_file,source,line,col,...) 	
	let l:qflist = getqflist()
	"let ctx = getqflist({'context': 1}).context
	if empty(l:qflist)
		cclose
		echom "successfully compiled"
		if a:viewpdf 
			silent! call <SID>TeXViewPDF(a:pdf_file,a:source,a:line,a:col)
		endif
	else 
		copen 5      " open quickfix window
		"if has_key(ctx, 'projdir')
		"	execute 'silent! lcd ' . fnameescape(ctx.projdir)
		"endif
		wincmd p    " jump back to previous window
		echohl WarningMsg
		echomsg "compile failed with errors"
		echohl None
	endif
endfunction
"}}}

function! s:TeXCompileOutHandler(job_id, msg,...) "{{{OutHandler
	if has("nvim")
		call setqflist([], 'a', {'lines': a:msg, 'efm': &l:efm})
	else
		call setqflist([], 'a', {
					\ 'lines': [a:msg],
					\ 'efm': &l:efm, 
					"\ 'context': {'projdir': b:tex_proj_dir}
					\ })
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
let b:tex_engine_options = '-synctex=1 -file-line-error -interaction=nonstopmode'
function! RunLaTeX_job(tex_file,dir,engine,view,track_source,track_line,track_col)
	let proj_dir = fnameescape(a:dir)
	let tex_file = fnameescape(a:tex_file)
	let pdf_file = fnamemodify(a:tex_file,':p:r').'.pdf'
	"切换编译时候的工作目录，错误转跳的时候需要用到
	execute 'silent! lcd ' . proj_dir 
	if has('unix')
		let tex_cmd = 'cd ' . proj_dir . ' && ' . a:engine . ' '
					\ . b:tex_engine_options. ' ' . tex_file
		"let tex_cmd =  a:engine . ' ' . b:tex_engine_options . ' ' . tex_file
		let cmd = ['/bin/sh', '-c', tex_cmd]
	elseif has('win32') || has('win64')
		let tex_cmd = 'cd /d ' . proj_dir . ' && ' . a:engine . ' '
					\ . b:tex_engine_options. ' ' . tex_file
		"let tex_cmd =  a:engine . ' ' . b:tex_engine_options . ' ' . tex_file
		let cmd = &shell . ' /c ' . tex_cmd

		let kill_adobe_cmd = 'powershell -Command "'
					\ . '$pdf=\"' . pdf_file . '\";'
					\ . 'try {'
					\ . '  $fs = [System.IO.File]::Open($pdf,\"Open\",\"ReadWrite\",\"None\");'
					\ . '  $fs.Close();'
					\ . '} catch {'
					\ . '  Get-Process Acrobat,AcroRd32 -ErrorAction SilentlyContinue | Stop-Process -Force;'
					\ . '}"'
		silent! call system(kill_adobe_cmd)
	endif
	call setqflist([])
	if has("nvim")
		let b:run_tex_job = jobstart(cmd, {
					"\ 'on_stderr': function('s:TeXCompileOutHandler'),
					\ 'on_stdout': function('s:TeXCompileOutHandler'),
					\ 'on_exit': function('s:TeXCompileCloseHandler', 
					\ [a:view,pdf_file,a:track_source,a:track_line,a:track_col]),
					\ })
	else
		let job_options = {
					\ 'out_io': 'pipe',
					\ 'out_cb': function('s:TeXCompileOutHandler'),
					\ 'close_cb': function('s:TeXCompileCloseHandler',
					\ [a:view,pdf_file,a:track_source,a:track_line,a:track_col]),
					\ }
		let b:run_tex_job = job_start(cmd, job_options)
	endif
endfunction
"}}}

""{{{ RunLaTeX(file,dir,engine,view)
function! RunLaTeX(tex_file,dir,engine,view,source,line,col)
	let dir_old = getcwd()
	let proj_dir = fnameescape(a:dir)
	exec 'lcd ' . proj_dir
	let pdf_file = fnamemodify(a:tex_file,':p:r').'.pdf'
	silent setlocal shellpipe=>
	call setqflist([]) " clear quickfix
	let makeprg_old = &makeprg
	let &makeprg = a:engine.' '.b:tex_engine_options.' '.fnameescape(a:tex_file)
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
		echom "successfully compiled"
		if a:view
			silent! call <SID>TeXViewPDF(pdf_file,a:source,a:line,a:col)
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
		call cursor(1, 1)
		let tex_engine_com_line = search(com_str,'c',b:doc_class_line)
		let xelatex_marker = search('^\s*\\\(setmainfont\|setCJKmainfont\)','cn',b:doc_begin_doc)
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
		let tex_engine_pre = matchstr(line_text, '\c\(pdf\|xe\|lua\)latex')
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

	let save_cursor = getpos(".")
	let track_line = line(".")
	let track_col = col(".")
	let track_source = expand("%:p")

	if !exists('b:tex_main_file_name')  || !exists('b:tex_proj_dir') || (b:tex_main_file_name == '')
		let [b:tex_main_file_name,b:tex_proj_dir] = s:Find_Main_TeX_File()
	endif
	if b:tex_main_file_name == ''
		echohl WarningMsg
		echomsg "No main tex file be found!"
		echohl None
		return ''
	endif

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
		let pdf_check = 'pgrep -a zathura | grep ' . fnameescape(pdf_file)
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
					\ viewpdf,
					\ track_source,
					\ track_line,
					\ track_col
					\ )
	else
		if v:version >= 801
			silent! call RunLaTeX_job(
						\ b:tex_main_file_name,
						\ b:tex_proj_dir,
						\ b:tex_engine,
						\ viewpdf,
						\ track_source,
						\ track_line,
						\ track_col
						\ )
		else
			silent! call RunLaTeX(
						\ b:tex_main_file_name,
						\ b:tex_proj_dir,
						\ b:tex_engine,
						\ viewpdf,
						\ track_source,
						\ track_line,
						\ track_col
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
	let current_dir = getcwd()
	if b:tex_main_file_name != ''
		exec 'lcd ' . fnameescape(b:tex_proj_dir)
		let l:tex_mfn = fnamemodify(b:tex_main_file_name,":p:t")
		if !exists('b:tex_bib_engine')  || (b:tex_bib_engine == '')
			if search('\\addbibresource\s*{.\+}','cnw')
				let b:tex_bib_engine = 'biber'
			else
				let b:tex_bib_engine = 'bibtex'
			endif
		endif
		let l:tex_mfwoe = substitute(l:tex_mfn,"\.tex$","","")
		silent! exec '!'.b:tex_bib_engine. ' '.fnameescape(l:tex_mfwoe)
		exec 'lcd ' . fnameescape(current_dir)
		echo 'BibTeX compiled!'
	else
		echomsg "no main file be found"
	endif
endfunction
"}}}1
"
"Compile asy {{{
function! s:CompileAsy()
	if !exists('b:tex_main_file_name')  || !exists('b:tex_proj_dir')|| (b:tex_main_file_name == '')
		let [b:tex_main_file_name,b:tex_proj_dir] = s:Find_Main_TeX_File()
	endif
	let l:tex_mfn = b:tex_main_file_name
	let current_dir = getcwd()
	if l:tex_mfn != ''
		exec 'lcd ' . fnameescape(b:tex_proj_dir)
		let l:tex_mf_asy = substitute(l:tex_mfn,"\.tex$","-*.asy","")
		silent! exec '!asy '.fnameescape(l:tex_mf_asy)
		echo 'Asy compiled !'
		exec 'lcd ' . fnameescape(current_dir)
	else
		echomsg "no main file be found"
	endif
endfunction
"}}}

function! s:TeX_Compile_Paragraph(engine) "{{{
	silent write
	let cur_cursor= [line("."),col(".")]
	let current_dir = getcwd()
	let projdir = expand("%:p:h")
	if !exists('b:tex_main_file_name')  || !exists('b:tex_proj_dir') || (b:tex_main_file_name == '')
		let [b:tex_main_file_name,b:tex_proj_dir] = s:Find_Main_TeX_File()
	endif
	"find the preamble
	if b:tex_main_file_name == ''
		echomsg "no main tex file be found!" 
		return 
	else
		let projdir = b:tex_proj_dir
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

	" choose proper TeX engine
	if a:engine == 'auto'
		if !exists('b:tex_engine')
			let b:tex_engine = s:Find_TeX_engine()
		endif
	else 
		let b:tex_engine = a:engine
	endif

	"find the current paragraph
	let start_line = search('^\s*\\\(chapter\|\(sub\)*section\|appendix\|begin\s*{\s*document\s*}\)','bcnW')
	let end_line = search('^\s*\\\(chapter\|\(sub\)*section\|appendix\|end\s*{\s*document\s*}\)','nW')
	if start_line == 0
		let start_line = 1
	elseif getline(start_line) =~ '^\s*\\begin\s*{\s*document\s*}'
		let start_line = start_line + 1
	endif
	if end_line == 0
		let end_line = line('$')
	else
		let end_line = end_line - 1
	endif
	"compile the paragraph 
	if start_line >= end_line
		return '' 
	else
		if getftype(projdir.'/tmp') != 'dir'
			call mkdir(projdir.'/tmp')
		endif
		let content = getline(start_line,end_line)
		"处理图片
		for i in range(len(content))
			let l = content[i]
			" 过滤掉不含 includegraphics 的行
			if l =~# '\\includegraphics'
				"" 1) ./img/foo.png → ../img/foo.png
				"if l =~# '\\includegraphics\(\[[^\]]*\]\)\?\s*{\s*\.'
				"	let l = substitute(l,
				"				\ '\\includegraphics\(\[[^\]]*\]\)\?\s*{\s*\.\([^}]*\)}',
				"				\ '\\includegraphics\1{..\2}',
				"				\ 'g')
				"" 2) img/foo.png → ../img/foo.png
				"elseif l =~# '\\includegraphics\(\[[^\]]*\]\)\?\s*{\s*\w'
				"	let l = substitute(l,
				"				\ '\\includegraphics\(\[[^\]]*\]\)\?\s*{\s*\([^}]*\)}',
				"				\ '\\includegraphics\1{../\2}',
				"				\ 'g')
				"endif
				"换一种写法
				let l = substitute(l,
							\ '\\includegraphics\(\[[^\]]*\]\)\?\s*{\s*\(\./\)\?\([^}]*\)}',
							\ '\\includegraphics\1{../\3}',
							\ 'g')
				let content[i] = l
			endif
		endfor
		let compile_part = extend(copy(preamble), content)
		call add(compile_part,'\end{document}')
		let tmp_file =  projdir.'/tmp/'.curtexfname.'_tmp.tex'
		let tmp_dir = projdir . '/tmp'
		call writefile(compile_part,tmp_file)
		let tmp_line = len(preamble) + cur_cursor[0] - start_line + 1
		let tmp_col = cur_cursor[1]
		let tmp_source = tmp_file
		echomsg "compiling the current paragraph with ".b:tex_engine."..."
		if has("nvim")
			silent call RunLaTeX_job(tmp_file,tmp_dir,b:tex_engine,1,
						\ tmp_source,tmp_line,tmp_col)
		else
			if v:version >= 801
				silent call RunLaTeX_job(tmp_file,tmp_dir,b:tex_engine,1,
							\ tmp_source,tmp_line,tmp_col)
			else
				silent call RunLaTeX(tmp_file,tmp_dir,b:tex_engine,1,
							\ tmp_source,tmp_line,tmp_col)
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
nnoremap <silent> <buffer><F3> : call <SID>TeX_Compile_Paragraph('auto')<CR>
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
