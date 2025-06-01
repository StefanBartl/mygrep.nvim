---@module 'mygrep.config'
---@brief Central configuration for mygrep.nvim
---@description
--- This module stores and retrieves global plugin options.
--- Users can override `M.options` during setup() if needed.

local M = {}

---@type ConfigOptions
M.options = {
  ---@type ToolPickerStyle
  tool_picker_style = "ui",
  ---@type Limit
  history_limit = 100,  -- Sets the limit for queries saved to the history storage (RAM) per tool
  ---@type Limit
  persist_limit  = 100, -- Maximum number of persisted queries saved to disk (json) per tool

  ---@type Keymaps
  keymaps = {
    open = "<leader><leader>",
    live_grep = "<leader>ml",
    multigrep = "<leader>mm",
  },
}


---@overload fun(key: "tool_picker_style"): ToolPickerStyle
---@overload fun(key: "history_limit"): Limit
---@overload fun(key: "persist_limit"): Limit
---@overload fun(key: "keymaps"): Keymaps
---Returns a configured option by key
---@param key ConfigOptions
---@return ToolName | Keymaps | Limit | nil
function M.get_option(key)
  return M.options[key] or nil
end

return M
