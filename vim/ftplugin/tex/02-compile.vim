"=============================================================================
" 	     File: compile.vim
"      Author: Yangqin Fang
"       Email: fangyq09@gmail.com
"     Created: 06/06/2013
"     Revised: 8/06/2026
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
	let b:default_pdfviewer = "sumatra"
	let s:tex_cmd_term = ['cmd.exe', '/c']
	let b:Path_VectorSnap = expand('C:\Tools\VectorSnap.exe')
	let b:Path_SumatraPDF = expand($LOCALAPPDATA . '/SumatraPDF/SumatraPDF.exe')
	let s:cmd_cd = 'cd /d'
elseif has("unix")
	let b:default_pdfviewer = "vectorsnap"
	let s:tex_cmd_term = ['/bin/sh', '-c']
	"let b:Path_VectorSnap = expand('~/.local/bin/VectorSnap')
	let b:Path_VectorSnap = expand('/home/fang/rust/pdf/target/debug/VectorSnap')
	let s:cmd_cd = 'cd'
endif 

"let &l:efm = '%-P**%f,%-P**"%f",%E! LaTeX %trror: %m,%E%f:%l: %m,'
"			\ . '%E! %m,%Z<argument> %m,%Cl.%l %m,%-G%.%#'

let s:tex_efm = '%-P**%f,%E%f:%l: %m,%I%f:%l: %m,%Z<argument> %m,%Cl.%l %m,%-G%.%#'
let &l:efm = s:tex_efm
let b:tex_engine_options = '-synctex=1 -file-line-error -interaction=nonstopmode'
let b:tex_compile_output = []
let b:tex_out_dir = 'build'
let b:self_parse_synctex = 0

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

function! s:SumatraSynctexForward(pdf,source,line,col,...)"{{{
	if !exists('b:Path_SumatraPDF') || (b:Path_SumatraPDF == '')
		if !exists('g:Path_SumatraPDF')
			if executable('SumatraPDF')
				let b:Path_SumatraPDF = 'SumatraPDF'
			elseif executable($LOCALAPPDATA . '/SumatraPDF/SumatraPDF.exe')
				let b:Path_SumatraPDF = $LOCALAPPDATA . '/SumatraPDF/SumatraPDF.exe'
			elseif executable('C:/Program Files/SumatraPDF/SumatraPDF.exe')
				let b:Path_SumatraPDF = 'C:/Program Files/SumatraPDF/SumatraPDF.exe'
			else
				let b:Path_SumatraPDF = ''
				echom 'Can not find SumatraPDF!'
			endif
		else
			let b:Path_SumatraPDF = g:Path_SumatraPDF
		endif
	endif
	if b:Path_SumatraPDF != ''
		silent execute '!start '.fnameescape(b:Path_SumatraPDF).' -reuse-instance '
					\ .fnameescape(a:pdf).' -forward-search "'.a:source.'" '.a:line
	endif
endfunction
"}}}

function! s:ZathuraSynctexForward_lua(pdf,source,line,col,...) "{{{
	let l:target_pdf = a:pdf
	let l:build_dir = a:0 > 0 ? a:1 : ''
	if !empty(l:build_dir)
		let l:dir = fnamemodify(a:pdf, ':h')
		let l:tail = fnamemodify(a:pdf, ':t')
		let l:target_pdf = (l:dir == '.' ? '' : l:dir . '/') . l:build_dir . '/' . l:tail
	endif
	let input = shellescape(a:line.":".a:col.":".a:source)
	if has("nvim")
		"let execstr_simple = 'zathura -x "nvim --server ' . v:servername
		"			\ . ' --remote-expr ''v:lua.jump_to_line(\"%{input}\", %{line})''" '
		"      \ . '--synctex-forward=' . input . ' ' . l:target_pdf . ' &'
		let base_cmd =
					\ 'if [ -S ' . v:servername . ' ]; then ' .
					\ 'nvim --server ' . v:servername .
					\ ' --remote-expr "v:lua.jump_to_line(\"%{input}\", %{line})"; ' .
					\ 'else setsid neovide "%{input}" -- ' .
					\ '--listen ' . v:servername .
					\ ' +"lua open_tex_and_jump(\"%{input}\", %{line})" >/dev/null 2>&1 & fi'
		
		let cmd = 'sh -c ' . shellescape(base_cmd)
		let execstr = 'zathura -x ' . shellescape(cmd) . ' ' .
					\ '--synctex-forward=' . input . ' ' . fnameescape(l:target_pdf) . ' &'
	else
		let execstr = 'zathura -x "gvim --servername '. v:servername
					\ .' --remote-silent +\%{line} \%{input}" --synctex-forward='
					\ .input.' '.fnameescape(l:target_pdf).' &'
	endif
  silent call system(execstr)
endfunction
"}}}

function! s:ZathuraSynctexForward(pdf,source,line,col,...)"{{{
	let l:target_pdf = a:pdf
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
					\ '--synctex-forward=' . input . ' ' . fnameescape(l:target_pdf) . ' &'
	else
		let execstr = 'zathura --synctex-forward=' . input . ' '
					\ . fnameescape(l:target_pdf) . ' &'
	endif
  silent call system(execstr)
endfunction
"}}}

function! s:VectorSnap_SynctexForward(pdf_file,source,line,col,build_dir)"{{{
    let l:out_dir = trim(a:build_dir)

		let page_match = ''
		if b:self_parse_synctex
			" 使用 synctex view 提取页码
			let synctex_arg = printf('%d:1:%s', a:line, a:source)
			let l:target_pdf = a:pdf_file

			if !empty(l:out_dir)
				let l:dir = fnamemodify(a:pdf_file, ':h')
				let l:tail = fnamemodify(a:pdf_file, ':t')
				let l:target_pdf = (l:dir == '.' ? '' : l:dir . '/') . l:out_dir . '/' . l:tail
			endif

			" 使用 SyncTeX 查询页码
			let syn_cmd = 'synctex view -i ' . shellescape(l:synctex_arg)
						\ . ' -o ' . shellescape(l:target_pdf)


			let output = system(syn_cmd)
			let page_match = matchstr(output, '\vPage:\zs\d+')
		endif

    " 获取 PDF 阅读器程序
    if exists('b:Path_VectorSnap')
        let l:pdf_viewer_prog = b:Path_VectorSnap
    else
        let l:pdf_viewer_prog = 'VectorSnap'
    endif

    " 获取当前 Vim ServerName
    let l:server_name = v:servername

		" 获取当前 Vim/Neovim 可执行文件
		let l:editor = get(g:, 'neovide', v:false) ? 'neovide' : v:progname


    " 构造启动命令
    let l:execstr = shellescape(l:pdf_viewer_prog) . ' ' . shellescape(a:pdf_file)

    if  b:self_parse_synctex && !empty(page_match)
        let l:execstr .= ' --page=' . page_match
    endif

		if !empty(l:out_dir)
				let l:dir = fnamemodify(a:pdf_file, ':h')
				let l:target_dir = l:dir . '/' . l:out_dir 
				let synctex_dir = '|' . l:target_dir
		else
			let synctex_dir = ''
		endif

		if b:self_parse_synctex == 0
			let l:synctex_arg = '--synctex=' . a:line . ':' . a:col . ':' . a:source . l:synctex_dir
			let l:execstr .= ' ' . shellescape(l:synctex_arg)
		endif

    if !empty(l:server_name)
        let l:execstr .= ' --servername=' . shellescape(l:server_name)
    endif

    if !empty(l:editor)
        let l:execstr .= ' --editor=' . shellescape(l:editor)
    endif

    " 启动或通知 VectorSnap
		if has('win32')
			silent execute '!start "" /b ' . l:execstr
		else
			"call system(l:execstr . ' &')
			call system(l:execstr . ' >/dev/null 2>&1 &')
		endif
endfunction
"}}}

function! s:TeXViewPDF(viewer, pdf_file,source,line,col,build_dir)"{{{
	if a:viewer == 'zathura'
		call <SID>ZathuraSynctexForward(a:pdf_file,a:source,a:line,a:col,a:build_dir)
	elseif a:viewer == 'vectorsnap'
		call <SID>VectorSnap_SynctexForward(a:pdf_file,a:source,a:line,a:col,a:build_dir)
	elseif a:viewer == 'sumatra'
		call <SID>SumatraSynctexForward(a:pdf_file,a:source,a:line,a:col,a:build_dir)
	endif
endfunction
"}}}

function! s:GetPDFViewer(pdf_file)"{{{ Detect which viewer is opening 
	let l:pdf = fnamemodify(a:pdf_file, ':t')

		" Get all running processes.
		let l:processes = systemlist('ps -eo comm=,args=')

		" Viewer process names and returned identifiers.
		let l:viewers = [
					\ ['zathura',    'zathura'],
					\ ['VectorSnap', 'vectorsnap'],
					\ ['evince',     'evince'],
					\ ['okular',     'okular'],
					\ ['atril',      'atril'],
					\ ['mupdf',      'mupdf'],
					\ ]

		for l:process in l:processes
			" Check whether the process belongs to a supported viewer.
			for l:viewer in l:viewers
				if l:process =~? '\V' . l:viewer[0]
					" Check whether this process is opening this PDF.
					if stridx(l:process, l:pdf) >= 0 
						return l:viewer[1]
					endif
				endif
			endfor
		endfor

	return ''
endfunction
"}}}
function! s:CopyFile(src, dst) "{{{
	if has('win32') || has('win64')
		let l:ps_cmd = printf('powershell -NoProfile -Command "Copy-Item -LiteralPath ''%s'' -Destination ''%s'' -Force"', a:src, a:dst)
		call system(l:ps_cmd)
	else
		call system('cp ' . shellescape(a:src) . ' ' . shellescape(a:dst))
	endif
endfunction
""}}}
function! s:IsFileLocked(pdf_file) ""{{{
    " 如果文件根本不存在，肯定没被占用
    if !filereadable(a:pdf_file)
        return v:false
    endif
    
    " 核心技巧：尝试把文件重命名为它自己（相当于一次轻量级的文件独占测试）
    " 如果文件被 Adobe 等程序以独占读写方式死死锁住，rename() 会失败并返回非 0
    let l:res = rename(a:pdf_file, a:pdf_file)
    if l:res != 0
        return v:true  "被占用
    endif
    
    return v:false     "未被占用
endfunction
""}}}
function! s:KillAdoble(pdf_file) "{{{
		let kill_adobe_cmd = 'powershell -Command "'
					\ . '$pdf=\"' . a:pdf_file . '\";'
					\ . 'try {'
					\ . '  $fs = [System.IO.File]::Open($pdf,\"Open\",\"ReadWrite\",\"None\");'
					\ . '  $fs.Close();'
					\ . '} catch {'
					\ . '  Get-Process Acrobat,AcroRd32 -ErrorAction SilentlyContinue | Stop-Process -Force;'
					\ . '}"'
		silent! call system(kill_adobe_cmd)
endfunction
""}}}

"{{{function! s:TeXCompileCloseHandler
function! s:TeXCompileCloseHandler(pdfviewer,proj_dir,pdf_file,source,line,col,out_dir,...) 	
	"call setqflist([], 'r', {'lines': b:tex_compile_output, 'efm': &l:efm})
	let l:save_cwd = getcwd()
	try
		execute 'cd ' . fnameescape(a:proj_dir)
		call setqflist([], 'r', { 'lines': b:tex_compile_output, 'efm': s:tex_efm})
	finally
		execute 'cd ' . fnameescape(l:save_cwd)
	endtry
	let b:tex_compile_output = [] " 清空缓存

	let l:qflist = getqflist()
	"let ctx = getqflist({'context': 1}).context
	if empty(l:qflist)
		cclose
		echom "successfully compiled"
		let l:out_dir = trim(a:out_dir)
		if l:out_dir !=# ''
			let l:pdf_name = fnamemodify(a:pdf_file, ':t')
			let l:src_pdf = fnamemodify(a:proj_dir . '/' . a:out_dir . '/' . l:pdf_name, ':p')
			let l:dst_pdf = fnamemodify(a:pdf_file, ':p')

			let l:src_synctex = fnamemodify(l:src_pdf, ':r') . '.synctex.gz'
			let l:dst_synctex = fnamemodify(a:pdf_file, ':r') . '.synctex.gz'
			if filereadable(l:src_synctex)
				call s:CopyFile(l:src_synctex, l:dst_synctex)
			endif
			if filereadable(l:src_pdf)
				call s:CopyFile(l:src_pdf, l:dst_pdf)
			endif
		endif
		if !empty(a:pdfviewer)
			silent! call <SID>TeXViewPDF(a:pdfviewer,a:pdf_file,a:source,a:line,a:col,a:out_dir)
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
function! s:TeXCompileOutHandler(job_id, msg,...)"{{{OutHandler
	if type(a:msg) == v:t_list
		call extend(b:tex_compile_output, a:msg)
	else
		call add(b:tex_compile_output, a:msg)
	endif
endfunction
function! s:TeXCompileOutHandler_Old(job_id, msg,...) "这个版本会导致编译时光标闪烁
	if has("nvim")
		call setqflist([], 'a', {'lines': a:msg, 'efm': s:tex_efm})
	else
		call setqflist([], 'a', {
					\ 'lines': [a:msg],
					\ 'efm': s:tex_efm, 
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

"{{{ RunLaTeX_job(file,dir,engine,viewer) 
function! RunLaTeX_job(tex_file,proj_dir,engine,viewer,track_source,track_line,track_col, out_dir)
	let pdf_file = fnamemodify(a:tex_file,':p:r').'.pdf'
	"切换编译时候的工作目录，错误转跳的时候需要用到
	execute 'silent! lcd ' . fnameescape(a:proj_dir) 
	let l:out_prm = ''
	let l:out_dir = trim(a:out_dir)
	if l:out_dir !=# ''
			let l:out_prm = ' -output-directory="' . l:out_dir . '"'
	endif
	"if has('unix')
	"	let tex_cmd = 'cd ' . fnameescape(a:proj_dir) . ' && ' . a:engine . ' '
	"				\ . b:tex_engine_options . l:out_prm . ' ' . fnameescape(a:tex_file)
	"	let cmd = ['/bin/sh', '-c', tex_cmd]
	"elseif has('win32') || has('win64')
	"	let tex_cmd = 'cd /d ' . fnameescape(a:proj_dir) . ' && ' . a:engine . ' '
	"				\ . b:tex_engine_options . l:out_prm . ' ' . fnameescape(a:tex_file)
	"	let cmd = &shell . ' /c ' . tex_cmd
	"	let current_viewer = s:GetPDFViewer(pdf_file)
	"	if current_viewer ==# 'adobe'
	"		silent! call <SID>KillAdoble(pdf_file)
	"	endif
	"endif
	let tex_cmd_opt = s:cmd_cd . ' ' . fnameescape(a:proj_dir) . ' && '
				\ . a:engine . ' ' . b:tex_engine_options . l:out_prm . ' ' 
				\ . fnameescape(a:tex_file)
	let cmd = s:tex_cmd_term + [tex_cmd_opt]
	call setqflist([])
	if has("nvim")
		let job_options = {
					\ 'cwd': fnameescape(a:proj_dir),
					"\ 'on_stderr': function('s:TeXCompileOutHandler'),
					\ 'on_stdout': function('s:TeXCompileOutHandler'),
					\ 'on_exit': function('s:TeXCompileCloseHandler', 
					\ [a:viewer,a:proj_dir,pdf_file,a:track_source,a:track_line,a:track_col,a:out_dir]),
					\ }
		let b:run_tex_job = jobstart(cmd, job_options)
	else
		let job_options = {
					\ 'cwd': fnameescape(a:proj_dir),
					\ 'out_io': 'pipe',
					\ 'out_cb': function('s:TeXCompileOutHandler'),
					\ 'close_cb': function('s:TeXCompileCloseHandler',
					\ [a:viewer,a:proj_dir,pdf_file,a:track_source,a:track_line,a:track_col,a:out_dir]),
					\ }
		let b:run_tex_job = job_start(cmd, job_options)
	endif
endfunction
"}}}

""{{{ RunLaTeX(file,dir,engine,view)
function! RunLaTeX(tex_file,proj_dir,engine,viewer,source,line,col, out_dir)
	let dir_old = getcwd()
	let proj_dir = fnameescape(a:proj_dir)
	exec 'lcd ' . proj_dir
	"let pdf_file = fnamemodify(a:tex_file,':p:r').'.pdf'
	let l:out_prm = ''
	let l:out_dir = trim(a:out_dir)
	if l:out_dir !=# ''
		let l:out_prm = ' -output-directory=' . shellescape(l:out_dir)
		let pdf_file = a:dir . '/' . l:out_dir . '/' . fnamemodify(a:tex_file,':t:r') . '.pdf'
	else
		let pdf_file = fnamemodify(a:tex_file,':p:r').'.pdf'
	endif
	silent setlocal shellpipe=>
	call setqflist([]) " clear quickfix
	let makeprg_old = &makeprg
	"let &makeprg = a:engine.' '.b:tex_engine_options.' '.fnameescape(a:tex_file)
	let &makeprg = a:engine.' '.b:tex_engine_options . l:out_prm .' '.fnameescape(a:tex_file)
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
		if !empty(a:viewer)
			silent! call <SID>TeXViewPDF(a:viewer,pdf_file,a:source,a:line,a:col)
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
			if item =~ '^\s*\\\(setmainfont\|setCJKmainfont\)'
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
function! s:Compile_LaTeX_Run(engine,viewer,out_dir) 
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
		echomsg "No main tex file!"
		echohl None
		return ''
	endif

	"输出文件夹
	let l:clean_out_dir = trim(a:out_dir)
	if l:clean_out_dir !=# ''
		let l:full_out_path = b:tex_proj_dir . '/' . l:clean_out_dir
		if getftype(l:full_out_path) !=# 'dir'
			call mkdir(l:full_out_path, 'p')
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

	let pdf_file = fnamemodify(b:tex_main_file_name,':p:r').'.pdf'
	"	let pdf_name = fnamemodify(pdf_file, ':t')
	let pdfviewer = ''
	if has("win32") || has("win64")
		if s:IsFileLocked(pdf_file)
			silent! call <SID>KillAdoble(pdf_file)
		endif
		let pdfviewer = tolower(a:viewer)
	else
		if !exists('b:pdf_prog') || b:pdf_prog ==# ''
			let result = s:GetPDFViewer(pdf_file)
			if empty(result) && !empty(a:viewer)
				let pdfviewer = tolower(a:viewer)
				let b:pdf_prog = a:viewer
			else
				let pdfviewer = result
				let b:pdf_prog = result
			endif
		else
			let pdfviewer = b:pdf_prog
		endif
	endif


	""compile latex 
	echomsg "compiling with ".b:tex_engine."..."
	if has("nvim")
		silent! call RunLaTeX_job(
					\ b:tex_main_file_name,
					\ b:tex_proj_dir,
					\ b:tex_engine,
					\ pdfviewer,
					\ track_source,
					\ track_line,
					\ track_col,
					\ a:out_dir
					\ )
	else
		if v:version >= 801
			silent! call RunLaTeX_job(
						\ b:tex_main_file_name,
						\ b:tex_proj_dir,
						\ b:tex_engine,
						\ pdfviewer,
						\ track_source,
						\ track_line,
						\ track_col,
						\ a:out_dir
						\ )
		else
			silent! call RunLaTeX(
						\ b:tex_main_file_name,
						\ b:tex_proj_dir,
						\ b:tex_engine,
						\ pdfviewer,
						\ track_source,
						\ track_line,
						\ track_col,
						\ a:out_dir
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
function! s:CompileBibTeX(out_dir)
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
		let l:clean_out_dir = trim(a:out_dir)
		if l:clean_out_dir !=# ''
			if b:tex_bib_engine ==# 'biber'
				let l:bib_cmd = '!' . b:tex_bib_engine . ' --output-directory ' . shellescape(l:clean_out_dir) . ' ' . fnameescape(b:tex_proj_dir)
			else
				let l:bib_cmd = '!' . b:tex_bib_engine . ' ' . shellescape(l:clean_out_dir . '/' . b:tex_proj_dir)
			endif
		else
			let l:bib_cmd = '!' . b:tex_bib_engine . ' ' . fnameescape(b:tex_proj_dir)
		endif
		silent! exec l:bib_cmd
		exec 'lcd ' . fnameescape(current_dir)
		echo 'BibTeX compiled!'
	else
		echomsg "no main tex file!"
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

function! s:TeX_Compile_Paragraph(engine, viewer) "{{{
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
			silent call RunLaTeX_job(tmp_file,tmp_dir,b:tex_engine,a:viewer,
						\ tmp_source,tmp_line,tmp_col,'')
		else
			if v:version >= 801
				silent call RunLaTeX_job(tmp_file,tmp_dir,b:tex_engine,a:viewer,
							\ tmp_source,tmp_line,tmp_col,'')
			else
				silent call RunLaTeX(tmp_file,tmp_dir,b:tex_engine,a:viewer,
							\ tmp_source,tmp_line,tmp_col,'')
			endif
		endif
	endif
endfunction
"}}}

nnoremap <silent> <buffer><F2>  :call <SID>Compile_LaTeX_Run('auto',b:default_pdfviewer,'build')<CR>
nnoremap <silent> <buffer><S-F2>  :call <SID>Compile_LaTeX_Run('pdflatex',b:default_pdfviewer,'build')<CR>
nnoremap <silent> <buffer><C-F2>  :call <SID>Compile_LaTeX_Run('pdflatex',b:default_pdfviewer,'')<CR>
nnoremap <silent> <buffer><F6>  :call <SID>Compile_LaTeX_Run("xelatex",b:default_pdfviewer,'build')<CR> 
nnoremap <silent> <buffer><F8> :call <SID>CompileBibTeX('build')<CR>
nnoremap <silent> <buffer><C-c> : call <SID>TeXCancelJob()<CR>
nnoremap <silent> <buffer><F3> : call <SID>TeX_Compile_Paragraph('auto',b:default_pdfviewer)<CR>
"{{{ menu
menu 8000.60.040 &LaTeX.&DVI\ To\ PDF<tab><C-F6>  
			\ :call <SID>DviToPDF(expand("%:r").".dvi")<CR>
menu 8000.60.050 &LaTeX.&XeLaTeX<tab><F6> 
			\ :call <SID>Compile_LaTeX_Run("xelatex",b:default_pdfviewer,'')<CR>
menu 8000.60.060 &LaTeX.&pdfLaTeX<tab><S-F2> 
			\ :call <SID>Compile_LaTeX_Run("pdflatex",b:default_pdfviewer,'')<CR>
menu 8000.60.070 &LaTeX.&Compile\ BibTeX<tab><F8>		
			\ :call <SID>CompileBibTeX()<CR>
menu 8000.60.080 &LaTeX.&Compile\ Asy<tab><C-F8>		
			\ :call <SID>CompileAsy()<CR>
menu 8000.60.090 &LaTeX.&Compile\ Paragraph<tab><F3>		
			\ :call <SID>TeX_Compile_Paragraph('auto',b:default_pdfviewer)<CR>

"}}}
"
" vim:fdm=marker:noet:ff=unix
