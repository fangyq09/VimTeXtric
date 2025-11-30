if exists("g:loaded_tex_outils")
    finish
endif
let g:loaded_tex_outils = 1

function! tex#outils#Vimgrep(filename,pattern) "{{{1
	let fns = []
	let result = []
	call setqflist([]) " clear quickfix
	exec 'silent! vimgrep! ?'.a:pattern.'?j '.a:filename
	for i in getqflist()
		call add(fns,bufname(i.bufnr))
	endfor 
	return fns
endfunction
"}}}

function! tex#outils#GetCommonItems(list1,list2) "{{{1
	let result = []
	for item in a:list1
		if count(a:list2,item) >0
			call add(result,item)
		endif
	endfor
	return result
endfunction
"}}}

function! s:tex_Prompt(path,file)"{{{
	let mtf1 = tex#outils#Vimgrep(a:path.'/*.tex','^\s*\\documentclass')
	let mtf2 = tex#outils#Vimgrep(a:path.'/*.tex','^\s*\\\(input\|include\){\s*'.a:file.'\s*}')
	let mtf_common = tex#outils#GetCommonItems(mtf1,mtf2)
	if len(mtf_common)==1
		call add(mtf_common,a:path)
		return mtf_common
	elseif len(mtf_common)>1
		let output = map(copy(mtf_common),'fnamemodify(v:val, ":t")')
		let num_output = []
		for ii in range(len(output))
			call add(num_output,string(ii+1).'.'.output[ii])
		endfor
		call inputsave()
		let file_choose = inputdialog("Please choose main tex file [".join(num_output,'; ')."]: ",1,0)
		call inputrestore()
		if (file_choose < 1) || (file_choose > len(output_new))
			return ['','']
		else
			let file_name = mtf_common[file_choose-1]
			return [file_name, a:path]
		endif
	else
		return ['','']
	endif
endfunction
"}}}

function! s:tex_SearchMainTeXFile() "{{{
	let cur_dir = expand('%:p:h')
	let cur_file_name = expand('%:p')
	let par_dir = expand('%:p:h:h')
	let projdirpath = fnameescape(cur_dir)
	let OrBuNa=fnameescape(expand('%:p:t'))
	let output = s:tex_Prompt(projdirpath,OrBuNa)
	if output[0] == ''
		"go to the parent dir
		let dir_path = fnameescape(par_dir)
		let file_name_keep = substitute(cur_file_name,par_dir.'/','','')
		let stfn = fnameescape(file_name_keep)
		let output = s:tex_Prompt(dir_path,stfn)
	endif
	return output
endfunction
"}}}

function! tex#outils#GetMainTeXFile() "{{{
		let save_cursor = getpos(".")
		let view = winsaveview()
		call cursor(1, 1)
		if search('^\s*\\documentclass','cnw')
			let main_tex_file = expand('%:p')
			let main_tex_dir = expand('%:p:h')
			let main_tex = [main_tex_file,main_tex_dir]
		else
			let main_tex = s:tex_SearchMainTeXFile()
		endif
		call setpos('.', save_cursor)
		call winrestview(view)
	return main_tex
endfunction
"}}}

function! tex#outils#JumpToLine(file, line)
  let l:buf = bufnr(a:file, 1)
  execute 'buffer' l:buf
  call cursor(a:line, 1)
endfunction

function! tex#outils#OpenTexAndJump(file, line)
  let l:path = fnamemodify(a:file, ':p')
  let l:bufnr = bufnr(l:path, 1)
  call bufload(l:bufnr)
  execute 'buffer' l:bufnr
  call cursor(a:line, 1)
endfunction

function! tex#outils#ismath(zname)
  return match(map(synstack(line('.'), max([col('.') - 1, 1])),
        \ 'synIDattr(v:val, ''name'')'), a:zname) >= 0 
endfunction

function! tex#outils#inmathzone(...) " {{{1
  return call('tex#outils#insyntax', ['texMathZone'] + a:000) 
endfunction

function! tex#outils#insyntax(name, ...) " {{{1
  " Get position and correct it if necessary
  let l:pos = a:0 > 0 ? [a:1, a:2] : [line('.'), col('.')]
  if mode() ==# 'i'
    let l:pos[1] -= 1
  endif
  call map(l:pos, 'max([v:val, 1])')

  " Check syntax at position
  return match(map(synstack(l:pos[0], l:pos[1]),
        \          "synIDattr(v:val, 'name')"),
        \      '^' . a:name) >= 0
endfunction

function! tex#outils#RLHI()
	call histdel("/", -1)
	let @/ = histget("/", -1)
endfunction

" vim:fdm=marker:noet:ff=unix



