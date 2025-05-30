---@module 'mygrep.ui.tool_picker'
---@brief Delegates tool picking to the configured style

local config = require("mygrep.config")
local selector = require("mygrep.ui.tool_cmdline_select")

local M = {}

function M.open()
  local style = config.get_option("tool_picker_style")
  if style == "ui" then
    selector.open()
  elseif style == "select" then
    require("mygrep.ui.tool_cmdline_select").open()
  else
    vim.notify("[mygrep] Invalid config: tool_picker_style = " .. tostring(style), vim.log.levels.ERROR)
  end
end

return M
