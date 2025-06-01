---@module 'mygrep.types.aliases'
---@brief Shared type aliases used throughout mygrep.nvim
---@description
--- This module defines all shared aliases and type annotations used in
--- mygrep.nvim to improve LSP support and ensure consistency across tools.
--- It should be imported anywhere type safety or shared interfaces are required.

---Plugin-wide configuration options
---@alias ConfigOptions table<string, any>
---@alias Keymaps table<string, string|false>

---Defines which UI to use for selecting tools:
---"ui"     => floating window buffer (default)
---"select" => command-line `vim.ui.select()`
---@alias ToolPickerStyle '"ui"' | '"select"'

---Default implemented tools + open string type
---@alias ToolName "live_grep" | "mutligrep" | string Tool identifier used in registry (e.g. "live_grep", "multigrep")

---Limit for the history and persistent storage
---@alias Limit number


---@alias Query string
---@alias HistoryStorage Query[] Session-only queries
---@alias FavoritesStorage Query[] Pinned entries always shown on top
---@alias PersistsStorage Query[] Persisted queries stored on disk
---@alias Storage HistoryStorage | FavoritesStorage | PersistsStorage


---@class ToolState
---@field history HistoryStorage Session-only queries
---@field favorites FavoritesStorage Pinned entries always shown on top
---@field persist PersistsStorage Persisted queries stored on disk

---@alias PickerInternalOpts { title: string, tool: ToolName, callback: fun(...), state: ToolState, default_text?: string }
---@alias PickerUserOpts { default_text?: string }

---@class RegistryEntry
---@field name ToolName
---@field run fun(opts?: table): nil Entry point for running the tool
---@field config? table Optional tool-specific config

---Mapping of all registered tools
---@alias RegistryTable table<ToolName, RegistryEntry>

---@alias SearchRootMode 'cwd' | 'root' | 'custom' | 'home'

---@class SearchRootState
---@field mode SearchRootMode
---@field custom_path? string
---@field project_dir? string

---@alias PickerMappingParams { tool: ToolName, title: string, callback: fun(string), tool_state: ToolState, combined_history: string[], last_prompt: string }

---@alias EntryTag "favorite" | "persist" | "session"


local M = {}

return M
