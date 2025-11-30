"=============================================================================
" 	     File: omni.vim
"      Author: Yangqin Fang
"       Email: fangyq09@gmail.com
" 	  Version: 3.0 
"     Created: 06/06/2013
"     Revised: 11/04/2025
" 
"  Description: An omni completion for writing LaTeX in vim
"=============================================================================
if exists('b:loaded_vimtextric_omni')
	finish
endif
let b:loaded_vimtextric_omni = 1

if has("win32") || has("win64")
	set shellslash
endif 

let s:completiondatadir = expand('<sfile>:p:h') . "/completion/"

function! s:LoadOmniEnvData() "{{{
  let s:tex_env_data_file   = s:completiondatadir . "environments.txt"
  if filereadable(s:tex_env_data_file)
    let s:tex_env_data = readfile(s:tex_env_data_file)
  else
    let s:tex_env_data = []
  endif
endfunction
"}}}
function! s:LoadOmniComData() "{{{
  let s:tex_unicode_file    = s:completiondatadir . "unicodemath.txt"
  let s:tex_commands_file   = s:completiondatadir . "commands.txt"
  if filereadable(s:tex_commands_file)
    let s:tex_commands = readfile(s:tex_commands_file)
  else
    let s:tex_commands = []
  endif

  if filereadable(s:tex_unicode_file)
    let s:tex_unicode = readfile(s:tex_unicode_file)
  else
    let s:tex_unicode = []
  endif
endfunction
"}}}
function! s:LoadOmniPkgData() "{{{
  let s:tex_packages_data_file = s:completiondatadir . "packages.txt"
  if filereadable(s:tex_packages_data_file)
    let s:tex_packages_data = readfile(s:tex_packages_data_file)
  else
    let s:tex_packages_data = []
  endif
endfunction
"}}}
function! s:LoadOmniFontsData() "{{{
  let s:tex_fonts_data_file    = s:completiondatadir . "fonts.txt"
  if filereadable(s:tex_fonts_data_file)
    let s:tex_fonts_data = readfile(s:tex_fonts_data_file)
  else
    let s:tex_fonts_data = []
  endif
endfunction
"}}}

function! s:NextCharsMatch(regex)
	let rest_of_line = strpart(getline('.'), col('.') - 1)
	return rest_of_line =~ a:regex
endfunction

"{{{ Find the bibtex source
function! s:TeX_Find_BiB_Source()
	if !exists('b:tex_main_file_name') || (b:tex_main_file_name == '')|| !exists('b:tex_proj_dir')
		let [b:tex_main_file_name,b:tex_proj_dir] = tex#outils#GetMainTeXFile()
	endif
	let current_dir = expand("%:p:h")
	let bib_name = ''
	let bib_line_num = 0
	if b:tex_main_file_name ==# expand('%:p')
		let save_pos = getpos(".")
		call cursor(line('$'), 1)
		let bib_line_num = search('\s*\\\(bibliography\|addbibresource\)\s*{.*}','cbnw')
		if bib_line_num
			let biblio_line = getline(bib_line_num)
		endif
		call setpos('.',save_pos)
	elseif b:tex_main_file_name != ''
		let text = readfile(b:tex_main_file_name)
		for line in text
			if line =~ '\s*\\\(bibliography\|addbibresource\)'
				let biblio_line = line
				let bib_line_num = 1
			endif
		endfor
	endif
	if bib_line_num
		let bib_name = matchstr(biblio_line, '.*{\zs.*\ze\s*}')
		let bib_name = split(bib_name,',')
	endif
	return bib_name
endfunction
""bibtex source file
"}}}

"{{{ Find bib items.
function! s:TeX_Find_bibref_items(pattern,file,dir,type)
	let result = []
	let sub_res = []
	execute 'lcd'. fnameescape(a:dir)
	if a:file =~? '\.bib$'
		let bib_file = readfile(a:file)
	endif
	call setqflist([]) " clear quickfix
	exec 'silent! vimgrep! "'.a:pattern.'"j '.a:file
	for i in getqflist()
		let itext = i.text
		let itext = substitute(itext,'\s\+',' ','g')
		let ifilename = bufname(i.bufnr)
		if a:file =~? '\.bib$'
			let next_line = bib_file[i.lnum]
			let next_line2 = bib_file[i.lnum + 1]
			let next_line = substitute(next_line,'\s\+',' ','g')
			let next_line2 = substitute(next_line2,'\s\+',' ','g')
			let app_line_add = next_line.' '.next_line2
		else
			let app_line_add = ''
		endif
		if a:type == 'cite'
			let prefix = matchstr(itext,'^.*{\s*\zs.*\ze\s*,\s*')
		elseif a:type == 'ref'
			let prefix = matchstr(itext,'\\label\s*{\s*\zs.*\ze\s*}')
		endif
		call add(result,[prefix,itext.' '.app_line_add,ifilename])
	endfor
	return result
endfunction
"}}}


setlocal omnifunc=TEXOMNI
"let s:completion_type = ''

function! TEXOMNI(findstart, base)  "{{{1
	"------------------------
	let line = getline('.')
	let l:current_cwd = getcwd()
	if a:findstart
		" return the starting position of the word
		let pos = col('.') - 1
		while pos > 0 && line[pos - 1] !~ '\(\\\|{\|\[\|,\|=\|\s\)'
			let pos -= 1
		endwhile

		if line[pos - 1] == '\'
			let pos -= 1
		endif
		return pos
	else
		" return suggestions in an array
		let current_dir = expand("%:p:h")
		let suggestions = []
		let text = getline(".")[0:col(".")-2]
		let com_prefix = escape(a:base, '\')
		if (com_prefix =~ '^\\.*')
			" suggest known commands
			if !exists('b:omni_com_data_loaded')
				call s:LoadOmniComData()
				let b:omni_com_data_loaded = 1
			endif
			let command_list = extend(copy(s:tex_commands),s:tex_unicode)
			for entry in command_list
				if entry =~ '^\s*' . com_prefix
					let item = entry
				elseif entry =~ '.*{\s*' . com_prefix
					let item = substitute(entry, '.\{-}{\s*\ze' . com_prefix, '', '')
				else
					let item = ''
				endif
				if item != ''
					let comments_pos = stridx(item, '%')
					if comments_pos == -1
						let command_cand = item
						let command_comments = ''
					else
						let command_cand = strpart(item, 0, comments_pos)
						let command_comments = strpart(item, comments_pos)
					endif
					let command_cand = trim(command_cand)
					call add(suggestions, {'word': command_cand, 'dup': 0, 'empty': 0,
								\ 'menu': command_comments})
				endif
			endfor
		elseif text =~ '\\\(begin\|end\)\s*{'
			"suggest known environments
			if !exists('b:omni_env_data_loaded')
				call s:LoadOmniEnvData()
				let b:omni_env_data_loaded = 1
			endif
			for entry in s:tex_env_data
				if entry =~ '^\s*' .  com_prefix
					if !s:NextCharsMatch('}')
						let entry = entry . '}'
					endif
					call add(suggestions, entry)
				endif
			endfor
		elseif text =~ '\\set\(CJK\)\=\(main\|sans\|mono\|math\|family\)font\(\[[^\]]*\]\)*\s*\(\[\|{\)'
			"suggest known environments
			if !exists('b:omni_fonts_data_loaded')
				call s:LoadOmniFontsData()
				let b:omni_fonts_data_loaded = 1
			endif
			for entry in s:tex_fonts_data
				if entry =~ '^\s*' . a:base
					if !s:NextCharsMatch('}') && (text =~ '{'.a:base.'$')
						let entry = entry . '}'
					endif
					call add(suggestions, entry)
				endif
			endfor
		elseif text =~ '\\\(usepackage\|RequirePackage\)\(\[[^\]]*\]\)*\s*{'
			" suggest known environments
			if !exists('b:omni_pkg_data_loaded')
				call s:LoadOmniPkgData()
				let b:omni_pkg_data_loaded = 1
			endif
			for entry in s:tex_packages_data
				if entry =~ '^\s*' . a:base
					call add(suggestions, entry)
				endif
			endfor
		elseif text.com_prefix =~ '\\\(input\|include\)\s*{'.com_prefix
			if !exists('b:tex_proj_dir') || (b:tex_proj_dir == '')
				let [b:tex_main_file_name,b:tex_proj_dir] = tex#outils#GetMainTeXFile()
			endif
			if b:tex_proj_dir != ''
				execute 'lcd'. fnameescape(b:tex_proj_dir)
				if com_prefix =~ '^\.\{2}'
					let texfiles1 = glob('../*.{tex,TEX}',0,1)
					let texfiles2 = glob('../*/*.{tex,TEX}',0,1)
				elseif com_prefix =~ '^\.'
					let texfiles1 = glob('./*.{tex,TEX}',0,1)
					let texfiles2 = glob('./*/*.{tex,TEX}',0,1)
				else
					let texfiles1 = glob('*.{tex,TEX}',0,1)
					let texfiles2 = glob('*/*.{tex,TEX}',0,1)
				endif
				let texfiles = texfiles1 + texfiles2
				for tex in texfiles
					if tex =~ '^'.a:base
						if !s:NextCharsMatch('}')
							let tex = tex . '}'
						endif
						call add(suggestions,tex)
					endif
				endfor
			endif
		elseif text =~ '\\include\(graphics\|pdf\|pdfmerge\|svg\)\(\[[^\]]*\]\)*\s*{'
			let searchstr = '\(pdf\|jpg\|jpeg\|png\|eps\|bmp\|svg\)'
			if !exists('b:tex_proj_dir') || (b:tex_proj_dir == '')
				let [b:tex_main_file_name,b:tex_proj_dir] = tex#outils#GetMainTeXFile()
			endif
			if b:tex_proj_dir != ''
				execute 'lcd'. fnameescape(b:tex_proj_dir)
				if com_prefix =~ '^\.\{2}'
					let all_files_1 = glob('../*.*', 0, 1) 
					let all_files_2 = glob('../*/*.*', 0, 1) 
					let pictures_1 = filter(all_files_1, 'v:val =~ ''\c\.' . searchstr . '$''')
					let pictures_2 = filter(all_files_2, 'v:val =~ ''\c\.' . searchstr . '$''')
				elseif com_prefix =~ '^\.'
					let all_files_1 = glob('./*.*', 0, 1) 
					let all_files_2 = glob('./*/*.*', 0, 1) 
					let pictures_1 = []
					let pictures_2 = []
					for f in all_files_1
						if f =~ '\c\.' . searchstr . '$'
							call add(pictures_1, f)
						endif
					endfor
					for f in all_files_2
						if f =~ '\c\.' . searchstr . '$'
							call add(pictures_2, f)
						endif
					endfor
				else
					let all_files_1 = glob('*.*', 0, 1) 
					let all_files_2 = glob('*/*.*', 0, 1) 
					let pictures_1 = filter(all_files_1, 'v:val =~ ''\c\.' . searchstr . '$''')
					let pictures_2 = filter(all_files_2, 'v:val =~ ''\c\.' . searchstr . '$''')
				endif
				let pictures = pictures_1 + pictures_2
				for pic in pictures
					if pic =~ '^'.a:base
						if !s:NextCharsMatch('}')
							let pic = pic . '}'
						endif
						call add(suggestions,pic)
					endif
				endfor
			endif
		elseif text.com_prefix =~ '\\\(\a\)*cite\(\a\)*\(\[[^\]]*\]\)*\s*{\([^}]\)*'.com_prefix
			if !exists('b:tex_bib_name')|| empty(b:tex_bib_name)
				let b:tex_bib_name = s:TeX_Find_BiB_Source()
			endif
			if !exists('b:tex_main_file_name')|| !exists('b:tex_proj_dir') 
				let [b:tex_main_file_name,b:tex_proj_dir] = tex#outils#GetMainTeXFile()
			endif
			let bib_pattern = '^\s*@.*{'.com_prefix
			if !empty(b:tex_bib_name)
				for fn in b:tex_bib_name
					let bib_source = fn
					if bib_source !~ '\.bib$'
						let bib_source = bib_source.'.bib'
					endif
					let bib_item_li = s:TeX_Find_bibref_items(bib_pattern,bib_source,b:tex_proj_dir,'cite')
					if len(bib_item_li)>0
						for bib_item in bib_item_li
							let key = bib_item[0]
							call add(suggestions, {'word': key, 'dup': 0, 'abbr': bib_item[1]})
						endfor
					endif
				endfor
			endif
		elseif text.com_prefix =~ '\\\(ref\|eqref\|pageref\|label\)\s*{'.com_prefix
			if exists('b:doc_class_line') && b:doc_class_line
				let file_name = expand("%:p:t")
			elseif search('^\s*\\documentclass','cnw')
				let file_name = expand("%:p:t")
			else
				let file_name = '*.tex'
			endif
			let label_pattern = '\\label\s*{'.com_prefix
			if !exists('b:tex_main_file_name')|| !exists('b:tex_proj_dir') 
				let [b:tex_main_file_name,b:tex_proj_dir] = tex#outils#GetMainTeXFile()
			endif
			let label_item_li = s:TeX_Find_bibref_items(label_pattern,file_name,b:tex_proj_dir,'ref')
			if text =~ '\\\(ref\|eqref\)\s*{'
				for label_item in label_item_li
					call add(suggestions, {'word': label_item[0], 'dup': 0,
								\ 'abbr': label_item[1], 'menu': label_item[2]})
				endfor
			else
				for label_item in label_item_li
					call add(suggestions, {'word': a:base, 'dup': 0, 'empty': 0,
								\ 'abbr': label_item[1], 'menu': label_item[2]})
				endfor
			endif
		else
			if !exists('b:omni_com_data_loaded')
				call s:LoadOmniComData()
				let b:omni_com_data_loaded = 1
			endif
			let command_list = extend(copy(s:tex_commands),s:tex_unicode)
			for entry in command_list
				if entry =~ '.*\(\\\|{\|\[\)\s*' . com_prefix
					let item = substitute(entry, 
								\ '.\{-}\(\\\|{\|\[\)\s*\ze' . com_prefix, '', '')
					let comments_pos = stridx(item, '%')
					if comments_pos == -1
						let command_cand = item
						let command_comments = ''
					else
						let command_cand = strpart(item, 0, comments_pos)
						let command_comments = strpart(item, comments_pos)
					endif
					let command_cand = trim(command_cand)
					call add(suggestions, {'word': command_cand, 'dup': 0, 'empty': 0,
								\ 'menu': command_comments})
				endif
			endfor
		endif
		execute 'lcd'. fnameescape(l:current_cwd)
		if !has('gui_running')
			redraw!
		endif
		return suggestions
	endif
endfunction
"}}}1

" vim:fdm=marker:noet:ff=unix
