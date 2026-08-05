-- ~/.config/nvim/colors/gruber_dark.lua
-- Gruber Darker color scheme for Neovim
-- Author: Alexey Kutepov / Jason R. Blevins
-- Converted for Neovim Lua
-- 粉色 Popup 菜单已经整合

-- 颜色表
local c = {
    none      = "NONE",
    fg        = "#e4e4ef",
    white     = "#ffffff",
    black     = "#000000",
    bg        = "#181818",
    red_1     = "#c73c3f",
    red_2     = "#ed6b6e",
    red_3     = "#ff4f58",
    red       = "#f43841",
    green     = "#73c936",
    yellow    = "#ffdd33",
    yellow_1  = "#ffce1b",
    yellow_2  = "#d9b918",
    brown     = "#cc8c3c",
    quartz    = "#95a99f",
    niagara_2 = "#303540",
    niagara_1 = "#565f73",
    niagara_3 = "#82a5ed",
    niagara_4 = "#5786eb",
    niagara   = "#96a6c8",
    wisteria  = "#9e95c7",
		olive     = "#808000", 
		purple    = "#c678dd",
		orange    = "#d19a66",  
		blue      = "#569cd6",
		amber     = "#ffdd33",
		cyan      = "#0bb0b0",
		cyan_2    = "#04c6c9",
		gold    	= "#efbf04",
		brightgreen    	= "#66ff00",
}

-- 高亮辅助函数
local function highlight(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

-- ===============================
-- 基本高亮
-- ===============================
highlight("Normal", { fg = c.fg, bg = c.bg })
highlight("CursorLine", { bg = "#282828" })
highlight("CursorColumn", { bg = "#282828" })
highlight("Visual", { fg = "#38075c", bg = "#0bb0b0" })
highlight("LineNr", { fg = c.red_2 })
highlight("CursorLineNr", { fg = c.yellow, bold = true })
highlight("Comment", { fg = c.niagara_1 })
highlight("ErrorMsg", { fg = c.red, bg = c.bg })
highlight("WarningMsg", { fg = c.red_3 })
highlight("Delimiter", { fg = c.purple })          -- 通用分隔符
-- highlight("Cursor", { fg = "#6600CC", bg = c.niagara }) 
-- highlight("Cursor", { fg = c.niagara, bg = "#6600CC" }) 
highlight("Cursor", { fg = "#6E260E", bg = c.niagara, bold = true })
highlight("CursorIM", { fg = c.white, bg = "#00008B" })
highlight("lCursor", { fg = c.white, bg = c.black })
highlight("Todo",     { fg = c.blue, bg = c.yellow })
highlight("VisualNOS",{ fg = "#8080ff", bg = c.bg, reverse = true })
highlight("Folded", { fg = c.brown, bg = c.niagara_2, bold =true})
-- highlight("StatusLine", {fg =c.black, bg = c.gold })
highlight("StatusLine", {fg =c.black, bg = c.white })
--highlight("colorcolumn", {fg =c.black, bg = c.niagara_3 })
-- ===============================
-- Popup menu（粉色风格）
-- ===============================
highlight("Pmenu", { fg = c.black, bg = "#FF69B4" })
highlight("PmenuSel", { fg = c.white, bg = "#FF1493", bold = true })
highlight("PmenuSbar", { bg = "#FF69B4" })
highlight("PmenuThumb", { bg = "#FF1493" })

-- ===============================
-- Diff
-- ===============================
highlight("DiffAdd", { bg = "#ADEBB3" })
highlight("DiffChange", { bg = "#C98EC4" })
highlight("DiffDelete", { bg = "#85d2c3" })
highlight("DiffText", { fg=c.black, bg = "#be84b9", bold = true })

-- ===============================
-- 搜索
-- ===============================
highlight("Search", { fg = c.black, bg = c.yellow })
highlight("IncSearch", { fg = c.yellow, bg = "#453d41" })

-- ===============================
-- 标题/目录
-- ===============================
highlight("Title", { fg = c.wisteria, bold = true })
highlight("Directory", { fg = c.niagara })

-- ===============================
-- 编程语法
-- ===============================
highlight("Number",   { fg = c.red_3 })
highlight("Operator", { fg = c.brightgreen })
highlight("Constant", { fg = c.green })
highlight("Function", { fg = c.olive, bold = true })
highlight("Keyword",  { fg = c.yellow, bold = true })
highlight("Statement", { fg = c.yellow_1, bold = true })
highlight("Identifier", { fg = c.niagara, bold = true })
highlight("Special", { fg = c.cyan_2, bold = true })
highlight("Type", { fg = c.blue, bold = true })
highlight("Preproc", { fg = c.quartz, bold = true })
highlight("Macro", { fg="#96bff2"})

-- ===============================
-- LaTeX 高亮
-- ===============================
highlight("texStatement", { fg = c.yellow_2})
highlight("texString",    { fg = c.green })
highlight("texMath",      { fg = c.red_3, bold = true })
highlight("texComment",   { fg = c.niagara_1 })
highlight("texCmdArgs",   { fg = c.niagara, bold = true })
highlight("texRefZone",   { fg = c.red_3, bold = true })
highlight("texCite",      { fg = c.red_1 })
highlight("texMathSymbol",{ fg = c.blue })
highlight("texSection",      { fg = c.olive, bold = true })  -- \section
highlight("texSubsection",   { fg = c.olive, bold = true })  -- \subsection
highlight("texChapter",      { fg = c.olive, bold = true })  -- \chapter
highlight("texSectionMarker", { fg = c.olive })   
highlight("texMathSymbol", { fg = c.yellow, bold = true })
highlight("texCommand", { fg = c.blue })
highlight("texNumber", { fg = c.green })           -- 数字
highlight("texOperator", { fg = c.purple })        -- 运算符 + {}[]()
highlight("texDelimiter", { fg = c.purple })       -- 大小括号
highlight("texConstant", { fg = c.orange })        -- 常量
highlight("texFunction", { fg = c.blue, bold = true })
highlight("texKeyword", { fg = c.yellow, bold = true })
highlight("texMathDelim", { fg = c.amber, bold = true })

-- ===============================
-- LSP Diagnostics
-- ===============================
highlight("DiagnosticError",       { fg = c.red })
highlight("DiagnosticWarn",        { fg = c.yellow })
highlight("DiagnosticInfo",        { fg = c.blue })
highlight("DiagnosticHint",        { fg = c.green })
highlight("DiagnosticUnderlineError", { underline=true, sp=c.red })
highlight("DiagnosticUnderlineWarn",  { underline=true, sp=c.yellow })
highlight("DiagnosticUnderlineInfo",  { underline=true, sp=c.blue })
highlight("DiagnosticUnderlineHint",  { underline=true, sp=c.green })

-- ===============================
-- Treesitter
-- ===============================
highlight("TSKeyword",         { fg = c.yellow, bold = true })
highlight("TSFunction",        { fg = c.niagara, bold = true })
highlight("TSVariable",        { fg = c.fg })
highlight("TSVariableBuiltin", { fg = c.purple })
highlight("TSString",          { fg = c.green })
highlight("TSComment",         { fg = c.brown })
highlight("TSConstant",        { fg = c.green })
highlight("TSNumber",          { fg = c.red_3 })
highlight("TSOperator",        { fg = c.quartz })
highlight("TSParameter",       { fg = c.fg })
highlight("TSProperty",        { fg = c.fg })
highlight("TSType",            { fg = c.olive, bold = true })
highlight("TSMethod",          { fg = c.niagara, bold = true })
highlight("TSField",           { fg = c.fg })
highlight("TSConditional",     { fg = c.yellow, bold = true })
highlight("TSRepeat",          { fg = c.yellow, bold = true })
highlight("TSInclude",         { fg = c.green })
highlight("TSException",       { fg = c.red })
highlight("TSLabel",           { fg = c.orange })
-- ===============================
-- 更多按需高亮可以继续加...
-- ===============================

-- 设置终端背景为暗色
vim.o.background = "dark"

-- 设置 colorscheme 名称（可用于 :colorscheme）
vim.g.colors_name = "gruber_dark"
