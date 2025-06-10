---@module 'myterm.@types.config'
---@brief Shared type aliases for global config options
---@description
--- Defines config keys, styles, keymap structure and limits used
--- in the global options table of myterm.nvim.

---@alias ToolPickerStyle '"ui"' | '"select"'

---@alias Limit integer

---@alias Keymaps table<string, string|false>

---@alias ConfigOptions
---| "tool_picker_style"
---| "history_limit"
---| "persist_limit"
---| "keymaps"

---@class OptionsTable
---@field tool_picker_style ToolPickerStyle
---@field history_limit Limit
---@field persist_limit Limit
---@field keymaps Keymaps
