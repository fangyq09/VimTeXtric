"=============================================================================
" 	     File: fold.vim
"      Author: Yangqin Fang
"       Email: fangyq09@gmail.com
" 	  Version: 3.0 
"     Created: 12/06/2023
"     Revised: 11/04/2025
" 
"  Description: A manual LaTeX fold plugin by analogy to syntax fold
"This plugin provides a LaTeX syntax fold similar to syntax folding. 
"It is similar to the folding scheme provided by latex-suite but is faster 
"and can avoid the side effects of nested environments.
"Don't set the value of  g:tex_fold_enabled in your vimrc, such as
"let g:tex_fold_enabled = 0
"or let g:tex_fold_enabled = 1
"because both of these setting will cause much slower.
"=============================================================================
"settings
if exists('g:tex_fold_enabled')
	unlet g:tex_fold_enabled
endif
if exists('g:vimtextric_fold_enabled') && (g:vimtextric_fold_enabled)
	finish
endif
if has("win32") || has("win64")
	set shellslash
endif 
"=============================================================================

if exists('b:loaded_vimtextric_folding') 
	finish
endif
let b:loaded_vimtextric_folding = 1

let save_cpo = &cpo
set cpo&vim
augroup VimTeXtric
	au VimTeXtric User VimTeXtricFileType 
				\ call TeX_Fold_Force()
augroup END

if !exists('g:tex_fold_envs_force')
	let g:tex_fold_envs_force = 1
endif
if !exists('g:tex_fold_chap_char')
    "let g:tex_fold_chap_char = '§'
    let g:tex_fold_chap_char = "\u00A7"
endif
if !exists('g:tex_fold_sec_char')
    "let g:tex_fold_sec_char = '●' 
    let g:tex_fold_sec_char = "\u25CF" 
endif
if !exists('g:tex_fold_subsec_char')
    let g:tex_fold_subsec_char = "\u2666"
endif
if !exists('g:tex_fold_env_char')
    "let g:tex_fold_env_char = '✎'
    let g:tex_fold_env_char = "\u270E"
endif
if !exists('g:tex_fold_override_foldtext')
    let g:tex_fold_override_foldtext = 1
endif

let s:tex_fold_envs_thm = [
			\ 'theorem',
			\ 'thm',
			\ 'prop',
			\ 'lem',
			\ 'cor',
			\ 'def',
			\ 'proof',
			\ 'remark',
			\ 'abstract',
			\ 'algorithm',
			\ 'example',
			\ 'exercise',
			\ 'problem',
			\ 'question', 
			\ 'solution',
			\ 'titlepage'
			\ ]
let s:tex_fold_envs_sp= [
			\ 'verbatim',
			\ 'biblist',
			\ 'thebibliography',
			"\ 'table',
			"\ 'tabular',
			"\ 'tabbing',
			"\ 'enumerate',
			"\ 'itemize',
			"\ 'description',
			"\ 'picture',
			"\ 'figure',
			"\ 'tikzpicture',
			"\ 'align',
			"\ 'array',
			"\ 'gather',
			\ 'lstlisting',
			\ 'tasks', 
			\ 'sthm',
			\ 'squote', 
			\ ] 
let s:tex_fold_sect_key_words = [
			\ 'part\W',
			\ 'chapter\W', 
			\ 'section\W', 
			\ 'subsection\W', 
			\ 'appendix\W',
			\ 'bibliography', 
			\ 'addbibresource', 
			\ 'begin\s*{\s*bibdiv',
			\ 'begin\s*{\s*biblist',
			\ 'begin\s*{\s*thebibliography',
			\ 'end\s*{\s*thebibliography',
			\ 'end\s*{\s*bibdiv', 
			\ 'end\s*{\s*biblist', 
			\ 'end\s*{\s*document\s*}'
			\ ]
let s:tex_fold_text_patterns = {
			\ 'chapter': ['^\s*\\chapter{\([^}]*\)\(}\)*', g:tex_fold_chap_char],
      \ 'section': ['^\s*\\section{\([^}]*\)\(}\)*', g:tex_fold_sec_char],
      \ 'subsection': ['^\s*\\subsection{\([^}]*\)\(}\)*', g:tex_fold_subsec_char],
      \ 'env': ['^\s*\(\\\[\)*\s*\\begin{\([^}]*\)}', g:tex_fold_env_char]
      \ }
let s:tex_fold_envs_names = s:tex_fold_envs_thm + s:tex_fold_envs_sp
let s:tex_env_names = join(s:tex_fold_envs_names,'\|')
let s:tex_env_patterns = '\(\(begin\|end\)\s*{\s*\('.s:tex_env_names.'\)\)'
let s:tex_sect_patterns = '\('.join(s:tex_fold_sect_key_words,'\|').'\)'


function! TeX_Fold_Force() "{{{
	if exists('b:vimtextric_fold_done')
		return
	endif
	let b:vimtextric_fold_done = 1
	if g:tex_fold_override_foldtext
		setlocal foldtext=TeXFoldText()
	endif
	setlocal fdm=manual
	normal! zE
	call TeX_doc_startup()
	call MakeTexFolds()
	call setqflist([]) " clear quickfix
	"normal! zv
endfunction
"}}}

function! TeX_doc_startup() "{{{1
	let save_cursor = getpos(".")
	call cursor(1, 1)
	let b:doc_class_line = search('^\s*\\documentclass','cW')
	let b:doc_begin_doc = search('^\s*\\begin\s*{\s*document\s*}','cW')

	if b:doc_class_line
		let tex_doc_class_line = getline(b:doc_class_line)
		let b:tex_doc_class = substitute(tex_doc_class_line,
					\ '\s*\\documentclass\(\[.*\]\)*{\([^}]*\)}.*','\2','')
	else
		let b:tex_doc_class = ''
	endif
	call setpos('.', save_cursor)
	let b:doc_name = expand("%:p")
	let b:doc_len = line('$')
endfunction
"}}}

function! TeXGetKeyLineList(file,pattern) "{{{1
	""return the list of key lines
	let rlist = []
	call setqflist([]) " clear quickfix
	exec 'silent! vimgrep! ?\c'.a:pattern.'?j '.escape(a:file,' \')
	for i in getqflist()
		call add(rlist,[i.lnum,i.text])
	endfor 
	return rlist
endfunction
"}}}1

function! TeXFoldText() "{{{1
    let fold_line = getline(v:foldstart)
		let ftxto = foldtext()
		let mas = matchstr(ftxto, '^[^:]*').': '
    if fold_line =~ '^\s*\\\(chapter\|section\|subsection\)'
			let fold_type = matchstr(fold_line,'\\\(chapter\|section\|subsection\)')
			let fold_type = substitute(fold_type,'\\','','')
			let [pattern, fold_symbol] = s:tex_fold_text_patterns[fold_type]
			let repl = mas . ' ' .fold_symbol. ' \1'
			let line = substitute(fold_line, pattern, repl, '') . ' '
			"let laba = ''
			return line
    elseif fold_line =~ '^\s*\(\\\[\)*\s*\\begin'
			let pattern = '^\s*\(\\\[\)*\s*\\begin{\([^}]*\)}'
			let repl = mas . ' ' . g:tex_fold_env_char . ' \2 '
			"if fold_line =~ '\\label'
			"	let laba = ''
			"else
			"let laba = matchstr(getline(v:foldstart + 1),'\\label{[^}]*}')
			"end
			let laba = substitute(getline(v:foldstart + 1),'^\s*','','')
			let line = substitute(fold_line, pattern, repl, '') . ' '
			return line . laba
		"elseif fold_line =~ '^\s*\\documentclass'
		else
			return mas . fold_line
		endif

endfunction
"}}}

function! TeXFoldBlock(name,list,start) "{{{1
	"return end position
	let list_len = len(a:list)
	if a:start == list_len-1
		let fold_start = a:list[a:start][0]
		let fold_start_line = a:list[a:start][1]
		if fold_start_line =~ '^\s*\\\(\(sub\)\?section\|chapter\)'
			let fold_end = b:doc_len
			if fold_end > fold_start
				exe fold_start.",".fold_end." fold"
			endif
		endif
		return a:start + 1
	elseif a:name == 'subsection'
		let fold_start=a:list[a:start][0]
		let end_pos = a:start+1
		while end_pos <= list_len-1
			let fold_end_line_attempt=a:list[end_pos][1]
			if fold_end_line_attempt =~ '^\s*\\'.s:tex_sect_patterns
				let fold_end = a:list[end_pos][0]-1
				break
			endif
			let end_pos = end_pos + 1
		endwhile
		if end_pos > list_len-1
			let fold_end = b:doc_len
		endif
		exe fold_start.",".fold_end." fold"
		return end_pos
	elseif a:name == 'section'
		let fold_start = a:list[a:start][0]
		let fold_end_line_attempt = a:list[a:start+1][1]
		if fold_end_line_attempt =~ '^\s*\\subsection'
			let start_new = a:start + 1
			while start_new <= list_len - 1
				if a:list[start_new][1] =~ '^\s*\\subsection'
					let start_new =  TeXFoldBlock('subsection',a:list,start_new)
				else
					break
				endif
			endwhile
			if start_new <= list_len - 1
				let fold_end = a:list[start_new][0]-1
			else
				let fold_end = b:doc_len
			endif
			let end_pos = start_new
			if (a:start > 0) || (end_pos < list_len-1)
				exe fold_start.",".fold_end." fold"
			endif
		elseif fold_end_line_attempt =~ '^\s*\\'.s:tex_sect_patterns
			let fold_end=a:list[a:start+1][0]-1
			let end_pos=a:start+1
			exe fold_start.",".fold_end." fold"
		endif
		return end_pos
	elseif a:name == 'chapter'
		let fold_start = a:list[a:start][0]
		let fold_end_line_attempt=a:list[a:start+1][1]
		if fold_end_line_attempt =~'^\s*\\\(sub\)\?section'
			let start_new = a:start+1
			let start_new_line = a:list[a:start+1][1]
			while start_new <= list_len-1
				if start_new_line =~ '^\s*\\section'
					let block_name = 'section'
				else
					let block_name = 'subsection'
				endif
				let next_step =  TeXFoldBlock(block_name,a:list,start_new)
				let start_new = next_step
				let start_new_line = a:list[start_new][1]
				if start_new_line !~ '^\s*\\\(sub\)\?section'
					break
				endif
			endwhile
			if start_new <= list_len -1
				let fold_end = a:list[next_step][0]-1
			else
				let fold_end = b:doc_len
			endif
			let end_pos = start_new
			if (a:start > 0) || (end_pos < list_len-1)
				exe fold_start.",".fold_end." fold"
			endif
			return end_pos
		else
			let fold_end=a:list[a:start+1][0]-1
			let end_pos=a:start+1
			exe fold_start.",".fold_end." fold"
			return end_pos
		endif
	endif
endfunction
"}}}

function! TeXFoldEnv(name,list,start) "{{{1
	let list_len = len(a:list)
	if a:start == list_len
		return list_len-1
	endif
	let fold_start_attempt = a:list[a:start][1]
	let start_pos = a:start
	while start_pos < list_len-1
		if fold_start_attempt =~ '^\s*\\begin\s*{\s*'.a:name
			let fold_start = a:list[start_pos][0]
			break
		else
			let start_pos = start_pos+1
		endif
	endwhile
	let is_fold_env_end = 0
	if start_pos < list_len-1
		let end_pos = start_pos+1
		while is_fold_env_end == 0
			let fold_end_attempt_line = a:list[end_pos][1]
			if fold_end_attempt_line =~ '^\s*\\end\s*{\s*'.a:name
				let is_fold_env_end = is_fold_env_end+1
			elseif fold_end_attempt_line =~ '^\s*\\begin\s*{\s*'.a:name
				let is_fold_env_end = is_fold_env_end-1
			elseif fold_end_attempt_line =~ '^\s*\\'.s:tex_sect_patterns
				break
			endif
			if ((is_fold_env_end == 1) || (end_pos >= list_len-1))
				break
			else
				let end_pos = end_pos + 1
			endif
		endwhile
	endif
	if (is_fold_env_end == 1)
		let fold_end = a:list[end_pos][0]
		exe fold_start.",".fold_end." fold"
	elseif a:start < list_len-1
		let start_point = a:start+1
		let new_name = ''
		while start_point < list_len-1
			let start_item = a:list[start_point][1]
			if start_item =~ '^\s*\\begin\s*{\s*'
				let new_name = substitute(start_item,
							\ '\s*\\begin\s*{\s*\([^}]*\)}.*','\1','')
				break
			endif
			let start_point = start_point+1
		endwhile
		if !empty(new_name)&&(start_point<list_len-1)
			let end_pos = TeXFoldEnv(new_name,a:list,start_point)
		else
			let end_pos = list_len-1
		endif
	endif
	return end_pos
endfunction
"}}}

function! MakeTexFolds() "{{{
	if b:tex_doc_class == 'beamer'
		let fold_start_preamble = b:doc_class_line
		let fold_end_preamble =  b:doc_begin_doc
		if fold_end_preamble
			let fold_end_preamble = fold_end_preamble - 1
			exe fold_start_preamble.",".fold_end_preamble." fold"
		endif
		let s:tex_fold_beamer_key_lines = TeXGetKeyLineList(b:doc_name,
					\ '^\s*\\\(begin\|end\)\s*{\s*frame\s*}')	
		let b:tex_fold_beamer_key_lines_len=len(s:tex_fold_beamer_key_lines)
		if b:tex_fold_beamer_key_lines_len>1
			let fold_count=0
			while fold_count < b:tex_fold_beamer_key_lines_len-1
				let fold_start_line = s:tex_fold_beamer_key_lines[fold_count][1]
				if fold_start_line =~ '\s*\\begin\s*{\s*'
					let env_name = substitute(fold_start_line,
								\ '\s*\\begin\s*{\s*\([^}]*\)}.*','\1','')
					let end_pos = TeXFoldEnv(env_name,s:tex_fold_beamer_key_lines,fold_count)
					let fold_count = end_pos
				else
					let fold_count = fold_count + 1
				endif
			endwhile
		endif
	else
		if g:tex_fold_envs_force
			let s:tex_fold_env_key_lines = TeXGetKeyLineList(b:doc_name,
						\ '^\s*\\\(begin\|end\)\s*{\s*\('.join(s:tex_fold_envs_names,'\|').'\)')
			let b:tex_fold_env_key_lines_len=len(s:tex_fold_env_key_lines)
			if b:tex_fold_env_key_lines_len>1
				let fold_count=0
				while fold_count < b:tex_fold_env_key_lines_len-1
					let fold_start_line = s:tex_fold_env_key_lines[fold_count][1]
					if fold_start_line =~ '^\s*\\begin\s*{\s*'
						let env_name = substitute(fold_start_line,
									\ '^\s*\\begin\s*{\s*\([^}]*\)}.*','\1','')
						let fold_count = TeXFoldEnv(env_name,s:tex_fold_env_key_lines,fold_count)
					else
						let fold_count = fold_count + 1
					endif
				endwhile
			endif
		endif

		"let tex_patterns = '^\s*\\\('.s:tex_sect_patterns.'\|'.s:tex_env_patterns.'\)'
		"let s:tex_fold_key_lines = TeXGetKeyLineList(b:doc_name,tex_patterns)
		let s:tex_fold_key_lines =TeXGetKeyLineList(b:doc_name,'^\s*\\'.s:tex_sect_patterns)
		if b:doc_class_line && b:doc_begin_doc && (b:doc_class_line < b:doc_begin_doc)
			let fold_start_preamble = b:doc_class_line
			let fold_end_preamble =  b:doc_begin_doc - 1
			exe fold_start_preamble.",".fold_end_preamble." fold"
		endif
		let b:tex_fold_key_lines_len = len(s:tex_fold_key_lines)
		if b:tex_fold_key_lines_len>1
			let fold_count = 0
			while fold_count <= b:tex_fold_key_lines_len-1
				let fold_start_line=s:tex_fold_key_lines[fold_count][1]
				if fold_count == b:tex_fold_key_lines_len-1
					if (fold_start_line !~ '^\s*\\end\s*{\s*document')&&
								\ (fold_start_line =~ '^\s*\\'.s:tex_sect_patterns)
						let fold_start = s:tex_fold_key_lines[fold_count][0]
						let fold_end = b:doc_len
						exe fold_start.",".fold_end." fold"
						break
					endif
					let fold_count=fold_count+1
				"elseif fold_start_line=~'^\s*\\documentclass'
				"	let fold_start = s:tex_fold_key_lines[fold_count][0]
				"	let fold_end = s:tex_fold_key_lines[fold_count+1][0]-1
				"	exe fold_start.",".fold_end." fold"
				"	let fold_count=fold_count+1
				elseif fold_start_line=~'^\s*\\subsection'
					let next_pos = TeXFoldBlock('subsection',s:tex_fold_key_lines,fold_count)
					let fold_count = next_pos
				elseif fold_start_line=~'^\s*\\section'
					let next_pos = TeXFoldBlock('section',s:tex_fold_key_lines,fold_count)
					let fold_count = next_pos
				elseif fold_start_line=~'^\s*\\chapter'
					let next_pos = TeXFoldBlock('chapter',s:tex_fold_key_lines,fold_count)
					let fold_count = next_pos
				else
					let fold_count=fold_count+1
				endif
			endwhile
		endif
	endif
endfunction
"}}}

silent! do VimTeXtric User VimTeXtricFileType

let &cpo = save_cpo

" vim:fdm=marker:noet:ff=unix
