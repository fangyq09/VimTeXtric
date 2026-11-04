" vimtex - LaTeX plugin for Vim
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com

if exists("b:loaded_vimtex_format")
	finish
endif
let b:loaded_vimtex_format = 1

setlocal formatexpr=Format_formatexpr()


function! Format_formatexpr() " {{{1
	if mode() =~# '[iR]' | return -1 | endif

	" Temporary disable folds and save view
	let l:save_view = winsaveview()
	let l:foldenable = &l:foldenable
	setlocal nofoldenable

	let l:top = v:lnum
	let l:bottom = v:lnum + v:count - 1
	let l:lines_old = getline(l:top, l:bottom)
	let l:tries = 5
	let s:textwidth = &l:textwidth == 0 ? 79 : &l:textwidth

	" This is a hack to make undo restore the correct position
	if mode() !=# 'i'
		normal! ix
		normal! x
	endif

	" Main formatting algorithm
	while l:tries > 0
		" Format the range of lines
		let l:bottom = s:format(l:top, l:bottom)

		" Ensure proper indentation
		if l:top < l:bottom
			silent! execute printf('normal! %sG=%sG', l:top+1, l:bottom)
		endif

		" Check if any lines have changed
		let l:lines_new = getline(l:top, l:bottom)
		let l:index = s:compare_lines(l:lines_new, l:lines_old)
		let l:top += l:index
		if l:top > l:bottom | break | endif
		let l:lines_old = l:lines_new[l:index : -1]
		let l:tries -= 1
	endwhile

	" Restore fold and view
	let &l:foldenable = l:foldenable
	call winrestview(l:save_view)

	" Set cursor at appropriate position
	execute 'normal!' l:bottom . 'G^'

	" Don't change the text if the formatting algorithm failed
	if l:tries == 0
		silent! undo
		echom 'Formatting of selected text failed!'
	endif
endfunction

" }}}1

" {{{1 Initialize module

let s:border_beginning = '\v^\s*%(' . join([
			\ '\\item',
			\ '\\task',
			\ '\\begin',
			\ '\\end',
			\ '\\chapter',
			\ '\\section',
			\ '\\subsection',
			\ '\\label',
			\ '\\use',
			\ '\\set',
			\ '\\new',
			\ '\\renew',
			\ '%(\\\[|\$\$)\s*$',
			\], '|') . ')'

let s:border_end = '\v^\s*\\%(' . join([
			\   '\\\*?',
			\   'clear%(double)?page',
			\   'linebreak',
			\   'section',
			\   'label',
			\   'new%(line|page)',
			\   'pagebreak',
			\ 	'use',
			\ 	'set',
			\ 	'new',
			\ 	'renew',
			\   '%(begin|end|chapter|section|subsection|label)\{[^}]*\}',
			\  ], '|') . ')(\s*%.*)?$'
			\ . '|^\s*%(\\\]|\$\$)\s*$'

" }}}1
function! s:tex_outils_inmathzone(...) " {{{1
  return call('s:tex_outils_insyntax', ['texMathZone'] + a:000) 
endfunction

function! s:tex_outils_insyntax(name, ...) " {{{1
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
"}}}
function! s:is_format_boundary(lnum) abort "{{{
    let l:line = getline(a:lnum)

    " Empty lines
    if l:line =~# '^\s*$'
        return 1
    endif

    " Display math delimiters
    if l:line =~# '^\s*\\\[\s*$'
                \ || l:line =~# '^\s*\\]\s*$'
                \ || l:line =~# '^\s*\$\$\s*$'
        return 1
    endif

    " LaTeX commands
    if l:line =~# '^\s*\\[A-Za-z@]\+'
        return 1
    endif

    " Comments
    if l:line =~# '%'
        return 1
    endif

    " Math syntax
    for l:col in range(1, strlen(l:line))
        if s:tex_outils_inmathzone(a:lnum, l:col)
            return 1
        endif
    endfor

    return 0
endfunction
"}}}
function! s:format(top, bottom) abort "{{{
    let l:segments = []
    let l:start = 0

    " First: identify all safe text segments
    for l:lnum in range(a:top, a:bottom)

        if s:is_format_boundary(l:lnum)

            if l:start > 0
                call add(l:segments, [l:start, l:lnum - 1])
                let l:start = 0
            endif

        elseif l:start == 0
            let l:start = l:lnum
        endif

    endfor

    " Last segment
    if l:start > 0
        call add(l:segments, [l:start, a:bottom])
    endif

    " Second: format from bottom to top
    let l:bottom = a:bottom

    for l:segment in reverse(l:segments)
        let l:bottom += s:format_build_lines(
                    \ l:segment[0], l:segment[1])
    endfor

    return l:bottom
endfunction
"}}}
function! s:format_build_lines(start, end) " {{{1
	"
	" Get the desired text to format as a list of words, but preserve the ending
	" line spaces
	"
	let l:text = join(map(getline(a:start, a:end),
				\ 'substitute(v:val, ''^\s*'', '''', '''')'), ' ')
	let l:spaces = matchstr(l:text, '\s*$')
	let l:words = split(l:text, ' ')
	if empty(l:words) | return 0 | endif

	"
	" Add the words in properly indented and formatted lines
	"
	let l:lnum = a:start-1
	let l:current = s:get_indents(indent(a:start))
	for l:word in l:words
		if strdisplaywidth(l:word) + strdisplaywidth(l:current) > s:textwidth
			call append(l:lnum, substitute(l:current, '\s$', '', ''))
			let l:lnum += 1
			let l:current = s:get_indents(indent(a:start))
		endif
		let l:current .= l:word . ' '
	endfor
	if l:current !~# '^\s*$'
		call append(l:lnum, substitute(l:current, '\s$', '', ''))
		let l:lnum += 1
	endif

	"
	" Append the ending line spaces
	"
	if !empty(l:spaces)
		call setline(l:lnum, getline(l:lnum) . l:spaces)
	endif

	"
	" Remove old text
	"
	silent! execute printf('%s;+%s delete', l:lnum+1, a:end-a:start)

	"
	" Return the difference between number of lines of old and new text
	"
	return l:lnum - a:end
endfunction

" }}}1
function! s:compare_lines(new, old) " {{{1
	let l:min_length = min([len(a:new), len(a:old)])
	for l:i in range(l:min_length)
		if a:new[l:i] !=# a:old[l:i]
			return l:i
		endif
	endfor
	return l:min_length
endfunction

" }}}1
function! s:get_indents(number) " {{{1
	return !&l:expandtab && &l:shiftwidth == &l:tabstop
				\ ? repeat("\t", a:number/&l:tabstop)
				\ : repeat(' ', a:number)
endfunction

" }}}1



" vim: fdm=marker sw=2
