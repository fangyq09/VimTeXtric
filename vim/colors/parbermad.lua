-- parbermad colorscheme in Lua
-- Author: Yangqin Fang
-- Version: 1.1
-- -- 定义局部函数
-- local function syntax_query()
--   local row = vim.fn.line(".")
--   local col = vim.fn.col(".")
--   -- synstack 返回语法 ID 的表
--   local stack = vim.fn.synstack(row, col)
--   for _, id in ipairs(stack) do
--     local name = vim.fn.synIDattr(id, "name")
--     local trans_name = vim.fn.synIDattr(vim.fn.synIDtrans(id), "name")
--     print(name .. " -> " .. trans_name)
--   end
-- end
-- -- 创建命令
-- vim.api.nvim_create_user_command("SyntaxQuery", syntax_query, {})

-- colorscheme
vim.o.background = "light"

vim.cmd("hi clear")

vim.g.colors_name = "parbermad"

local hi = vim.api.nvim_set_hl

-- Normal
hi(0, "Normal", { fg="#000000", bg="#FFF0BA" })
hi(0, "ErrorMsg", { fg="red", bg="#ffffff" })
hi(0, "Error", { fg="red", bg="#ffffff" })
hi(0, "Visual", { bg="#8080ff", fg="#ffffff",reverse=true })
hi(0, "VisualNOS", { bg="#8080ff", reverse=true })
hi(0, "Todo", { fg="blue", bg="darkgoldenrod" })
hi(0, "Search", { fg="black", bg="gold", underline=true})
hi(0, "IncSearch", { fg="#b0ffff", bg="#2050d0" })
hi(0, "MatchParen", { fg="Black", bg="CadetBlue" })
hi(0, "SpecialKey", { fg="darkgreen" })
hi(0, "Directory", { fg="deeppink" })
hi(0, "Title", { fg="magenta", bold=true })
hi(0, "WarningMsg", { fg="darkred" })
hi(0, "WildMenu", { fg="yellow", bg="black" })
hi(0, "ModeMsg", { fg="#22cce2" })
hi(0, "MoreMsg", { fg="darkgreen" })
hi(0, "Question", { fg="green" })
hi(0, "NonText", { fg="#0030ff" })
hi(0, "StatusLine", { fg="black", bg="gold" })
hi(0, "StatusLineNC", { fg="black", bg="Grey42" })
hi(0, "VertSplit", { fg="black", bg="Grey42" })
hi(0, "Folded", { fg="black", bg="darksalmon" })
hi(0, "FoldColumn", { fg="Grey", bg="#000040" })
hi(0, "LineNr", { fg="red" })
hi(0, "DiffAdd", { bg="#ADEBB3" })
hi(0, "DiffChange", { bg="#c98ec4" })
hi(0, "DiffDelete", { fg="Blue", bg="#85d2c3", bold=true})
hi(0, "DiffText", { bg="#be84b9", bold=true })
hi(0, "Cursor", { fg="#ffffff", bg="#6600CC" })
hi(0, "lCursor", { fg="#ffffff", bg="#000000" })
hi(0, "CursorLine", { bg="peachpuff" })
hi(0, "CursorIM", { fg="#000000", bg="#8A4C98" })
hi(0, "Comment", { fg="black", bg="#F5DEB3" })
hi(0, "String", { fg="DarkGreen", bold=true })
hi(0, "Special", { fg="BlueViolet", bold=true })
hi(0, "Identifier", { fg="brown", bold=false })
hi(0, "Statement", { fg="#5555ff", bold=true })
hi(0, "PreProc", { fg="green3", bold=true })
hi(0, "PreCondit", { fg="green4", bold=true })
hi(0, "Type", { fg="magenta", bold=true })
hi(0, "Label", { fg="Olive", bold=true })
hi(0, "Operator", { fg="brown", bold=true })
hi(0, "Number", { fg="red", bold=true })
hi(0, "Constant", { fg="#ff88d3", bold=true })
hi(0, "Function", { fg="DarkOliveGreen", bold=true })
hi(0, "IO", { fg="red", bold=true })
hi(0, "Communicator", { bg="yellow", fg="black" })
hi(0, "UnitHeader", { bg="lightblue", fg="black", bold=true })
hi(0, "Macro", { fg="#1A5FB4" })
hi(0, "Keyword", { fg="orangered" })
hi(0, "Underlined", { underline=true })
hi(0, "Ignore", { fg="NONE", bg="NONE" })
hi(0, "colorcolumn", { bg="#999933" })
hi(0, "Conceal", { fg="green4", bg="peachpuff", bold=true })
hi(0, "Delimiter", { fg="DarkCyan", bold=true })
hi(0, "SpellBad", { fg="Purple4", bg="#F5DEB3", underline=true, bold=true, italic=true })

-- TeX specific
hi(0, "texSectionMarker", { fg="darkgoldenrod", bold=true })
hi(0, "texSection", { fg="Olive", bold=true, underline=true })
hi(0, "texSectionName", { fg="Black", bold=true })
hi(0, "texInputFile", { fg="ForestGreen" })
hi(0, "texCmdArgs", { fg="SkyBlue", bold=true })
hi(0, "texInputFileOpt", { fg="#999933" })
hi(0, "texType", { fg="DarkSlateGray" })
hi(0, "texTypeStyle", { fg="DarkGreen" })
hi(0, "texMath", { fg="Red4", bold=true })
hi(0, "texStatement", { fg="Blue" })
hi(0, "texString", { fg="Blue4" })
hi(0, "texSpecialChar", { fg="DodgerBlue" })
hi(0, "texRefZone", { fg="DeepPink2", bold=true })
hi(0, "texCite", { fg="DeepPink4" })
hi(0, "texGreek", { fg="Green4", bold=true })
hi(0, "texDef", { fg="DodgerBlue" })
hi(0, "texMathSymbol", { fg="NavyBlue" })
hi(0, "texRefOption", { fg="HotPink4" })
hi(0, "texMathMatcher", { fg="DarkOrange3" })


hi(0, "DiagnosticError", { fg="#ff0000" })
hi(0, "DiagnosticWarn", { fg="#ffaa00" })
hi(0, "DiagnosticInfo", { fg="#00aaff" })
hi(0, "DiagnosticHint", { fg="#00ff00" })
hi(0, "DiagnosticUnderlineError", { undercurl=true, sp="#ff0000" })
hi(0, "DiagnosticUnderlineWarn", { undercurl=true, sp="#ffaa00" })
hi(0, "DiagnosticUnderlineInfo", { undercurl=true, sp="#00aaff" })
hi(0, "DiagnosticUnderlineHint", { undercurl=true, sp="#00ff00" })


hi(0, "TSKeyword", { fg="orangered", bold=true })
hi(0, "TSFunction", { fg="DarkOliveGreen", bold=true })
hi(0, "TSVariable", { fg="brown" })
hi(0, "TSComment", { fg="black", bg="#F5DEB3" })
hi(0, "TSString", { fg="DarkGreen", bold=true })
hi(0, "TSConstant", { fg="#ff88d3", bold=true })
hi(0, "TSOperator", { fg="brown", bold=true })

