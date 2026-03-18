scriptencoding utf-8

"关闭vi兼容模式，不要使用vi的键盘模式，而是vim自己的
set nocompatible
" 记住上次的位置
autocmd BufReadPost *
			\ if line("'\"") > 1 && line("'\"") <= line("$") |
			\   exe "normal! g`\"" |
			\ endif

set viminfo='10,\"100,:20,%,n~/.viminfo



"禁止生成临时文件
set nobackup
set noswapfile

"------------------------------------------------------------------------------
""编码设置
"------------------------------------------------------------------------------
"language messages zh_CN.UTF-8  

set encoding=utf-8
set langmenu=zh_CN.UTF-8

set fileencoding=UTF-8
set fileencodings=ucs-bom,UTF-8,cp936,gb18030,big5,latin1

"source $VIMRUNTIME/delmenu.vim  
"source $VIMRUNTIME/menu.vim
"------------------------------------------------------------------------------
" ============================
" LaTeX 语法增强设置
" ============================
let g:tex_comment_nospell = 1
let g:tex_no_error = 1
let g:tex_stylish = 1
" ============================
"vim脚本
" ============================
"关闭所有嵌入语言
let g:vimsyn_embed = ''
"------------------------------------------------------------------------------
"自动语法高亮
syntax on

"打开文件类型检测,补全功能需要
filetype on         "检测文件类型
filetype plugin on  "载入文件类型插件
filetype indent on

"------------------------------------------------------------------------------
"------------------------------------------------------------------------------
"自动补全(ctrl-p)时的一些选项：
set completeopt=menu,longest,preview

"omni补全设置
"使用回车代替Ctrl-y选词
"inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

"------------------------------------------------------------------------------
"------------------------------------------------------------------------------

"if v:version >= 730
"set cc=79
"endif

" 永久撤销
set undofile
" 设置撤销文件的存放的目录
set undolevels=1000
set undoreload=10000


"显示相对行号
set rnu
"显示行号
set number

"split window blew
set splitbelow

"长行不能完全显示时显示当前屏幕能显示的部分,
"默认值为空,长行不能完全显示时显示 @。
set display=lastline

"允许在有未保存的修改时切换缓冲区，
"此时的修改由切换由 vim 负责保存
set hidden

" 设置冒号命令和搜索命令的命令历史列表的长度为100
set history=100

" 搜索时高亮显示被找到的文本
set hlsearch

" 搜索时忽略大小写，但在有一个或以上大写字母时仍保持对大小写敏感
set ignorecase smartcase
" 默认区分大小写
set noignorecase

" 输入搜索内容时就显示搜索结果
set incsearch

" 设定在任何模式下鼠标都可用
if has('mouse')
	set mouse=a
endif


"自动保存
set autowriteall

"在编辑过程中，在右下角显示光标位置
set ruler

"设定命令行的行数为1
set cmdheight=1

"标题栏
auto BufEnter * let &titlestring = expand("%:p")
set title titlestring=%<%F%=%l/%L-%P titlelen=70
"显示状态栏(默认值为 1, 无法显示状态栏,0表示)
set laststatus=2
set statusline=%-40.50t
set statusline+=\ %-7.7{&fenc!=''?&fenc:&enc}
set statusline+=\ b%-4.4n
set statusline+=\ 总共\:%6.6L\行
set statusline+=[%6l,%-3c]\ 
set statusline+=%4.4P\ 
set showcmd

set directory=.,$TEMP  

" 如遇Unicode值大于255的文本，不必等到空格再断行。
set formatoptions+=m
" 合并两行中文时，不在中间加空格：
set formatoptions+=M

""使用J合并行或是gq命令时不产生多余空格
set nojoinspaces

set backspace=indent,eol,start

"整词换行,告诉Vim在合适的地方折行,所谓合适的地方，是由breakat选项中的字符来确定的。
"在默认的情况下，这些字符是“^I!@*-+_;:,./?”。
"如果我们不希望在下划线处打断句子，只要用下面的命令将“_”从这个列表移除就可以了
":set breakat-=_
set wrap 
set nolinebreak "任何字符处都可以折行（不是断行）
set wrapmargin=0
"set showbreak=@

"自动对齐
set autoindent
"开启cindent,类似C语言程序的缩进
"set ci
"智能对齐
"set smartindent

"每层缩进的空格数=2
set shiftwidth=2

"编辑时一个TAB字符占多少个空格的位置
set tabstop=2     

" 关闭 rust.vim 的深层自动缩进
let g:rust_recommended_style = 0

"设置匹配模式，类似当输入一个左括号时会匹配相应的那个右括号,注意会拖累输入速度
"set showmatch
"set matchtime=0


"去掉输入错误的提示声音
set noeb

"在处理未保存或只读文件的时候，弹出确认
"set confirm

"设置语法折叠
set foldmethod=syntax
"set foldmethod=manual
"设置折叠层数为
"setlocal foldlevel=1

"左右光标移动到头时可以自动下移
set whichwrap=b,s,<,>,[,] 

"配对
"set mps+=「:」

"不高亮显示当前行和列
set nocursorline
set nocursorcolumn

"自动设当前编辑的文件所在目录为当前工作路径
set autochdir  

"启动时不显示 捐赠提示
set shortmess=atWI

"设置中文帮助文档
let helptags=$HOME."/.vim/doc"
set helplang=cn


"设置宽度不明的文字(如 “”①②→ )为双宽度文本, 要不然会挤在一起
set ambiwidth=double
"

"if str2nr(strftime("%d")) % 2
"	colorscheme parbermad
"else
"  colorscheme gruber_dark
"endif
colorscheme parbermad
if has("win32") || has("win64")
	set termencoding=cp936
	set shellslash
	"set guifont=Consolas:h14:cANSI ""英文字体
	"set guifontwide=SimSun-ExtB:h15:cANSI ""中文字体
	"set guifont=DejaVu_Sans_Mono:h14:cANSI ""英文字体
	set guifont=Sarasa_Term_SC_Nerd:h15:cANSI ""字体
	"set renderoptions=type:directx,renmode:5,taamode:1
	set grepprg=internal
	set undodir=$TMP
elseif has("unix")
	set termencoding=UTF-8
	"shell设为zsh
	set shell=/usr/bin/zsh
	set undodir=/tmp/,~/.vim/tmp     
	set grepprg=grep\ -nH\ $*
	if has("gui_running")
		set guifont=Dejavu\ Sans\ Mono\ Book\ 14
		set guifontwide=文泉驿等宽微米黑\ 14
	else
		if has('termguicolors')
			set termguicolors
		else
			""只支持 256 色的终端
			set t_Co=256
			set bg=light
		endif
	endif 
endif

"隐藏工具条设置
set guioptions-=T " 隐藏工具条
"set guioptions+=m " 显示菜单栏
set guioptions-=m " 隐藏菜单栏
set guioptions-=L " 隐藏左侧滚动条 
set guioptions-=r " 隐藏右侧滚动条 
set guioptions-=b " 隐藏底部滚动条 
set showtabline=0 " 隐藏Tab栏

" 调整gvim的文本行距
set linespace=7

"光标上下两侧最少保留的屏幕行数
set scrolloff=2

"窗口大小设置
set lines=38
set columns=90


if v:version >= 801
	nnoremap <C-t> :terminal<CR>
	tnoremap <C-q> <C-w>:q!<CR>
	tnoremap <ESC> <C-\><C-n>
endif

"diff模式下的窗口大小
if &diff
	let &columns = 164 + 2*&foldcolumn + 1
endif

let g:netrw_browsex_viewer= "google-chrome"
"------------------------------------------------------------------------------
"""vim中文输入法设置""
set imdisable
nmap <M-i> i
nmap <M-o> o
nmap <M-a> a
nmap <M-x> x
nmap K <nop>
nmap <C-l> <nop>
nmap <F1> <nop>
imap <F1> <nop>
nmap <F10> <nop>
nnoremap <silent> <M-b> :let @+ = @b<CR>
nnoremap <silent> <M-c> :let @+ = @c<CR>
nnoremap <silent> <M-d> :let @+ = @d<CR>
"------------------------------------------------------------------------------
""78换行
"set textwidth=78
augroup EditVim
	autocmd!
	au BufNewFile,BufRead *.\(tex\|TEX\) set ft=tex
	"au BufNewFile,BufRead *.\(tex\|TEX\) set ft=tex | set wrap | set textwidth=78
	"au BufNewFile,BufRead * if &ft == '' | set ft=tex | endif
	"autocmd BufNewFile,BufRead * if expand('%:t') !~ '\.' | set syntax=tex | endif
	"
	"对于tex文件在退出时，自动执行write命令
	au VimLeave *.tex write
augroup END
"------------------------------------------------------------------------------

"------------------------------------------------------------------------------

set spell spelllang=en_us,cjk 


""""---------------------------------------------------------------------------
"python
