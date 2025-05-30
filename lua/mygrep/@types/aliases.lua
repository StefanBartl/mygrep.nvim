---@module 'mygrep.types.aliases'
---@brief Shared type aliases used throughout mygrep.nvim
---@description
--- This module defines all shared aliases and type annotations used in
--- mygrep.nvim to improve LSP support and ensure consistency across tools.
--- It should be imported anywhere type safety or shared interfaces are required.

---@alias ToolName string Tool identifier used in registry (e.g. "live_grep", "multigrep")

---@class ToolState
---@field history string[] Session-only queries
---@field favorites string[] Pinned entries always shown on top
---@field persist string[] Persisted queries stored on disk
---@field undo? string[] Optional undo stack (last removed entries)

---@class PickerOptions
---@field title string Title shown in Telescope prompt
---@field tool ToolName Tool identifier used for state/folder
---@field callback fun(input: string): nil Function to run search on input
---@field state ToolState Loaded or initialized state object

---@class RegistryEntry
---@field name ToolName
---@field run fun(opts?: table): nil Entry point for running the tool
---@field config? table Optional tool-specific config

local M = {}

return M
