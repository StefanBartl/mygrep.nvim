---@module 'mygrep.@types.classes'
---@brief Shared type classes used throughout mygrep.nvim
---@description
--- This module defines all shared classes used in
--- mygrep.nvim to improve LSP support and ensure consistency across tools.

---@class ToolState
---@field history HistoryStorage
---@field favorites FavoritesStorage
---@field persist PersistsStorage

---@class PickerInternalOpts
---@field title string
---@field tool ToolName
---@field callback fun(input: string)
---@field state ToolState
---@field default_text? string

---@class PickerUserOpts
---@field default_text? string

---@class RegistryEntry
---@field name ToolName
---@field run fun(opts?: table): nil
---@field config? table

---@class SearchRootState
---@field mode 'cwd' | 'root' | 'custom' | 'home'
---@field custom_path? string
---@field project_dir? string

---@class PickerMappingParams
---@field tool ToolName
---@field title string
---@field callback fun(input: string)
---@field tool_state ToolState
---@field combined_history string[]
---@field last_prompt string

---@class TelescopePicker
---@field reset_prompt fun(prompt: string): nil
