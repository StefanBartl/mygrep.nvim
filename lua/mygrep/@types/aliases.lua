---@module 'mygrep.@types.aliases'
---@brief Shared type aliases used throughout mygrep.nvim
---@description
--- This module defines all shared aliases used in
--- mygrep.nvim to improve LSP support and ensure consistency across tools.

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

---@alias RegistryTable table<ToolName, RegistryEntry>

---@alias EntryTag "favorite" | "persist" | "session"

---@alias SearchRootMode 'cwd' | 'root' | 'custom' | 'home'
