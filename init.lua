--========================================
-- Neovim + Neovide 配置 (init.lua)
--========================================
-- ============================
-- LaTeX 语法增强设置
-- ============================
vim.g.tex_comment_nospell = 1
vim.g.tex_no_error = 1
vim.g.tex_stylish = 1

---------------------------
-- 基础设置
---------------------------
-- 开启语法高亮
vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.fileencodings = { "utf-8", "ucs-bom", "cp936", "gb18030", "big5", "latin1" }

---------------------------
-- 终端设置
---------------------------
if vim.fn.has("termguicolors") == 1 then
  vim.opt.termguicolors = true
end

---------------------------
-- viminfo & 撤销
---------------------------
vim.opt.viminfo = "'10,\"100,:20,%,n~/.local/share/nvim/viminfo"
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.local/share/nvim/undo")
vim.opt.undolevels = 1000
vim.opt.undoreload = 10000

---------------------------
-- 临时文件
---------------------------
vim.opt.backup = false
vim.opt.swapfile = false

---------------------------
-- 光标位置恢复
---------------------------
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
		local line = vim.fn.line('"')
    if line > 1 and line <= vim.fn.line("$") then
      vim.cmd('normal! g`"')
    end
  end,
})

---------------------------
-- 窗口 & 行号
---------------------------
-- 保持光标上下方最少 2 行
vim.opt.scrolloff = 2
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitbelow = true
vim.opt.hidden = true
vim.opt.ruler = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 2
vim.opt.showcmd = true

vim.opt.statusline = "%-40.50t" ..
  " %-7.7{&fenc!=''?&fenc:&enc}" ..
  " b%-4.4n" ..
  " 总共:%6.6L行" ..
  " [%6l,%-3c] " ..
  "%4.4P "

---------------------------
-- 搜索
---------------------------
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true

---------------------------
-- 编辑 & 缩进
---------------------------
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.wrap = true
vim.opt.linebreak = false
vim.opt.formatoptions:append({ "m", "M" })
vim.opt.joinspaces = false
vim.opt.display = "lastline"

---------------------------
-- 鼠标 & 自动保存
---------------------------
vim.opt.mouse = "a"
vim.opt.autowriteall = true

---------------------------
-- 折叠
---------------------------
vim.opt.foldmethod = "syntax"

---------------------------
-- 光标 & 配对
---------------------------
vim.opt.whichwrap = "b,s,<,>,[,]"
vim.opt.cursorline = false
vim.opt.cursorcolumn = false

---------------------------
-- 中文 & 拼写
---------------------------
vim.opt.spell = true
vim.opt.spelllang = { "en_us", "cjk" }
vim.opt.ambiwidth = "double"

---------------------------
-- 自动切换工作目录
---------------------------
vim.opt.autochdir = true


---------------------------
-- 配色方案
---------------------------
-- 当前主题模式
local current_mode = "dark" -- 有light与dark可选
-- local current_mode = "light" -- 有light与dark可选
if current_mode == "light" then
	vim.cmd.colorscheme("parbermad")
else
	vim.cmd.colorscheme("gruber-dark")
end


---------------------------
-- Neovide GUI 设置
---------------------------
if vim.g.neovide then
  -- 字体
  -- vim.opt.guifont = "Hack Nerd Font:h14"
	-- vim.opt.guifont = "Monospace:h14"
	vim.opt.guifont = "DejaVu Sans Mono:h14"
  vim.opt.guifontwide = "文泉驿等宽微米黑:h14"

	-- 行间距
	vim.opt.linespace = 7
	
	--透明度
	if current_mode == "light" then
		vim.g.neovide_opacity = 1
	else
		vim.g.neovide_opacity = 0.9 -- 90% 不透明
	end

	vim.o.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50," ..
	"a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor," ..
	"sm:block-blinkwait175-blinkoff150-blinkon175"

  vim.g.neovide_cursor_animation_length = 0.1  -- 光标平滑移动时间
	vim.g.neovide_cursor_trail_size = 0     -- 拖尾长度
	-- vim.g.neovide_cursor_vfx_opacity = 0.5  -- 半透明特效
	-- vim.g.neovide_cursor_vfx_mode = "pixiedust"      -- 光标粒子特效
	-- vim.g.neovide_cursor_vfx_particle_lifetime = 0.1
  vim.g.neovide_refresh_rate = 120
  vim.g.neovide_remember_window_size = true
	vim.g.neovide_confirm_quit = false
	vim.g.neovide_cursor_animate_command_line = true

	-- diff
	-- if vim.o.diff then
	-- 	vim.g.neovide_remember_window_size = false
	-- 	vim.g.neovide_fullscreen = true
	-- end
end

---------------------------
-- 文件类型 & Tex
---------------------------

vim.filetype.add({
  extension = {
    tex = "tex",
    typ = "typst",
  },
})

vim.api.nvim_create_augroup("TexAutoSave", { clear = true })
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = "TexAutoSave",
  pattern = "*.tex",
  callback = function()
    if vim.bo.modified then
      vim.cmd("write")
    end
  end,
})
---------------------------
-- 中文帮助
---------------------------
-- vim.opt.helplang = "cn"
---------------------------

---------------------------
-- Netrw 浏览器
---------------------------
vim.g.netrw_browsex_viewer = "google-chrome"

---------------------------
-- 键位映射
---------------------------
vim.keymap.set("n", "<M-i>", "i")
vim.keymap.set("n", "<M-a>", "a")
vim.keymap.set("n", "<M-o>", "o")
vim.keymap.set("n", "<M-x>", "x")
vim.keymap.set("n", "K", "<nop>")
vim.keymap.set("n", "<C-l>", "<nop>")
vim.keymap.set("n", "<F1>", "<nop>")
vim.keymap.set("i", "<F1>", "<nop>")
vim.keymap.set("n", "<F10>", "<nop>")

-- 普通模式 Ctrl+t 打开终端
vim.keymap.set('n', '<C-t>', ':terminal<CR>', { noremap = true, silent = true })

local function close_terminal()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].buftype ~= "terminal" then return end
  -- 如果终端还有正在运行的进程，先停止它
  local job_id = vim.b[bufnr].terminal_job_id
  if job_id and vim.fn.jobwait({job_id}, 0)[1] == -1 then
    vim.fn.jobstop(job_id)
  end
  -- 切回上一个 buffer 并删除终端 buffer
  vim.cmd("b#")
  vim.api.nvim_buf_delete(bufnr, { force = true })
end
local function exit_terminal()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].buftype ~= "terminal" then return end

  local job_id = vim.b[bufnr].terminal_job_id
  if job_id then
    -- 先温和退出
    vim.fn.chansend(job_id, "exit\n")
    -- 等 50ms，看进程是否退出
    vim.defer_fn(function()
      if vim.fn.jobwait({job_id}, 0)[1] == -1 then
        -- 如果进程还在运行，强制终止
        vim.fn.jobstop(job_id)
      end
      -- 删除终端 buffer
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.cmd("b#")
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end
    end, 50)
  else
    -- 没有进程，直接删除 buffer
    vim.cmd("b#")
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end
-- 终端打开时自动绑定快捷键
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function(args)
    local buf = args.buf
    -- 插入模式
    vim.keymap.set('t', '<C-q>', exit_terminal, { buffer = buf, noremap = true, silent = true })
    -- 普通模式
    vim.keymap.set('n', '<C-q>', exit_terminal, { buffer = buf, noremap = true, silent = true })
  end,
})

---------------------------
-- LaTeX <--> Zathura 设置
---------------------------
 require("zathura_jump")


---------------------------
-- nnn设置
---------------------------
vim.api.nvim_create_user_command('NNN', function()
    require("minimal-nnn").start()
end, {})
