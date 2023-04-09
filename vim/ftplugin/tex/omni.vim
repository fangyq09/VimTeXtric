"=============================================================================
" 	     File: omni.vim
"      Author: Yangqin Fang
"       Email: fangyq09@gmail.com
" 	  Version: 1.1 
"     Created: 06/04/2013
" 
"  Description: An omni completion of LaTeX
"=============================================================================
if exists('b:tex_omni')
	finish
endif

let b:tex_omni = 1
if has('unix')
	let b:glob_option = '\c'
else 
	let b:glob_option = ''
endif

function! s:NextCharsMatch(regex)
	let rest_of_line = strpart(getline('.'), col('.') - 1)
	return rest_of_line =~ a:regex
endfunction

let s:datadir=expand("<sfile>:p:h") ."/"
let s:tex_unicode =s:datadir . "completion/unicodemath.txt"
let s:tex_commands =s:datadir . "completion/commands.txt"
let s:tex_env_data =s:datadir . "completion/environments.txt"
let s:tex_packages_data =s:datadir . "completion/packages.txt"
let s:tex_fonts_data =s:datadir . "completion/fonts.txt"

inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

setlocal omnifunc=TEXOMNI
let s:completion_type = ''

function! TEXOMNI(findstart, base)  "{{{1
	if a:findstart
		" return the starting position of the word
		let line = getline('.')
		let pos = col('.') - 1
		while pos > 0 && line[pos - 1] !~ '\\\|{'
			let pos -= 1
		endwhile

		if line[pos - 1] == '\'
			let pos -= 1
		endif
		return pos
	else
		" return suggestions in an array
		let suggestions = []
		let text = getline(".")[0:col(".")-2]
		let curdir = expand("%:p:h")
		if escape(a:base, '\') =~ '^\\.*'
			" suggest known commands
			if filereadable(s:tex_commands) || filereadable(s:tex_unicode)
				let lines =extend(readfile(s:tex_commands),readfile(s:tex_unicode))
				for entry in lines
					if entry =~ '^' . escape(a:base, '\')
						call add(suggestions, entry)
					endif
				endfor
			endif
		elseif text =~ '\\\(begin\|end\)\_\s*{$'
			" suggest known environments
			if filereadable(s:tex_env_data)
				let lines = readfile(s:tex_env_data)
				for entry in lines
					if entry =~ '^' . escape(a:base, '\')
						if !s:NextCharsMatch('^}')
							let entry = entry . '}'
						endif
						call add(suggestions, entry)
					endif
				endfor
			endif
		elseif text =~ '\\set\(CJK\)\=\(main\|sans\|mono\|math\|family\)font\(\[[^\]]*\]\)*\_\s*{$'
			" suggest known environments
			if filereadable(s:tex_fonts_data)
				let lines = readfile(s:tex_fonts_data)
				for entry in lines
					if entry =~ '^' . escape(a:base, '\')
						if !s:NextCharsMatch('^}')
							let entry = entry . '}'
						endif
						call add(suggestions, entry)
					endif
				endfor
			endif
		elseif text =~ '\\\(usepackage\|RequirePackage\)\(\[[^\]]*\]\)*\_\s*{'
			"'\C\\usepackage\_\s*[$'
			" suggest known environments
			if filereadable(s:tex_packages_data)
				let lines = readfile(s:tex_packages_data)
				for entry in lines
					if entry =~ '^' . escape(a:base, '\')
						if !s:NextCharsMatch('^}')
							" add trailing '}'
							let entry = entry . '}'
						endif
						call add(suggestions, entry)
					endif
				endfor
			endif
		elseif text =~ '\\input\_\s*{$'
			let texfiles1 = glob(curdir.'/*.'.b:glob_option.'tex')
			let texfiles2 = glob(curdir.'/*/*.'.b:glob_option.'tex')
			let texfiles = split(texfiles1, '\n') + split(texfiles2, '\n')
			for tex in texfiles
				let tex_c = substitute(tex,"^".curdir."/","","") 
				if tex_c =~ '^'.a:base
					call add(suggestions,tex_c)
				endif
			endfor
		elseif text =~ '\\includegraphics\(\[[^\]]*\]\)*\_\s*{$'
			let searchstr = '\(pdf\|jpg\|jpeg\|png\|eps\)'
			let pictures1 = glob(curdir.'/*.'.b:glob_option.searchstr)
			let pictures2 = glob(curdir.'/*/*.'.b:glob_option.searchstr)
			let pictures = split(pictures1, '\n') + split(pictures2, '\n')
			for pic in pictures
				let pic_c = substitute(pic,"^".curdir."/","","")
				if pic_c =~ '^'.a:base
					call add(suggestions,"./".pic_c)
				endif
			endfor
		elseif text =~ '\\includepdf\(merge\)\=\(\[[^\]]*\]\)*\_\s*{$'
			let searchstr = '\(png\|jpg\|jpeg\|eps\|pdf\|bmp\)'
			"let pdffiles1 = globpath(curdir,searchstr)
			"let pdffiles2 = globpath(curdir,'*/'.searchstr)
			let pdffiles1 = glob(curdir.'/*.'.b:glob_option.searchstr)
			let pdffiles2 = glob(curdir.'/*/*.'.b:glob_option.searchstr)
			let pdffiles = split(pdffiles1, '\n') + split(pdffiles2, '\n')
			for pdf in pdffiles
				let pdf_c = substitute(pdf,"^".curdir."/","","")
				if pdf_c =~ '^'.a:base
					call add(suggestions,"./".pdf_c)
				endif
			endfor
		endif
		if !has('gui_running')
			redraw!
		endif
		return suggestions
	endif
endfunction
"}}}1

" vim:fdm=marker:noet:ff=unix