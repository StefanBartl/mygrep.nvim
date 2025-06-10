---@module 'myterm.@types.terminal'
---@brief Terminal instance representation
---@description
--- Types related to terminal buffers, windows and associated metadata.

---@alias LayoutMode "float"|"horizontal"|"vertical"

---@class TerminalInstance
---@field id integer
---@field buf integer
---@field win integer
---@field job_id integer
---@field mode LayoutMode
---@field last_focused boolean
