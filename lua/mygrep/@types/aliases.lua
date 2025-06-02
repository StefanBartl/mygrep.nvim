---@module 'mygrep.types.aliases'
---@brief Shared type aliases used throughout mygrep.nvim
---@description
--- This module defines all shared aliases and type annotations used in
--- mygrep.nvim to improve LSP support and ensure consistency across tools.
--- It should be imported anywhere type safety or shared interfaces are required.

---@alias ConfigOptions table<string, any>
---@alias Keymaps table<string, string|false>
---@alias ToolPickerStyle '"ui"' | '"select"'
---@alias ToolName "live_grep" | "multigrep" | string
---@alias Limit number

---@alias Query string
---@alias HistoryStorage Query[]
---@alias FavoritesStorage Query[]
---@alias PersistsStorage Query[]
---@alias Storage HistoryStorage | FavoritesStorage | PersistsStorage

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

---@alias RegistryTable table<ToolName, RegistryEntry>

---@alias EntryTag "favorite" | "persist" | "session"

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
