" ==============================================================================
" Script Title: rainbow parentheses (ftplugin version for Rust)
" 路径应为: ftplugin/rust.vim  (或 ftplugin/rust/rainbow.vim)
" ==============================================================================

" 防止同一个缓冲区重复加载
if exists('b:did_rust_rainbow')
    finish
endif
let b:did_rust_rainbow = 1

" 1. 定义自适应背景的彩虹颜色方案
if !exists('g:rainbow_guifgs')
	" 判断当前是 light 模式还是 dark 模式
	if &background ==# 'dark'
		" 【暗色背景方案】（高亮、柔和的亮色系，防止在黑底上看不清）
		let g:rainbow_guifgs = [
					\ '#fffff0',  
					\ '#ffcc66',  
					\ '#99cc99',  
					\ '#66cccc',  
					\ '#6699cc',  
					\ '#cc99cc',  
					\ ]
	else
		" 【亮色/米黄色背景方案】（沉稳的深色系）
		let g:rainbow_guifgs = [
					\ '#222222',  
					\ '#b72800',  
					\ '#8f6e00',  
					\ '#007f3e',  
					\ '#007399',  
					\ '#384cb7',  
					\ '#8237b7',  
					\ ]
	endif
endif

if !exists('g:rainbow_ctermfgs')
    if &background ==# 'dark'
        let g:rainbow_ctermfgs = [
                    \ 'white', 'yellow', 'green', 'cyan', 'blue', 'magenta'
                    \ ]
    else
        let g:rainbow_ctermfgs = [
                    \ 'black', 'darkred', 'darkyellow', 'darkgreen', 'darkcyan', 'darkblue', 'darkmagenta'
                    \ ]
    endif
endif

let s:max = has('gui_running') ? len(g:rainbow_guifgs) : len(g:rainbow_ctermfgs)

" 2. 核心加载与匹配逻辑（仅针对当前 Buffer 生效，仅保留 () 和 {}）
func! s:Rainbow_load_buffer()
    if exists('b:rainbow_loaded')
        call s:Rainbow_clear_buffer()
    endif

    let b:loaded = [ ['(', ')'], ['{', '}'] ]
    let b:operators = ''

    let str = 'TOP'
    for each in range(1, s:max)
        let str .= ',lv'.each
    endfor

    let cmd = 'syn region %s matchgroup=%s start=+%s+ end=+%s+ containedin=%s contains=%s,%s,@Spell fold'
    for [left , right] in b:loaded
        for each in range(1, s:max)
            exe printf(cmd, 'lv'.each, 'lv'.each.'c', left, right, 'lv'.(each % s:max + 1), str, 'op_lv'.each)
        endfor
    endfor

    call s:Rainbow_activate_buffer()
endfunc

func! s:Rainbow_clear_buffer()
    if exists('b:rainbow_loaded')
        unlet b:rainbow_loaded
        for each in range(1 , s:max)
            exe 'silent! syn clear lv'.each
        endfor
    endif
endfunc

func! s:Rainbow_activate_buffer()
    for id in range(1 , s:max)
        let ctermfg = g:rainbow_ctermfgs[(s:max - id) % len(g:rainbow_ctermfgs)]
        let guifg = g:rainbow_guifgs[(s:max - id) % len(g:rainbow_guifgs)]
        exe 'hi default lv'.id.'c ctermfg='.ctermfg.' guifg='.guifg
    endfor
    exe 'syn sync fromstart'
    let b:rainbow_active = 1
    let b:rainbow_loaded = 1
endfunc

func! s:Rainbow_toggle_buffer()
    if exists('b:rainbow_active')
        for each in range(1, s:max)
            exe 'silent! hi clear lv'.each.'c'
        endfor
        unlet b:rainbow_active
    else
        call s:Rainbow_activate_buffer()
    endif
endfunc

" 3. 注册当前 Buffer 专属的命令（避免全局污染）
command! -buffer RainbowToggle call s:Rainbow_toggle_buffer()

" 4. 打开 Rust 文件时自动执行
augroup RustRainbowAutoLoad
    autocmd! * <buffer>
    autocmd Syntax <buffer> nested call s:Rainbow_load_buffer()
augroup END
