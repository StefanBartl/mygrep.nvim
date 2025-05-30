---@module 'mygrep.ui.tool_picker'
---@brief Delegates tool picking to the configured style

local M = {}

local config = require("mygrep.config")
local selector_ui = require("mygrep.ui.tool_selector")
local selector_cmdline = require("mygrep.ui.tool_cmdline_select")

function M.open()
  local style = config.get_option("tool_picker_style")
  print("[mygrep] style resolved to:", style)

  if style == "ui" then
    selector_ui.open()
  elseif style == "select" then
    selector_cmdline.open()
  else
    vim.notify("[mygrep] Invalid config: tool_picker_style = " .. tostring(style), vim.log.levels.ERROR)
  end
end

return M
