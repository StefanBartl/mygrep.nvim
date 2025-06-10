---@module 'myterm.@types.registry'
---@brief Registry table definitions
---@description
--- Defines tool registry entries and their executable interface.

---@class RegistryEntry
---@field name string
---@field run fun(opts?: table): nil
---@field config? table

---@alias RegistryTable table<string, RegistryEntry>
