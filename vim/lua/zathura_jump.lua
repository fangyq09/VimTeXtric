-- ~/.config/nvim/lua/zathura_jump.lua
--
-- 在zathurarc中需要打开synctex
-- 即set synctex true
--
function _G.jump_to_line(file, line)
	local buf = vim.fn.bufnr(file, true)  
  vim.cmd("buffer " .. buf)            
  vim.api.nvim_win_set_cursor(0, { tonumber(line), 0 })
  return "" 
end


function _G.open_tex_and_jump(file, line)
  local path = vim.fn.fnamemodify(file, ":p")
  local bufnr = vim.fn.bufnr(path, true) -- 获取或创建 buffer
  vim.fn.bufload(bufnr)                   -- 确保 buffer 已载入
  -- 切换到 buffer
  vim.api.nvim_set_current_buf(bufnr)
	-- 跳转到指定行
  vim.api.nvim_win_set_cursor(0, { tonumber(line), 0 })
end


