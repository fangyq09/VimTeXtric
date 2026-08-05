-- fcitx.lua
-- 与 Fcitx5 通信，控制输入法开关和获取当前状态
-- 使用 gdbus 命令实现，无需 dbus 库依赖

local fcitx = {}

-- 执行 shell 命令并返回输出
local function cmd(str)
  local handle = io.popen(str)
  if not handle then return nil end
  local result = handle:read("*a")
  handle:close()
  return result and result:gsub("^%s+", ""):gsub("%s+$", "")
end

----------------------------------------------------------------------
-- 检测 Fcitx5 是否正在运行
----------------------------------------------------------------------

function fcitx.is_running()
  local out = cmd("gdbus introspect --session --dest org.fcitx.Fcitx5 --object-path /controller 2>/dev/null")
  return out and out ~= ""
end

-- 如果 Fcitx5 未运行，则打印一次警告（可选）
local function ensure_running()
  if not fcitx.is_running() then
    vim.schedule(function()
      vim.notify("Fcitx5 not running", vim.log.levels.WARN)
    end)
    return false
  end
  return true
end

----------------------------------------------------------------------
-- 基本控制函数
----------------------------------------------------------------------

-- 获取 Fcitx5 状态：2 表示激活，1 表示未激活
function fcitx.state()
  if not ensure_running() then return 0 end
  local out = cmd("gdbus call --session " ..
    "--dest org.fcitx.Fcitx5 " ..
    "--object-path /controller " ..
    "--method org.fcitx.Fcitx.Controller1.State 2>/dev/null")
  local state = tonumber(out:match("(%d+)"))
  return state or 0
end

-- 判断是否启用
function fcitx.active()
  return fcitx.state() == 2
end

-- 激活输入法
function fcitx.activate()
  if not ensure_running() then return end
  cmd("gdbus call --session " ..
    "--dest org.fcitx.Fcitx5 " ..
    "--object-path /controller " ..
    "--method org.fcitx.Fcitx.Controller1.Activate 2>/dev/null")
end

-- 关闭输入法
function fcitx.deactivate()
  if not ensure_running() then return end
  cmd("gdbus call --session " ..
    "--dest org.fcitx.Fcitx5 " ..
    "--object-path /controller " ..
    "--method org.fcitx.Fcitx.Controller1.Deactivate 2>/dev/null")
end

----------------------------------------------------------------------
-- 获取输入法信息
----------------------------------------------------------------------

-- 当前输入法
function fcitx.current_im()
  if not ensure_running() then return "unknown" end
  local out = cmd("gdbus call --session " ..
    "--dest org.fcitx.Fcitx5 " ..
    "--object-path /controller " ..
    "--method org.fcitx.Fcitx.Controller1.CurrentInputMethod 2>/dev/null")
  if not out then return "unknown" end
  local im = out:match("'(.-)'")
  return im or "unknown"
end

-- 当前 Rime 方案
function fcitx.current_rime_schema()
  if not ensure_running() then return nil end
  local out = cmd("gdbus call --session " ..
    "--dest org.fcitx.Fcitx5 " ..
    "--object-path /rime " ..
    "--method org.fcitx.Fcitx.Rime1.GetCurrentSchema 2>/dev/null")
  if not out then return nil end
  local schema = out:match("'(.-)'")
  return schema
end

-- 当前输入法 + Rime 方案
function fcitx.current_im_and_rime()
  local im = fcitx.current_im()
  if im == "rime" then
    local schema = fcitx.current_rime_schema()
    if schema then
      return "rime:" .. schema
    end
  end
  return im
end

----------------------------------------------------------------------
-- 自动切换输入法
----------------------------------------------------------------------

function fcitx.to_en()
  if not ensure_running() then return end
  if fcitx.active() then
    vim.b.inputtoggle = 1
    fcitx.deactivate()
  end
end

function fcitx.to_zh()
  if not ensure_running() then return end
  if vim.b.inputtoggle == 1 then
    fcitx.activate()
    vim.b.inputtoggle = 0
  else
    vim.b.inputtoggle = 0
  end
end

return fcitx
