---@module 'myterm.@types.picker'
---@brief Types used for picker-based UI interactions
---@description
--- Types used for picker state, callbacks and display properties.

---@alias ToolName "live_grep" | "multigrep" | "multigrep_file" | string

---@class ToolState
---@field history string[]
---@field favorites string[]
---@field persist string[]

---@class PickerInternalOpts
---@field title string
---@field tool ToolName
---@field callback fun(input: string)
---@field state ToolState
---@field default_text? string

---@class PickerUserOpts
---@field default_text? string

---@class PickerMappingParams
---@field tool ToolName
---@field title string
---@field callback fun(input: string)
---@field tool_state ToolState
---@field combined_history string[]
---@field last_prompt string

---@class TelescopePicker
---@field reset_prompt fun(prompt: string): nil

