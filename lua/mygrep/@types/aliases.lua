---@module 'mygrep.types.aliases'
---@brief Shared type aliases used throughout mygrep.nvim
---@description
--- This module defines all shared aliases and type annotations used in
--- mygrep.nvim to improve LSP support and ensure consistency across tools.
--- It should be imported anywhere type safety or shared interfaces are required.

---Plugin-wide configuration options
---@alias ConfigOptions table<string, any>

---Defines which UI to use for selecting tools:
---"ui"     => floating window buffer (default)
---"select" => command-line `vim.ui.select()`
---@alias ToolPickerStyle '"ui"' | '"select"'

---@alias ToolName string Tool identifier used in registry (e.g. "live_grep", "multigrep")

---@class ToolState
---@field history string[] Session-only queries
---@field favorites string[] Pinned entries always shown on top
---@field persist string[] Persisted queries stored on disk
---@field undo? string[] Optional undo stack (last removed entries)

---@alias PickerInternalOpts { title: string, tool: ToolName, callback: fun(...), state: ToolState, default_text?: string }
---@alias PickerUserOpts { default_text?: string }

---@class RegistryEntry
---@field name ToolName
---@field run fun(opts?: table): nil Entry point for running the tool
---@field config? table Optional tool-specific config

---Mapping of all registered tools
---@alias RegistryTable table<ToolName, RegistryEntry>

local M = {}

return M
