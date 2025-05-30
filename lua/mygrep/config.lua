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

  ---@type Keymaps
  keymaps = {
    open = "<leader><leader>",
    live_grep = "<leader>ml",
    multigrep = "<leader>mm",
  },
}

---Returns a configured option by key
---@param key string
---@return any | nil
function M.get_option(key)
  return M.options[key] or nil
end

return M
