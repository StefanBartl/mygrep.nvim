---@module 'mygrep.ui.tool_cmdline_select'
---@class ToolPicker
---@brief Presents a floating window to choose a grep tool
---@description
--- Offers a minimal UI using vim.ui.select with custom border and title.
local M = {}

-- Vim Utilties
local notify = vim.notify
local select = vim.ui.select
-- MyGrep dependencies
local registry = require("mygrep.core.registry")


---Opens the floating tool selector
---@return nil
function M.open()
  local tools = registry.list()
  if #tools == 0 then
    notify("[mygrep] No tools registered", vim.log.levels.WARN)
    return
  end

  table.sort(tools, function(a, b)
    if a == "live_grep" then return true end
    if b == "live_grep" then return false end
    return a < b
  end)

  select(tools, {
    prompt = "MyGrep - Select Tool",
    format_item = function(item) return item end,
    kind = "mygrep_tool_selector",
  }, function(selected)
    if not selected then return end
    local tool = registry.get(selected)
    if tool and tool.run then
      tool.run()
    else
      notify("[mygrep] Tool '" .. selected .. "' is not executable", vim.log.levels.ERROR)
    end
  end)
end

return M
