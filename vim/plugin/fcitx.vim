"=========================================================
"Fcitx 输入法自动切换
"
"在离开或重新进入插入模式或搜索模式时自动记录和恢复每个缓冲区各自的输入法状态，
"以便在普通模式下始终是英文输入模式，切换回插入模式时恢复离开前的输入法输入模式。
"
"原理是使用gdbus查询和切换fcitx的状态
"
"# 查询状态
"gdbus call --session 
"  --dest org.fcitx.Fcitx5 
"  --object-path /controller 
"  --method org.fcitx.Fcitx.Controller1.State
"
"# 切换激活状态
"gdbus call --session 
"  --dest org.fcitx.Fcitx5 
"  --object-path /controller 
"  --method org.fcitx.Fcitx.Controller1.Deactivate
"
"# 切换激活状态
"gdbus call --session 
"  --dest org.fcitx.Fcitx5 
"  --object-path /controller 
"  --method org.fcitx.Fcitx.Controller1.Activate
"
" 也可以用'fcitx5-remote'查看输入状态，这种方式的好处是不依赖于gdbus，
" 然后用'fcitx5-remote -o' 与'fcitx5-remote -c'进行切换
" 
" windows 平台使用im-select.exe命令行工具切换输入法：
"	https://github.com/daipeihust/im-select
"=========================================================
if exists('g:fcitx_plugin_loaded')
  finish
endif
let g:fcitx_plugin_loaded = 1

" 离开插入模式时切回英文
function! Fcitx2en()
  " 获取当前状态
  let s:state = system('gdbus call --session --dest org.fcitx.Fcitx5 --object-path /controller --method org.fcitx.Fcitx.Controller1.State')
  " 如果激活了，记录标志
  if s:state =~ '2'
    let b:inputtoggle = 1
    call system('gdbus call --session --dest org.fcitx.Fcitx5 --object-path /controller --method org.fcitx.Fcitx.Controller1.Deactivate')
  else
    let b:inputtoggle = 0
  endif
endfunction

" 回到插入模式时恢复输入法
function! Fcitx2zh()
  " 只有之前激活过才恢复
  if exists('b:inputtoggle') && b:inputtoggle == 1
    call system('gdbus call --session --dest org.fcitx.Fcitx5 --object-path /controller --method org.fcitx.Fcitx.Controller1.Activate')
    let b:inputtoggle = 0
  endif
endfunction

" 永久禁止 Fcitx5 激活
function! FcitxDisableForever()
  " 检查 Fcitx5 是否激活
  let s:state = system('gdbus call --session --dest org.fcitx.Fcitx5 --object-path /controller --method org.fcitx.Fcitx.Controller1.State')
  if s:state =~ '2'
    " 如果激活了就立即关闭
    call system('gdbus call --session --dest org.fcitx.Fcitx5 --object-path /controller --method org.fcitx.Fcitx.Controller1.Deactivate')
  endif
endfunction

"Windows
function! IME2en()
  let s:state = system('im-select.exe')
  if s:state =~ '2052'
    let b:inputtoggle = 1
    call system('im-select.exe 1033')
  else
    let b:inputtoggle = 0
  endif
endfunction

function! IME2zh()
  if exists('b:inputtoggle') && b:inputtoggle == 1
    call system('im-select.exe 2052')
    let b:inputtoggle = 0
  endif
endfunction

" 自动命令
if has('win32')
	autocmd InsertLeave * call IME2en()
	autocmd InsertEnter * call IME2zh()
else
	autocmd InsertLeave * call Fcitx2en()
	autocmd InsertEnter * call Fcitx2zh()
endif

" 在每次插入/普通模式切换时触发
"autocmd InsertEnter,InsertLeave,WinEnter,WinLeave,BufEnter,BufLeave,TabEnter,TabLeave,FocusGained,FocusLost,VimEnter * call FcitxDisableForever()
"autocmd InsertEnter,InsertLeave,WinEnter,WinLeave * call FcitxDisableForever()
