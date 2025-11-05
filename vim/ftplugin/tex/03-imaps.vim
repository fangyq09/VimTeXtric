"=============================================================================
" 	     File: imaps.vim
"      Author: Yangqin Fang
"       Email: fangyq09@gmail.com
" 	  Version: 1.5 
"     Created: 11/06/2013
" 
"  Description: An imaps plugin for LaTeX
"  put it into ~/.vim/ftplugin/tex/
"  1. In the insert mode, typed any prefix, press <C-l>, you will get a
"  commands or an environment input. Please see s:MapsDict, s:Maps_commands_abbrv
"  and s:Maps_envs_abbrv for the list of abbreviation
"  2. In the insert mode, if you type ^^, it will give ^{} and the cursor
"  inside the curly brace, if you type `/, it will give \frac{}{} and the
"  cursor inside the first curly brace. The behavior is simlar to
"  latex-suite's. Indeed, the TEXIMAP() function is borrowed from the 
"  latex-suite plugin.
"  3. In the insert mode, press <C-i>, type and env name, you will get an env
"  input. See s:KeyWDict for the list.
"  4. I suggest y u do not set "set showmatch" in your vimrc, it will cause a
"  lot delay when typing (),{},[].
"=============================================================================

if exists("b:loaded_vimtextric_imaps")
	finish
endif
let b:loaded_vimtextric_imaps = 1

"{{{ envs
let s:MapsEnvDict = {
			\ 'align' : join(['\begin{align}','<++>&\\','&','\end{align}'],"\n"),
			\ 'aligned' : join(['\begin{aligned}','<++>&\\','&','\end{aligned}'],"\n"),
			\ 'array' : join(['\begin{array}{<++>}','\end{array}'],"\n"),
			\ 'cas' : join(["\\begin{cases}","<++>","\\end{cases}"],"\n"),
			\ 'numcases' : join(["\\begin{numcases}{<++>}","\\end{numcases}"],"\n"),
			\ 'CJK' : join(["\\begin{CJK*}{UTF8}{gbsn}","\\end{CJK*}"],"\n"),
			\ 'enumerate' : join(["\\begin{enumerate}[label={(\\arabic*)}]",
													\ "\\item <++>","\\end{enumerate}"], "\n"),
			\ 'equation' : join(['\begin{equation}\label{<++>}','\end{equation}'],"\n"),
			\ 'figure' :  join(['\begin{figure}[H]','\centering',
												\ '\includegraphics[width=\textwidth]{<++>}',
												\ '\caption{}','\label{fig:}','\end{figure}'],"\n"),
			\ 'fig2' :  join(['\begin{figure}[H]','\centering',
											\ '\begin{subfigure}{0.4\textwidth}','\centering',
											\ '\includegraphics[width=\textwidth]{<++>}',
											\ '\caption{}','\label{fig:}','\end{subfigure}',
											\ '\hspace{0.1\textwidth}',
											\ '\begin{subfigure}{0.4\textwidth}','\centering',
											\ '\includegraphics[width=\textwidth]{}',
											\ '\caption{}','\label{fig:}',
											\ '\end{subfigure}','\end{figure}'],"\n"),
			\ 'itemize' : join(['\begin{itemize}','\item <++>','\end{itemize}'],"\n"),
			\ 'lst' : join(['\begin{lstlisting}[language=bash,breaklines]','<++>',
										\ '\end{lstlisting}'],"\n"),
			\ 'm' : join(['\[','<++>','\]'],"\n"),
			\ 'multicols' : join(['\begin{multicols}{<++>}','\end{multicols}'],"\n"),
			\ 'minipage'  : join(['\begin{minipage}{<++>0.5\textwidth}',
													\ '\end{minipage}'],"\n"),
			\ 'pic'  : 	join(['\begin{center}',
											\ '\includegraphics[width=\textwidth]{<++>}',
											\ '\end{center}'],"\n"),
			\ 'table' : join(['\begin{table}','\centering',
											\ '\begin{tabular}{<++>}','\end{tabular}',
											\ '\caption{tab:}','\label{tab:}','\end{table}'],"\n"),
			\ 'tasks': join(['\begin{tasks}(<++>)','\task','\end{tasks}'],"\n"),
			\ 'tabular': join(['\begin{tabular}{<++>}','\end{tabular}'],"\n"),
			\ 'tikzpicture'  :  join(['\begin{tikzpicture}[thick, scale=2]','<++>',
														  \ '\end{tikzpicture}'],"\n"),
			\ }
"}}}

"{{{ commands
let s:MapsComDict = {
			\ 'av' : "\\left\\lvert\<++> \\right\\rvert",
			\ 'abs' : "\\lvert\<++> \\rvert",
			\ 'bb' : "\\mathbb{<++>}",
			\ 'bf' : "\\mathbf{<++>}",
			\ 'bk' : "\llbracket <++>\rrbracket",
			\ 'cal' : "\\mathcal{<++>}",
			\ 'cball' : "\\cball",
			\ 'cite' : "\\cite{<++>}",
			\ 'dfrac' : "\\dfrac{<++>}{}",
			\ 'ds' : "\\displaystyle",
			\ 'eqref' : "\\eqref{eq:<++>}",
			\ 'exp' : "\\exp\\left(<++>\\right)",
			\ 'frac' : "\\frac{<++>}{}",
			\ 'frak' : "\\mathfrak{<++>}",
			\ 'i' : "\\infty",
			\ 'int' : "\\int_{<++>}^{}",
			\ 'ip' : "\\langle <++> \\rangle",
			\ 'label' : "\\label{<++>}",
			\ 'lr' : "\\left<++>\\right",
			\ 'mbox'  : "\\mbox{<++>}",
			\ 'mr'  : "\\mathring{<++>}",
			\ 'norm' : "\\left\\lVert\<++> \\right\\rVert",
			\ 'overline'  : "\\overline{<++>}",
			\ 'overbrace'  : "\\overbrace{<++>}_{}",
			\ 'underbrace' : "\\underbrace{<++>}_{}",
			\ 'underline' : "\\underline{<++>}",
			\ 'p' : "\\partial",
			\ 'real' : "\\mathbb{R}",
			\ 'ref' : "\\ref{<++>}",
			\ 'rn' : "\\mathbb{R}^n",
			\ 'rm' : "\\mathbb{R}^m",
			\ 'r2' : "\\mathbb{R}^2",
			\ 'r3' : "\\mathbb{R}^3",
			\ 'rb' : "\\left(<++>\\right)",
			\ 'sb' : "\\left[<++>\\right]",
			\ 'scr' : "\\mathscr{<++>}",
			\ 'sm' : "\\setminus",
			\ 'sqrt' : "\\sqrt[<++>]{}",
			\ 'sub'  : "\\subseteq",
			\ 'sum'  : "\\sum_{<++>}^{}",
			\ 'suml' : "\\sum\\limits_{<++>}^{}",
			\ 'sup'  : "\\supseteq",
			\ 'text' : "\\text{<++>}",
			\ 'tw' : "\\textwidth",
			\ 'th' : "\\textsuperscript{th}",
			\ 'vli' : "\\varliminf_{<++>}",
			\ 'vls' : "\\varlimsup_{<++>}",
			\ 've' : "\\varepsilon",
			\ 'vt' : "\\vartheta",
			\ 'vr' : "\\varrho",
			\ 'vp' : "\\varphi",
			\ 'wh' : "\\widehat{<++>}",
			\ 'wt' : "\\widetilde{<++>}",
			\ 'x' : "\\times",
			\ 'alpha' : "\\alpha",
			\ 'beta' : "\\beta",
			\ 'gamma' : "\\gamma",
			\ 'delta' : "\\delta",
			\ 'epsilon' : "\\epsilon",
			\ 'zeta' : "\\zeta",
			\ 'theta' : "\\theta",
			\ 'kappa' : "\\kappa",
			\ 'lambda' : "\\lambda",
			\ 'nabla' : "\\nabla",
			\ 'sigma' : "\\sigma",
			\ 'upsilon' : "\\upsilon",
			\ 'omega' : "\\omega",
			\ 'Alpha'   : "\\Alpha",
			\ 'Beta'    : "\\Beta",
			\ 'Gamma'   : "\\Gamma",
			\ 'Delta'   : "\\Delta",
			\ 'Epsilon' : "\\Epsilon",
			\ 'Zeta'    : "\\Zeta",
			\ 'Theta'   : "\\Theta",
			\ 'Kappa'   : "\\Kappa",
			\ 'Lambda'  : "\\Lambda",
			\ 'Sigma'   : "\\Sigma",
			\ 'Upsilon' : "\\Upsilon",
			\ 'Omega'   : "\\Omega",
			\ '('   : "\\left(",
			\ ')'   : "\\right)",
			\ '(('   : '\left(<++>\right)',
			\ 'vect' : '\\overrightarrow',
			\ }
"}}}

"{{{ words abbrv
let s:Mapswordsabbrv = {
			\ 'lip'     : 'Lipschitz',
			\ 'ffp'     : 'Federer Fleming projection',
			\ 'st'      : 'such that',
			\ 'eun'     : '$\mathbb{R}^{n}$',
			\ 'lnr'     : 'Lipschitz neighborhood retract',
			\ 'nbh'     : 'neighborhood',
			\ 'nhb'     : 'neighborhood',
			\ 'cech'    : '\v{C}ech',
			\ 'holder'  : 'H\"older',
			\ }
"}}}

"{{{ commands abbrv
let s:Maps_commands_abbrv = {
			\ 'a' : 'alpha',
			\ 'b' : 'beta',
			\ 'd' : 'delta',
			\ 'df' : 'dfrac',
			\ 'D' : 'Delta',
			\ 'e' : 'epsilon',
			\ 'f' : 'frac',
			\ 'er' : 'eqref',
			\ 'g' : 'gamma',
			\ 'G' : 'Gamma',
			\ 'k' : 'kappa',
			\ 'l' : 'lambda',
			\ 'L' : 'Lambda',
			\ 'la' : 'label',
			\ 'le' : 'lemma',
			\ 'n' : 'nabla',
			\ 'o' : 'omega',
			\ 'O' : 'Omega',
			\ 'ob' : 'overbrace',
			\ 'ol' : 'overline',
			\ 'r' : 'real',
			\ 's' : 'sigma',
			\ 'S' : 'Sigma',
			\ 't' : 'theta',
			\ 'T' : 'Theta',
			\ 'tt' : 'text',
			\ 'u' : 'upsilon',
			\ 'ub' : 'underbrace',
			\ 'ul' : 'underline',
			\ 'U' : 'Upsilon',
			\ 'z' : 'zeta',
			\ }
"}}}

"{{{ envs abbrv
let s:Maps_envs_abbrv = {
			\ 'al' : 'align',
			\ 'ald' : 'aligned',
			\ 'ar' : 'array',
			\ 'athm' : 'algorithm',
			\ 'c' : 'center',
			\ 'cor' : 'corollary',
			\ 'conj' : 'conjecture',
			\ 'conc' : 'conclusion',
			\ 'def' : 'definition',
			\ 'enu' : 'enumerate',
			\ 'eq' : 'equation',
			\ 'exa' : 'example',
			\ 'exm' : 'example',
			\ 'exe' : 'exercise',
			\ 'dm' : 'displaymath',
			\ 'fig' : 'figure',
			\ 'ga' : 'gather*',
			\ 'gad' : 'gathered',
			\ 'item' : 'itemize',
			\ 'mc' : 'multicols',
			\ 'mp' : 'minipage',
			\ 'ncas' : 'numcases',
			\ 'pf' : 'proof',
			\ 'prob' : 'problem',
			\ 'prop' : 'proposition',
			\ 'ques' : 'question',
			\ 're' : 'remark',
			\ 'sol' : 'solution',
			\ 'state' : 'statement',
			\ 'thm' : 'theorem',
			\ 'tab' : 'tabular',
			\ 'tikz' : 'tikzpicture',
			\ 'bm' : 'bmatrix',
			\ 'pm' : 'pmatrix',
			\ 'vm' : 'vmatrix',
			\ }
"}}}

let s:MapsDict = extend(extend(copy(s:MapsEnvDict),s:MapsComDict),s:Mapswordsabbrv)
let s:Mapsabbrv = extend(copy(s:Maps_commands_abbrv),copy(s:Maps_envs_abbrv))

inoremap <buffer> <C-l>		 <C-r>=<SID>PutEnvironment()<CR>

function! s:PutEnvironment() "{{{
	let linenum = line(".")
	let colnum = col(".")-1
	let line_text = getline(".")
	let text_before = trim(line_text[0:colnum])
	let ttb_len = len(text_before)
	let stcn = colnum
	while stcn > 0
		let startp = strpart(line_text,stcn-1,1)
		"从非字母以及小括号的地方结束
		if startp =~ '[^0-9A-Za-z()]'
			break
		else
		let stcn = stcn - 1
		endif
	endwhile
	let word = strpart(line_text,stcn,colnum-stcn)
	"如果是以小括号结束，如果有left right前缀直接清空word
	if word =~ '\W'
		let word = substitute(word,'.*\(left(\|right)\)','','')
	endif
	if word != ''
		if (strcharpart(word, len(word) - 1) =~ '\w')
			"保留最后那串单词
			let	word = substitute(word, '.\{-}\(\w\+\)$', '\1', '')
		else
			"保留最后那串非单词字符
			let word = substitute(word, '.\{-}\(\W\+\)$', '\1', '')
		endif
		if has_key(s:Mapsabbrv,word)  
			let env =  get(s:Mapsabbrv,word)
		else
			let env = word
		endif
		""<C-g>u for an undo point
		"return "\<C-g>u\<C-r>=Tex_env_Debug('".word."','".env."')\<cr>"
		"return "\<C-g>u\<C-r>=Tex_env_Debug('".word."','".env."',".ttb_len.")\<cr>"
		return "\<C-g>u\<C-r>=" . expand('<SID>') .
					\ "Tex_env_Debug('" . word . "','" . env . "'," . ttb_len . ")\<CR>"
	else
		return ''
	endif
endfunction
"}}}

function! s:Tex_env_Debug(word,env,len) "{{{
	let bkspc = substitute(a:word, '.', "\<bs>", "g")
	if has_key(s:MapsDict,a:env)
		let rhs = get(s:MapsDict,a:env)
		if has_key(s:MapsEnvDict,a:env) && (a:len > len(a:word))
			let rhs = "\<cr>".rhs
		endif
	elseif (a:env !~ '\W') && (len(a:word) == a:len)
		let rhs= "\\begin{".a:env."}\<cr><++>\<cr>\\end{".a:env."}"
	elseif a:word =~ '.*)$'
		let rhs = strpart(a:env,0,len(a:env)-1)."\\right)"
	else
		let rhs = a:word
	endif
	if rhs =~  '<++>'
		let movement = "\<esc>:call\ search('<++>','bcW')\<cr>".'"_4s'
	else
		let movement = ''
	endif
	let events = rhs . movement
	return bkspc.events
endfunction
"}}}

""""==========================================================================

let s:TeX_IMAP_dict = {
			\ "__" : "_{<++>}",
			\ "^^" : "^{<++>}",
			\ "$$" : "$<++>$",
			\ "{}" : "{<++>}",
			\ "()" : "(<++>)",
			\ '\{' : "\\{<++>\\}",
			\ "`8" : "\\infty",
			\ "`9" : "\\subseteq",
			\ "`6" : "\\partial",
			\ '`\' : "\\setminus",
			\ '`e' : "\\emptyset",
			\ "[]" : "[<++>]",
			\ "`0" : "\\supseteq",
			\ }                
function! s:TEXIMAP()   "{{{
	if exists('b:teximap_done')
		return
	endif
	let b:teximap_done = 1
	let keys_list = keys(s:TeX_IMAP_dict)
	let lastchars_list = map(copy(keys_list),"v:val[-1:]")
	for char in lastchars_list
		exec 'inoremap <silent><buffer><nowait>'
					\ escape(char, '|')
					\ '<C-r>=<SID>LookupChar("' .
					\ escape(char, '\|"') .
					\ '")<CR>'
	endfor
endfunction
"}}}
function! s:LookupChar(char) "{{{
	let keys_list = keys(s:TeX_IMAP_dict)
	let text = strpart(getline("."), col(".") - 2, 1, v:true) . a:char
	let match_keys = filter(copy(keys_list),'v:val == text')
	if empty(match_keys)
		return a:char
	else
		let lhs = match_keys[0]
		let rhs = get(s:TeX_IMAP_dict,lhs)
		if (lhs == '$$') && (col(".") > &tw - 6) && (col(".") < &tw - 2)
			let rhs = "\<cr>".rhs
		endif
		let bs = substitute(strpart(lhs, 1), ".", "\<bs>", "g")
		if rhs =~  '<++>'
			let movement = "\<esc>:call\ search('<++>','bcW')\<cr>".'"_4s'
		else
			let movement = ''
		endif
		" \<c-g>u inserts an undo point
		return a:char . "\<c-g>u\<bs>" . bs . rhs . movement
	endif
endfunction
"}}}
call <SID>TEXIMAP()

"==========================================================================
function! s:PutTextWithMovement(str) "{{{1
	if a:str =~ '<++>'
		let movement = "\<esc>:call\ search('<++>','bcW')\<cr>".'"_4s'
	else
		let movement = ''
	endif
	return a:str.movement
endfunction
"}}}

"{{{let s:KeyWDict ={}
let s:KeyWDict = { 
			\ '()' : '\left(<++>\right)',
			\ '[]' : '\left[<++>\right]',
			\ '{}' : '\left\{<++>\right\}',
			\ '{' : '\{<++>\}',
			\ 'fig' :  "\\begin{figure}[H]\<cr>\\centering\<cr>"
			\ ."\\includegraphics[width=\\textwidth]{<++>}\<cr>\\end{figure}",
			\ 'enu' : "\\begin{enumerate}[label=(\\arabic*)]\<cr>"
			\ ."\\item <++>\<cr>\\end{enumerate}",
			\ '\[' : "\\[<++>\<cr>\\]",
			\ 'ncas' : "\\begin{numcases}{}\<cr><++>\<cr>\\end{numcases}",
			\ 'ilim' : '\varinjlim', 
			\ 'dlim' : '\varprojlim', 
			\ 'injto' : '\hookrightarrow', 
			\ 'wc' : '\rightharpoonup', 
			\ 'uc' : '\rightrightarrows', 
			\ 'Thm'   : "Theorem \\ref{thm:<++>}",
			\ 'Cor'   : "Corollary \\ref{co<++>}",
			\ 'Prop'   : "Proposition \\ref{prop:<++>}",
			\ 'Le'   : "Lemma \\ref{le:<++>}",
			\ 'article' : "\\documentclass[12pt]{article}\<cr>\<cr>"
			\ ."\\begin{document}\<cr><++>\<cr>\\end{document}",
			\ 'amsart' : "\\documentclass[12pt,reqno]{amsart}\<cr>\<cr>"
			\ ."\\begin{document}\<cr><++>\<cr>\\end{document}",
			\ 'xe' : '% !TeX engine = xelatex',
			\ 'a4' : "\\usepackage[a4paper,includeheadfoot,margin=2.54cm]{geometry}",
			\ 'times' : "\\usepackage[scaled=0.9]{helvet}\<cr>\\usepackage{tgtermes}",
			\ 'hyperref' : "\\usepackage[unicode=true,\<cr>colorlinks=true,\<cr>"
			\ ."linkcolor=purple,\<cr>citecolor=blue,\<cr>urlcolor=violet,\<cr>"
			\ ."linktoc=all,\<cr>plainpages=false,\<cr>bookmarks=true,\<cr>"
			\ ."bookmarksopen=true,\<cr>bookmarksnumbered]{hyperref}",
			\ 'mathabx' : "\\usepackage{mathabx}\<cr>"
			\ ."\\usepackage[scr=rsfso,bb=ams,frak=euler]{mathalpha}",
			\ 'amsthm' : "\\usepackage{amsthm}\<cr>"
			\ ."\\theoremstyle{plain}\<cr>"
			\ ."\\newtheorem{theorem}{Theorem}[section]\<cr>"
			\ ."\\newtheorem*{theorem*}{Theorem}\<cr>"
			\ ."\\newtheorem{corollary}[theorem]{Corollary}<\cr>"
			\ ."\\newtheorem{lemma}[theorem]{Lemma}\<cr>"
			\ ."\\newtheorem{proposition}[theorem]{Proposition}\<cr>"
			\ ."\\theoremstyle{definition}\<cr>"
			\ ."\\newtheorem{definition}[theorem]{Definition}\<cr>"
			\ ."\\theoremstyle{remark}\<cr>"
			\ ."\\newtheorem{remark}[theorem]{Remark}\<cr>"
			\ ."\\newtheorem{example}[theorem]{Example}\<cr>"
			\ ."\\numberwithin{equation}{section}",
			\ 'titlesec' : "\\usepackage{titlesec}\<cr>"
			\ ."\\titleformat{\\section}{\\normalfont\\Large\\bfseries\\centering}\<cr>"
			\ ."{\\thesection.}{0.5em}{}\<cr>"
			\ ."\\titlespacing{\\section}{0pt}{0em}{20pt}\<cr>"
			\ ."\\newcommand{\\sectionbreak}{\\clearpage}\%start new page for each section",
			\ 'titlepage' : "\\begin{titlepage}\<cr>\\title{}\<cr>\\author{}\<cr>" 
			\ ."\\date{}\<cr>\\maketitle\<cr>\\thispagestyle{empty}\<cr>" 
			\ ."\\end{titlepage}\<cr>\\pagestyle{empty}\<cr>\\tableofcontents\<cr>" 
			\ ."\\newpage\\clearpage\<cr>\\setcounter{page}{1}\<cr>"
			\ ."\\pagestyle{plain}\<cr>",
			\ 'xetimes' : "\\RequirePackage{fontspec}\<cr>"
			\ ."\\defaultfontfeatures{Mapping=tex-text}\<cr>" 
			\ ."\\setmainfont[BoldFont = texgyretermes-bold.otf,\<cr>"
			\ ."ItalicFont = texgyretermes-italic.otf]{texgyretermes-regular.otf}",
			\ 'xeCJK' : "\\RequirePackage{xeCJK}\<cr>"
			\ ."\\setCJKmainfont[Path = \\string~/.fonts/,\<cr>"
			\ ."BoldFont = SourceHanSansCN-Medium.otf,\<cr>"
			\ ."ItalicFont = SourceHanSerifCN-ExtraLight.otf,\<cr>"
			\ ."BoldItalicFont = SourceHanSansCN-Light.otf\<cr>"
			\ ."]{SourceHanSerifCN-Regular.otf}",
			\ 'xemath' : "\\RequirePackage{unicode-math}\<cr>"
			\ ."\\setmathfont{STIXTwoMath-Regular.otf}",
			\ 'xemathtimes' : "\\RequirePackage{unicode-math}\<cr>"
			\ ."\\setmathfont{texgyretermes-math.otf}\<cr>"
			\ ."\\setmathfont[range=\\setminus]{Asana-Math.otf}",
			\ }
"}}}
inoremap <buffer> <C-i>		 <C-r>=<SID>PutEnv()<CR>
function! s:PutEnv() "{{{
	let key_word = input('Insert Env/Command: ')
	if key_word == ''
		let events = ''
	elseif has_key(s:KeyWDict,key_word)
		let rhs = get(s:KeyWDict,key_word)
		let events = s:PutTextWithMovement(rhs)
	elseif has_key(s:Maps_envs_abbrv,key_word)
		let env_name = get(s:Maps_envs_abbrv,key_word)
		let rhs= "\\begin{".env_name."}\<cr><++>\<cr>\\end{".env_name."}"
		let events = s:PutTextWithMovement(rhs)
	else
		let env_name = key_word
		let rhs= "\\begin{".env_name."}\<cr><++>\<cr>\\end{".env_name."}"
		let events = s:PutTextWithMovement(rhs)
	end
	return events
endfunction
"}}}

" vim:fdm=marker ff=unix

